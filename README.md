# SplitVid

A powerful and flexible video splitting utility that allows you to split videos into equal halves or segments with various optimization options.

## Features

- Split videos into two equal parts
- Split videos into segments of specified duration
- GPU acceleration support (CUDA/VAAPI)
- Quality optimization options
- Keyframe-accurate splitting
- Progress tracking
- Detailed metadata generation

## Prerequisites

- ffmpeg
- ffprobe
- bc (basic calculator)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/splitvid.git
   cd splitvid
   ```

2. Make the script executable:
   ```bash
   chmod +x splitvid.sh
   ```

## Usage

```bash
./splitvid.sh [-i input_file] [-o output_dir] [-m mode] [-d duration] [-k] [-g] [-q]
```

### Options

- `-i` : Input video file (required)
- `-o` : Output directory (default: timestamped folder)
- `-m` : Split mode (half/segments) (default: half)
- `-d` : Segment duration in seconds (required for segments mode)
- `-k` : Disable keyframe-accurate splitting
- `-g` : Enable GPU acceleration (if available)
- `-q` : Enable quality optimization

### Examples

1. Split a video in half:
   ```bash
   ./splitvid.sh -i video.mp4
   ```

2. Split into 2-minute segments:
   ```bash
   ./splitvid.sh -i video.mp4 -m segments -d 120
   ```

3. Split with GPU acceleration and quality optimization:
   ```bash
   ./splitvid.sh -i video.mp4 -g -q
   ```

## Testing

Run the test suite:
```bash
./test_splitvid.sh
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
