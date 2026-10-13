#!/usr/bin/env bash
# to_line.sh — convert a video into an mp4 that LINE plays inline.
# Version: 1.0.0
# Usage: bash to_line.sh <input> [--crf N]
# Output: <input dir>/<input name>_line.mp4; the input is never modified.
#         Over 299 s of video: equal parts <input name>_line_<i>of<n>.mp4, each under LINE's 5 minutes.
# Exit: 0 = converted and all checks PASS; 2 = usage error;
#       1 = anything else: output exists, input unreadable or refused, temp file, ffmpeg, or a check failed;
#       130 / 143 = interrupted by SIGINT / SIGTERM, nothing written.
set -euo pipefail

usage() { echo "usage: bash $(basename "$0") <input> [--crf N]" >&2; exit 2; }

for tool in ffmpeg ffprobe; do
  command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: $tool not found in PATH" >&2; exit 2; }
done

[ $# -ge 1 ] || usage
in="$1"; shift
crf=23
while [ $# -gt 0 ]; do
  case "$1" in
    --crf) [ $# -ge 2 ] || usage; crf="$2"; shift 2 ;;
    *) usage ;;
  esac
done
# libx264 silently clamps values above 51, which would hide a typo behind a blurry file;
# crf 0 is lossless, which -profile:v high rejects, so the encode would fail later instead of here.
case "$crf" in ''|*[!0-9]*) echo "ERROR: --crf must be an integer 1-51, got '$crf'" >&2; exit 2 ;; esac
[ "$crf" -ge 1 ] && [ "$crf" -le 51 ] || { echo "ERROR: --crf must be an integer 1-51, got '$crf'" >&2; exit 2; }
[ -f "$in" ] || { echo "ERROR: input not found: $in" >&2; exit 2; }
# A bare relative name is otherwise read as an option when it starts with '-' (dirname, ffprobe)
# or as a protocol when it contains ':' (ffmpeg), so anchor it to the current directory.
case "$in" in /*|./*|../*) ;; *) in="./$in" ;; esac

dir=$(dirname "$in")
base=$(basename "$in")
stem=${base%.*}

# First value only: mpegts repeats every stream field under its PROGRAM section.
probe() { ffprobe -v error "$@" -of default=noprint_wrappers=1:nokey=1 | awk 'NR == 1'; }

w=$(probe -select_streams v:0 -show_entries stream=width "$in" 2>/dev/null) \
  || { echo "ERROR: ffprobe cannot read $in (not a video, or corrupt)" >&2; exit 1; }
h=$(probe -select_streams v:0 -show_entries stream=height "$in")
[ -n "$w" ] && [ -n "$h" ] || { echo "ERROR: no video stream in $in" >&2; exit 1; }
case "$w$h" in *[!0-9]*) echo "ERROR: unreadable frame size '${w}x${h}' in $in" >&2; exit 1 ;; esac
# Only plain media containers: a text playlist renamed to .mov (ffconcat, for one) is accepted by ffmpeg
# and splices other files from the same folder into the output, which then gets sent to someone else.
fmt=$(probe -show_entries format=format_name "$in")
case "$fmt" in
  mov,mp4,m4a,3gp,3g2,mj2|matroska,webm|avi|mpegts|flv|asf|mpeg) ;;
  *) echo "ERROR: $in is a '$fmt' file, not a plain video container; refusing it" >&2; exit 1 ;;
esac
has_audio=$(probe -select_streams a:0 -show_entries stream=codec_name "$in")

# The video track's own duration: the container's covers every stream, so a longer audio track
# would mask a truncated video, and unmapped tracks (a second audio, timecode) would fail a good file.
# Some containers (mkv, webm) leave stream duration N/A; the container's is the last resort.
video_duration() {
  local d
  d=$(probe -select_streams v:0 -show_entries stream=duration "$1")
  case "$d" in ''|N/A)
    # Matroska keeps a per-stream length only as a DURATION tag (HH:MM:SS.fraction).
    d=$(probe -select_streams v:0 -show_entries stream_tags=DURATION "$1" \
      | awk -F: 'NF == 3 { printf "%.6f", $1 * 3600 + $2 * 60 + $3 }') ;;
  esac
  case "$d" in ''|N/A) d=$(probe -show_entries format=duration "$1") ;; esac
  echo "$d"
}
d_in=$(video_duration "$in")
case "$d_in" in ''|*[!0-9.]*) echo "ERROR: unreadable duration '$d_in' in $in" >&2; exit 1 ;; esac

# LINE keeps only the first 5 minutes of a longer chat video, so longer input is split into equal parts.
# Each part's video stays at most 299 s: AAC priming and container rounding add a few ms that must not reach 300 s.
nparts=$(awk -v d="$d_in" 'BEGIN { n = int(d / 299); if (n * 299 < d) n++; if (n < 1) n = 1; print n }')
part_len=$(awk -v d="$d_in" -v n="$nparts" 'BEGIN { printf "%.3f", d / n }')
outs=()
i=1
while [ "$i" -le "$nparts" ]; do
  if [ "$nparts" -eq 1 ]; then outs+=("$dir/${stem}_line.mp4"); else outs+=("$dir/${stem}_line_${i}of${nparts}.mp4"); fi
  i=$((i + 1))
done
# Checked up front so a long encode is not wasted on an output that cannot be placed.
for out in "${outs[@]}"; do
  [ -e "$out" ] && { echo "ERROR: output already exists, not overwriting: $out" >&2; exit 1; }
done
[ "$nparts" -gt 1 ] && echo "note: video is ${d_in} s, over LINE's 5-minute limit; splitting into $nparts parts of ${part_len} s"

# yuv420p subsamples chroma 2x2, so libx264 rejects odd width/height.
# Crop one edge pixel instead of scaling: no resample, and the PSNR reference below stays pixel-aligned.
# Even input gets no filter at all, so its video is encoded with the same options already confirmed to play in LINE.
vf=()
if [ $((w % 2)) -ne 0 ] || [ $((h % 2)) -ne 0 ]; then
  vf=(-vf "crop=trunc(iw/2)*2:trunc(ih/2)*2:0:0")
  echo "note: ${w}x${h} has an odd side, cropping to even"
fi

if [ -n "$has_audio" ]; then
  audio=(-map 0:a:0 -c:a aac -b:a 128k)
else
  audio=(-an)
fi

# --- checks: any FAIL means no output is placed ---
fail=0
# Runs the test inside `if` so a failing test is reported, not turned into a set -e exit.
check() { # name, detail, test command...
  local name="$1" detail="$2"; shift 2
  if "$@"; then echo "PASS  $name ($detail)"; else echo "FAIL  $name ($detail)"; fail=1; fi
}
# A non-numeric duration (N/A) counts as a FAIL rather than as 0 s.
within_01s() { awk -v a="$1" -v b="$2" 'BEGIN { if (a !~ /^[0-9.]+$/ || b !~ /^[0-9.]+$/) exit 1; d = a - b; if (d < 0) d = -d; exit !(d < 0.1) }'; }
under_300s() { awk -v a="$1" 'BEGIN { if (a !~ /^[0-9.]+$/) exit 1; exit !(a < 300) }'; }

# Every part is encoded into a file mktemp created for this run, so the only files ever deleted are ones
# this run owns, and nothing is placed until every part has passed: a failed, interrupted or rejected run
# leaves no half-written or partial set of _line files to block the next run.
tmps=()
trap 'rm -f ${tmps[@]+"${tmps[@]}"}' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# ffmpeg answers Ctrl-C by stopping early and exiting 255 instead of dying from the signal, so bash never runs
# the INT trap: without this the run would carry on and place the outputs.
interrupted() {
  [ "$1" -ne 255 ] && return 0
  echo "RESULT: FAIL — interrupted; no output was written"
  exit 130
}
size_in=$(wc -c < "$in" | tr -d ' ')
br_in=$(probe -show_entries format=bit_rate "$in")
i=1
while [ "$i" -le "$nparts" ]; do
  out=${outs[$((i - 1))]}
  tmp=$(mktemp "$dir/.${stem}_line.XXXXXX") || { echo "ERROR: cannot create a temp file in $dir" >&2; exit 1; }
  tmps+=("$tmp")
  seek=(); label=""
  if [ "$nparts" -gt 1 ]; then
    # Each part runs from its own rounded start to the next part's rounded start, so a frame sitting between
    # two rounded boundaries lands in exactly one part instead of being cut from both.
    start=$(awk -v d="$d_in" -v n="$nparts" -v i="$i" 'BEGIN { printf "%.3f", (i - 1) * d / n }')
    if [ "$i" -lt "$nparts" ]; then
      expect=$(awk -v d="$d_in" -v n="$nparts" -v i="$i" -v s="$start" 'BEGIN { printf "%.3f", sprintf("%.3f", i * d / n) - s }')
    else
      expect=$(awk -v d="$d_in" -v s="$start" 'BEGIN { printf "%.3f", d - s }')
    fi
    seek=(-ss "$start"); label=" [part $i/$nparts]"
  else
    expect=$d_in
  fi
  # Every output stops at its video span: an audio track running past the video would otherwise
  # stretch the file past LINE's 5 minutes even though the video fits.
  span=(-t "$expect")

  echo "converting${label}: $in -> $out (crf $crf, audio: ${has_audio:-none})"
  rc=0
  ffmpeg -nostdin -hide_banner -loglevel error -stats -y ${seek[@]+"${seek[@]}"} -i "$in" -map 0:v:0 ${vf[@]+"${vf[@]}"} \
    -c:v libx264 -preset fast -crf "$crf" -pix_fmt yuv420p -profile:v high \
    "${audio[@]}" ${span[@]+"${span[@]}"} -movflags +faststart -f mp4 "$tmp" || rc=$?
  interrupted "$rc"
  [ "$rc" -eq 0 ] || { echo "RESULT: FAIL — ffmpeg could not convert $in${label}"; exit 1; }

  vcodec=$(probe -select_streams v:0 -show_entries stream=codec_name "$tmp")
  check "video codec h264${label}" "$vcodec" [ "$vcodec" = h264 ]

  pixfmt=$(probe -select_streams v:0 -show_entries stream=pix_fmt "$tmp")
  check "pixel format yuv420p${label}" "$pixfmt" [ "$pixfmt" = yuv420p ]

  # Without faststart the moov atom trails mdat and LINE has to download the whole file before playing.
  first_atom=$(ffprobe -v trace -i "$tmp" 2>&1 | grep -oE "type:'(moov|mdat)'" | head -1 || true)
  check "moov before mdat (faststart)${label}" "first: ${first_atom:-none}" [ "$first_atom" = "type:'moov'" ]

  d_out=$(video_duration "$tmp")
  check "video duration within 0.1 s${label}" "expected $expect s, out $d_out s" within_01s "$expect" "$d_out"

  c_out=$(probe -show_entries format=duration "$tmp")
  check "file duration under 300 s${label}" "$c_out s" under_300s "$c_out"

  if [ -n "$has_audio" ]; then
    acodec=$(probe -select_streams a:0 -show_entries stream=codec_name "$tmp")
    check "audio codec aac${label}" "${acodec:-none}" [ "$acodec" = aac ]
  fi

  size_out=$(wc -c < "$tmp" | tr -d ' ')
  br_out=$(probe -show_entries format=bit_rate "$tmp")
  awk -v si="$size_in" -v so="$size_out" -v bi="$br_in" -v bo="$br_out" -v n="$nparts" '
  function kbps(v) { return v ~ /^[0-9]+$/ ? sprintf("%.0f kb/s", v / 1000) : "unavailable" }
  BEGIN {
    if (n == 1) printf "size     %.1f MB -> %.1f MB (%.0f%%)\n", si/1e6, so/1e6, so*100/si
    else        printf "size     %.1f MB (input %.1f MB in total)\n", so/1e6, si/1e6
    printf "bitrate  %s -> %s\n", kbps(bi), kbps(bo)
  }'

  # The reference is cut to the same span and cropped the same way. Both sides restart their timestamps at 0:
  # a seek that lands a fraction of a millisecond before a frame otherwise offsets the pairing by one frame.
  rc=0
  psnr_log=$(ffmpeg -nostdin -hide_banner -nostats -i "$tmp" ${seek[@]+"${seek[@]}"} ${span[@]+"${span[@]}"} -i "$in" \
    -lavfi "[0:v]setpts=PTS-STARTPTS[out];[1:v]crop=trunc(iw/2)*2:trunc(ih/2)*2:0:0,setpts=PTS-STARTPTS[ref];[out][ref]psnr" -f null - 2>&1) || rc=$?
  interrupted "$rc"
  psnr=$(printf '%s\n' "$psnr_log" | grep -oE 'average:[0-9.inf]+ min:[0-9.inf]+' | tail -1 || true)
  echo "PSNR     ${psnr:-unavailable} dB"
  i=$((i + 1))
done

if [ "$fail" -ne 0 ]; then
  echo "RESULT: FAIL — not every check passed; no output was written"
  exit 1
fi

# mktemp creates mode 600; give the outputs the mode a normally created file gets under this umask.
mode=$(printf '%o' $((0666 & ~$(umask))))
placed=()
i=0
while [ "$i" -lt "$nparts" ]; do
  chmod "$mode" "${tmps[$i]}"
  # mv -n keeps a file that appeared at the output path during the encode; the temp file still existing means it did.
  mv -n "${tmps[$i]}" "${outs[$i]}" || true
  if [ -e "${tmps[$i]}" ]; then
    echo "RESULT: FAIL — ${outs[$i]} appeared during the conversion; it was left untouched${placed[@]+; already placed: ${placed[*]}}"
    exit 1
  fi
  placed+=("${outs[$i]}")
  i=$((i + 1))
done

if [ "$nparts" -eq 1 ]; then
  echo "RESULT: PASS — ${outs[0]}"
else
  echo "RESULT: PASS — $nparts parts: ${outs[*]}"
fi
