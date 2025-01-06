#!/bin/bash

# Enhanced video splitting script with error handling, progress tracking, and advanced features

# Default settings
input_file=""
output_dir="split_output_$(date +%Y%m%d_%H%M%S)"
split_mode="half"
segment_duration=""
preserve_keyframes=true
gpu_acceleration=false
quality_optimization=false

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [-i input_file] [-o output_dir] [-m mode] [-d duration] [-k] [-g] [-q]"
    echo "Options:"
    echo "  -i : Input video file (required)"
    echo "  -o : Output directory (default: timestamped folder)"
    echo "  -m : Split mode (half/segments) (default: half)"
    echo "  -d : Segment duration in seconds (required for segments mode)"
    echo "  -k : Disable keyframe-accurate splitting"
    echo "  -g : Enable GPU acceleration (if available)"
    echo "  -q : Enable quality optimization"
    exit 1
}

# Function to check dependencies
check_dependencies() {
    local deps=("ffmpeg" "ffprobe" "bc")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Error: Missing dependencies: ${missing[*]}${NC}"
        exit 1
    fi
}

# Function to validate input file
validate_input() {
    if [ ! -f "$input_file" ]; then
        echo -e "${RED}Error: Input file not found: $input_file${NC}"
        exit 1
    fi
    
    # Check if input is a valid video file
    if ! ffprobe -v quiet "$input_file" 2>/dev/null; then
        echo -e "${RED}Error: Invalid video file: $input_file${NC}"
        exit 1
    fi
}

# Parse command line arguments
while getopts "i:o:m:d:kgq" opt; do
    case $opt in
        i) input_file="$OPTARG" ;;
        o) output_dir="$OPTARG" ;;
        m) split_mode="$OPTARG" ;;
        d) segment_duration="$OPTARG" ;;
        k) preserve_keyframes=false ;;
        g) gpu_acceleration=true ;;
        q) quality_optimization=true ;;
        ?) usage ;;
    esac
done

# Check required arguments
if [ -z "$input_file" ]; then
    echo -e "${RED}Error: Input file is required${NC}"
    usage
fi

if [ "$split_mode" = "segments" ] && [ -z "$segment_duration" ]; then
    echo -e "${RED}Error: Segment duration is required for segments mode${NC}"
    usage
fi

# Check dependencies
check_dependencies

# Validate input file
validate_input

# Create output directory
mkdir -p "$output_dir"

# Get video information
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")
codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$input_file")

# Configure encoding parameters
encode_params=()
if [ "$gpu_acceleration" = true ]; then
    if ffmpeg -hide_banner -hwaccels | grep -q "cuda"; then
        encode_params+=(-hwaccel cuda)
    elif ffmpeg -hide_banner -hwaccels | grep -q "vaapi"; then
        encode_params+=(-hwaccel vaapi)
    fi
fi

if [ "$quality_optimization" = true ]; then
    encode_params+=(-preset slow -crf 18)
else
    encode_params+=(-c copy)
fi

# Function to format time
format_time() {
    printf "%02d:%02d:%02d" $(($1/3600)) $(($1%3600/60)) $(($1%60))
}

# Function to process split
process_split() {
    local start=$1
    local duration=$2
    local output=$3
    
    echo -e "${YELLOW}Processing: $output${NC}"
    
    if [ "$preserve_keyframes" = true ]; then
        encode_params+=(-avoid_negative_ts 1)
    fi
    
    ffmpeg "${encode_params[@]}" -i "$input_file" -ss "$start" -t "$duration" \
        -progress pipe:1 "$output" 2>/dev/null | \
    while read line; do
        if [[ $line == time=* ]]; then
            current_time=${line#time=}
            current_seconds=$(echo "$current_time" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
            progress=$(echo "scale=2; $current_seconds/$duration * 100" | bc)
            echo -ne "\rProgress: ${progress}%"
        fi
    done
    echo -e "\n${GREEN}Completed: $output${NC}"
}

# Split based on mode
if [ "$split_mode" = "half" ]; then
    half_duration=$(echo "$duration / 2" | bc)
    
    process_split 0 "$half_duration" "$output_dir/part1.mp4"
    process_split "$half_duration" "$duration" "$output_dir/part2.mp4"
    
elif [ "$split_mode" = "segments" ]; then
    segment_count=$(echo "($duration + $segment_duration - 1) / $segment_duration" | bc)
    
    for ((i=0; i<segment_count; i++)); do
        start=$(echo "$i * $segment_duration" | bc)
        process_split "$start" "$segment_duration" "$output_dir/segment_${i}.mp4"
    done
fi

# Generate metadata file
{
    echo "Split Details:"
    echo "Input File: $input_file"
    echo "Duration: $(format_time ${duration%.*})"
    echo "Codec: $codec"
    echo "Split Mode: $split_mode"
    echo "GPU Acceleration: $gpu_acceleration"
    echo "Quality Optimization: $quality_optimization"
    echo "Timestamp: $(date)"
} > "$output_dir/metadata.txt"

echo -e "\n${GREEN}Video splitting completed successfully!${NC}"
echo "Output directory: $output_dir"