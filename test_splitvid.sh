#!/bin/bash

# Test suite for splitvid.sh
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Create test video file
create_test_video() {
    echo "Creating test video..."
    ffmpeg -y -f lavfi -i "testsrc=duration=10:size=1280x720:rate=30" -c:v libx264 -preset ultrafast test_video.mp4
}

# Test 1: Basic half split
test_half_split() {
    echo "Testing half split mode..."
    rm -rf split_output_* # Clean previous test outputs
    ./splitvid.sh -i test_video.mp4 -m half
    
    # Wait a moment for files to be created
    sleep 1
    
    # Use find to locate the most recent output directory
    output_dir=$(find . -maxdepth 1 -type d -name "split_output_*" | sort -r | head -n1)
    
    if [ ! -f "${output_dir}/part1.mp4" ] || [ ! -f "${output_dir}/part2.mp4" ]; then
        echo -e "${RED}✗ Half split test failed - files not found in ./${output_dir}${NC}"
        ls -la "${output_dir}"
        return 1
    else
        echo -e "${GREEN}✓ Half split test passed${NC}"
        return 0
    fi
}

# Test 2: Segment split
test_segment_split() {
    echo "Testing segment split mode..."
    rm -rf split_output_* # Clean previous test outputs
    ./splitvid.sh -i test_video.mp4 -m segments -d 2
    
    # Wait a moment for files to be created
    sleep 1
    
    # Use find to locate the most recent output directory
    output_dir=$(find . -maxdepth 1 -type d -name "split_output_*" | sort -r | head -n1)
    
    # Check if we have 5 segments (10 seconds / 2 seconds per segment)
    missing_segments=0
    for i in {0..4}; do
        if [ ! -f "${output_dir}/segment_${i}.mp4" ]; then
            echo -e "${RED}✗ Missing segment_${i}.mp4${NC}"
            ((missing_segments++))
        fi
    done
    
    if [ $missing_segments -gt 0 ]; then
        echo -e "${RED}✗ Segment split test failed - $missing_segments segments missing${NC}"
        ls -la "${output_dir}"
        return 1
    else
        echo -e "${GREEN}✓ Segment split test passed${NC}"
        return 0
    fi
}

# Test 3: Invalid input file
test_invalid_input() {
    echo "Testing invalid input handling..."
    if ./splitvid.sh -i nonexistent.mp4 2>&1 | grep -q "Error: Input file not found"; then
        echo -e "${GREEN}✓ Invalid input test passed${NC}"
    else
        echo -e "${RED}✗ Invalid input test failed${NC}"
        return 1
    fi
}

# Run tests
create_test_video

echo "Running tests..."
test_half_split
test_segment_split
test_invalid_input

# Final cleanup
rm -f test_video.mp4
rm -rf split_output_*

echo "Test suite completed"
