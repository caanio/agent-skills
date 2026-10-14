---
name: video-to-line
description: Convert a video (screen recording .mov, phone clip; mov/mp4/3gp, mkv/webm, avi, ts, flv, wmv or mpeg) into an H.264 mp4 that plays inline in LINE chat, then verify the result. Use when the user wants to send a video over LINE, says a video won't play in LINE or arrives as a file attachment instead of a video (LINE 不能播 / 變成檔案 / 傳到 LINE), asks to shrink a .mov into a LINE-friendly mp4, or has a video over 5 minutes to send (影片太長 / 超過 5 分鐘).
---

# Video → LINE-playable mp4

Version: 1.1.0 | Date: 2026-10-13

One script does the conversion and its own verification:
`scripts/to_line.sh` in this skill's folder (bash + ffmpeg/ffprobe, macOS bash 3.2 compatible).
Tested 2026-10-13 with ffmpeg 9.0.2 on a macOS QuickTime screen recording
(.mov, H.264 Main, 1622x1004, variable frame rate averaging 31 fps, no audio, 11 s, 26 MB):
the script's output, 1.8 MB at 1.30 Mbps with PSNR average 42.7 dB, played inline in LINE for Mac 8.7.0;
so did the same recording with an AAC track added (1.42 Mbps).

## Steps

1. Run `bash <skill-dir>/scripts/to_line.sh <input> [--crf N] 2>&1`.
   Output lands beside the input as `<input name>_line.mp4`, or as `<input name>_line_<i>of<n>.mp4` parts for long video (see Length);
   the input is never touched.
   Every part is encoded to a hidden temp file and placed only once all parts pass, so a failed or interrupted run leaves no output.
2. Done = exit 0 and the last line `RESULT: PASS — <path>` or `RESULT: PASS — <n> parts: <paths>`.
   Report the paths plus each part's `size`, `bitrate` and `PSNR` lines; for parts, tell the user to send them in order.
   Any other exit → report the `ERROR:`, `FAIL` and `RESULT: FAIL` lines verbatim, then take the exit table's next move.

## Exit codes

| Exit | Meaning | Next move |
|---|---|---|
| 0 | converted, every check PASS | deliver the path |
| 1 | output (or any part's output) already exists | ask the user to rename or delete it — the script never overwrites |
| 1 | input unreadable, without a video stream, with an unreadable frame size or duration, or not a plain video container (`not a plain video container; refusing it`) | ask the user for the right file; a refused container is never forced through — playlist formats can splice other local files into the output |
| 1 | `ERROR: cannot create a temp file in <dir>` | the input's folder is not writable; ask the user to make it writable or copy the input somewhere writable |
| 1 | `RESULT: FAIL — ffmpeg could not convert` | nothing was left on disk; fix the cause in ffmpeg's error line above it, then rerun |
| 1 | `RESULT: FAIL — … appeared during the conversion` | another program wrote that path mid-run; it was left untouched, and any parts named as already placed stay — same next move as "output already exists" |
| 1 | `RESULT: FAIL — not every check passed` | no output was written, and a split run stops at the first failing part without encoding the rest; report the `FAIL` lines — they describe the input or the encode, so rerunning unchanged gives the same result. A bitrate FAIL alone (short, busy clips) → rerun with `--crf` raised by 5 until it passes; a 1 s clip of moving noise with audio needed 40 |
| 130 / 143 | interrupted (Ctrl-C / SIGTERM), `RESULT: FAIL — interrupted` on Ctrl-C | nothing was written; rerun when the user wants |
| 2 | usage: no input given, unknown option or `--crf` without a value, input path not found, `--crf` outside integer 1–51, ffmpeg/ffprobe not in PATH | fix the call; ffmpeg missing → the user installs it (`brew install ffmpeg` on macOS; on macOS 12 see the ⚠️ under Coverage limits) |

## What the script decides

- **Audio**: input has an audio stream → AAC 128 kb/s; none → `-an`.
- **Odd width/height**: yuv420p needs even sides, so one edge pixel is cropped (no resampling).
  Even input gets no filter.
- **Bitrate**: ⚠️ LINE for Mac 8.7.0 sends a clip as a file attachment instead of a video
  above a bitrate somewhere between 1.71 and 2.86 Mbps; hit in practice 2026-10-13.
  Re-encodes of one 11 s recording (one looped to 74 s) arrived as a video at 0.9–1.71 Mbps and as a file at 2.86–10.4 Mbps,
  across 1280 and 1622 wide and 1.3 MB to 8.3 MB, so bitrate, not size or resolution, decided it.
  The LINE Chrome extension took a 2.95 Mbps encode as a video.
  So the video is capped at 1300 kb/s and the whole file checked at 1700 kb/s or less.
- **Length**: ⚠️ LINE truncates a chat video longer than 5 minutes; hit in practice 2026-10-13.
  LINE's help center publishes no chat-video limit (its one official 5-minute figure is for LINE Premium albums);
  third-party reports agree on 5 minutes.
  So more than 299 s of video is split into ceil(seconds / 299) equal parts, each re-encoded from its own start
  (330 s → 2 parts of 165 s); the 1 s margin under 300 s is a guess [unconfirmed].
  Every output stops where its video ends: audio running past the video is cut.
- **Encode**: `libx264 -preset fast -crf 23 -maxrate 1300k -bufsize 1300k -pix_fmt yuv420p -profile:v high -movflags +faststart`.
- **Checks**: video codec h264, pixel format yuv420p,
  `moov` atom before `mdat` (faststart, so playback starts before the download finishes),
  video-track duration within 0.1 s of the input's (of the part's span when split),
  file duration under 300 s, file bitrate at most 1700 kb/s, audio codec aac when audio exists.
- **Quality report**: PSNR against the input, or the same span of it for a part (cropped the same way, so odd-sized input still compares pixel for pixel).

## Tuning

Under the cap the test recording came to about 1.6 MB per 10 s without audio and 1.8 MB with it;
the check allows up to 1700 kb/s, about 2.1 MB per 10 s.
`--crf` sets quality under that cap: lower is sharper only until the cap is reached, higher gives smaller, softer files.
Whether text in busy screen recordings stays readable at the cap is not yet judged [unconfirmed].

## Coverage limits

- Confirmed in LINE for Mac 8.7.0: the script's output for an even-size screen recording, with and without audio.
  The capped output has not been sent through the LINE Chrome extension or a phone [unconfirmed].
- Odd-size input and split parts pass the script's checks on synthetic test files but have not yet been sent through LINE.
- LINE's file-size limit is [unconfirmed]; third-party figures disagree, so the skill states none.
- Resolution and frame rate are kept under the bitrate cap, so 4K60 input stays 4K at H.264 level 5.x but very soft;
  whether LINE and every phone play that is untested [unconfirmed].
- ⚠️ On macOS 12, Homebrew builds ffmpeg and its dependencies from source, and the install failed twice
  on kegs left unlinked (`lame`, then an older `x264`): `brew link lame` and `brew link --overwrite x264`,
  then `brew install ffmpeg` again, finished it; hit in practice 2026-10-13.
  The built-in `avconvert` is no substitute: its 10.4 Mbps output arrived in LINE for Mac as a file.
- Source metadata, such as a phone's GPS location and a title, is copied into the output (kept by maintainer call);
  whether LINE strips it on upload is [unconfirmed].
- iPhone HDR / 10-bit HEVC input becomes 8-bit H.264 that still carries the source's HDR colour tags (BT.2020, HLG or PQ), with no tone mapping;
  how LINE and phones display it is [unconfirmed].
