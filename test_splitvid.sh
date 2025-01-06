#!/bin/bash

# Test suite for splitvid.sh
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Create test video file
create_test_video() {
    ffmpeg -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 -c:v libx264 test_video.mp4
}

# Test 1: Basic half split
test_half_split() {
    echo "Testing half split mode..."
    ./splitvid.sh -i test_video.mp4 -m half
    
    if [ -f "split_output_"*/part1.mp4 ] && [ -f "split_output_"*/part2.mp4 ]; then
        echo -e "${GREEN}✓ Half split test passed${NC}"
    else
        echo -e "${RED}✗ Half split test failed${NC}"
        return 1
    fi
}

# Test 2: Segment split
test_segment_split() {
    echo "Testing segment split mode..."
    ./splitvid.sh -i test_video.mp4 -m segments -d 2
    
    # Check if we have 5 segments (10 seconds / 2 seconds per segment)
    for i in {0..4}; do
        if [ ! -f "split_output_"*/segment_${i}.mp4 ]; then
            echo -e "${RED}✗ Segment split test failed${NC}"
            return 1
        fi
    done
    echo -e "${GREEN}✓ Segment split test passed${NC}"
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
echo "Creating test video..."
create_test_video

echo "Running tests..."
test_half_split
test_segment_split
test_invalid_input

# Cleanup
rm -f test_video.mp4
rm -rf split_output_*

echo "Test suite completed"
