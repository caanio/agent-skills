---
name: video-to-line
description: Convert a video (screen recording .mov, phone clip; mov/mp4, mkv/webm, avi, ts, flv, wmv or mpeg) into an H.264 mp4 that plays inline in LINE chat, then verify the result. Use when the user wants to send a video over LINE, says a video won't play in LINE (LINE 不能播 / 傳到 LINE), asks to shrink a .mov into a LINE-friendly mp4, or has a video over 5 minutes to send (影片太長 / 超過 5 分鐘).
---

# Video → LINE-playable mp4

Version: 1.0.0 | Date: 2026-10-13

One script does the conversion and its own verification:
`scripts/to_line.sh` in this skill's folder (bash + ffmpeg/ffprobe, macOS bash 3.2 compatible).
Tested 2026-10-13 with ffmpeg 8.1: a macOS QuickTime screen recording (.mov, H.264 Main, 1622x1004, 60 fps, no audio, 11 s, 26 MB)
became a 4.1 MB mp4 that played in LINE;
PSNR average 45.4 dB (SSIM 0.986, measured by hand; the script reports PSNR only).

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
| 1 | `RESULT: FAIL — not every check passed` | no output was written; report the `FAIL` lines — they describe the input or the encode, so rerunning unchanged gives the same result |
| 130 / 143 | interrupted (Ctrl-C / SIGTERM), `RESULT: FAIL — interrupted` on Ctrl-C | nothing was written; rerun when the user wants |
| 2 | usage: no input given, unknown option or `--crf` without a value, input path not found, `--crf` outside integer 1–51, ffmpeg/ffprobe not in PATH | fix the call; ffmpeg missing → the user installs it (`brew install ffmpeg` on macOS) |

## What the script decides

- **Audio**: input has an audio stream → AAC 128 kb/s; none → `-an`.
- **Odd width/height**: yuv420p needs even sides, so one edge pixel is cropped (no resampling).
  Even input gets no filter, so its video is encoded with the same options confirmed to play in LINE.
- **Length**: ⚠️ LINE truncates a chat video longer than 5 minutes; hit in practice 2026-10-13.
  LINE's help center publishes no chat-video limit (its one official 5-minute figure is for LINE Premium albums);
  third-party reports agree on 5 minutes.
  So more than 299 s of video is split into ceil(seconds / 299) equal parts, each re-encoded from its own start
  (330 s → 2 parts of 165 s); the 1 s margin under 300 s is a guess [unconfirmed].
  Every output stops where its video ends: audio running past the video is cut.
- **Encode**: `libx264 -preset fast -crf 23 -pix_fmt yuv420p -profile:v high -movflags +faststart`.
- **Checks**: video codec h264, pixel format yuv420p,
  `moov` atom before `mdat` (faststart, so playback starts before the download finishes),
  video-track duration within 0.1 s of the input's (of the part's span when split),
  file duration under 300 s, audio codec aac when audio exists.
- **Quality report**: PSNR against the input, or the same span of it for a part (cropped the same way, so odd-sized input still compares pixel for pixel).

## Tuning

`--crf` trades size for quality: higher = smaller and softer, lower = larger and sharper.
23 already looked clean on screen-recorded UI text; raise it when the file is too large to send.

## Coverage limits

- Only the no-audio, even-size path has been confirmed playing in LINE.
  The audio and odd-size paths pass the script's checks on synthetic test files but are unconfirmed in LINE.
- Split parts pass the script's checks on synthetic test files but have not yet been sent through LINE.
- LINE's file-size limit is [unconfirmed]; third-party figures disagree, so the skill states none.
- Resolution and frame rate are kept, so 4K60 input becomes H.264 High at level 5.x and a large file;
  whether LINE and every phone play that is untested [unconfirmed].
- Source metadata, such as a phone's GPS location and a title, is copied into the output (kept by maintainer call);
  whether LINE strips it on upload is [unconfirmed].
- iPhone HDR / 10-bit HEVC input becomes 8-bit H.264 that still carries the source's HDR colour tags (BT.2020, HLG or PQ), with no tone mapping;
  how LINE and phones display it is [unconfirmed].
