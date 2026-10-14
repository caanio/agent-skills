# LINE for Mac: what decides video vs file attachment

Version: 1.1.0 | Date: 2026-10-13

Why `video-to-line` caps bitrate. Every row below is one file dragged into a
LINE chat by hand and the result read off the chat: inline video, or a file
attachment the receiver must download.

## Setup

- Sender: LINE for Mac 8.7.0 on macOS 12.7.6; ffmpeg 9.0.2 (Homebrew).
- Comparison sender: the LINE Chrome extension on macOS 15.
- Source: one macOS QuickTime screen recording, `.mov`, H.264 Main L4.2,
  1622x1004, variable frame rate (`r_frame_rate` 60/1, `avg_frame_rate`
  1470/47, about 31 fps), no audio, 11.05 s, 26 MB, 18.8 Mbps.
- Variants A–G each change one factor from the skill's 1.0.0 output
  (`libx264 -preset fast -crf 23 -pix_fmt yuv420p -profile:v high
  -movflags +faststart -an`). Values from `ffprobe`; bitrate is the
  container's `format=bit_rate`.

## Results (LINE for Mac 8.7.0)

| File | Change | Size | Resolution | Bitrate | Result |
|---|---|---|---|---|---|
| `avconvert -p Preset1920x1080` | Apple encoder, High L4.0, VFR | 14.4 MB | 1622x1004 | 10.4 Mbps | file |
| skill 1.0.0 output | — | 4.1 MB | 1622x1004 | 2.95 Mbps | file |
| A | silent AAC track added | 4.1 MB | 1622x1004 | 2.96 Mbps | file |
| B | `fps=30` (constant) | 4.1 MB | 1622x1004 | 2.96 Mbps | file |
| D | `-profile:v main -level 4.0` | 3.95 MB | 1622x1004 | 2.86 Mbps | file |
| E | `scale=1280:-2`, crf 16 | 7.0 MB | 1280x792 | 5.0 Mbps | file |
| C | `scale=1280:-2` | 2.4 MB | 1280x792 | 1.71 Mbps | video |
| scale + fps 30 + Main + silent AAC | four changes at once | 2.2 MB | 1280x792 | 1.59 Mbps | video |
| F | crf 30 | 1.3 MB | 1622x1004 | 0.95 Mbps | video |
| G | input looped, crf 30, 73.7 s | 8.3 MB | 1622x1004 | 0.90 Mbps | video |
| capped, first try | `-maxrate 1300k -bufsize 2600k` | 1.9 MB | 1622x1004 | 1.38 Mbps | video |
| same, AAC input | source + 440 Hz AAC track | 2.1 MB | 1622x1004 | 1.51 Mbps | video |
| skill 1.1.0 output | `-maxrate 1300k -bufsize 1300k` | 1.8 MB | 1622x1004 | 1.30 Mbps | video |
| skill 1.1.0, AAC input | source + 440 Hz AAC track | 2.0 MB | 1622x1004 | 1.42 Mbps | video |

## Reading

- Audio, frame-rate mode, profile and level changed nothing on their own
  (A, B, D).
- Resolution is not the gate: C (1280) passed, E (1280) failed; F (1622)
  passed.
- Size is not the gate: G at 8.3 MB passed while D at 3.95 MB failed.
- Bitrate splits every row: video at 1.71 Mbps or below, file at 2.86 Mbps
  or above. The exact threshold inside 1.71–2.86 Mbps is untested, and
  whether LINE reads the average or a peak is inferred, not observed.
- The skill 1.0.0 output arrived as a video through the LINE Chrome
  extension, so the gate belongs to the desktop client. Other LINE builds
  and phones are untested.

## Encoder note

x264's average came out about 6% over `-maxrate`: a 1500k cap gave
1597 kb/s without audio and 1726 kb/s with a 128 kb/s AAC track, which
failed the 1700 kb/s check. 1300k (bufsize still 2600k) gives 1383 and
1511 kb/s.

The overshoot grows on short clips: x264 starts the VBV buffer nearly
full, so a clip of a few seconds can spend most of a buffer on top of
`-maxrate`. Plain ffmpeg runs (not the script, so the 11 s row differs
from the table above by a few kb/s), a 1300k cap, no audio:

| Length | bufsize 2600k | bufsize 1300k | bufsize 650k |
|---|---|---|---|
| 1 s | 2162 kb/s | 1681 kb/s | 1101 kb/s |
| 2 s | 1773 kb/s | 1197 kb/s | 826 kb/s |
| 3 s | 1600 kb/s | 1007 kb/s | 705 kb/s |
| the 11 s recording | 1383 kb/s | 1308 kb/s | 1077 kb/s |

1.1.0 uses bufsize equal to the cap. The 1 s clip with an AAC track
still came to 1851 kb/s and needed `--crf 40` to pass.
