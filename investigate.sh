#!/bin/bash

# =============================================================================
#  Universal File Investigator for CTF (Refactored Version)
#
#  Usage: ./investigate.sh <target_file>
#
#  This script identifies the file type and runs appropriate analysis commands.
# =============================================================================

# --- Color Definitions ---
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# --- Logging Functions ---
# $1: Message
pheader() {
    echo -e "\n${BLUE}--- [ $1 ] ---${NC}"
}

# $1: Message
psubheader() {
    echo -e "\n${YELLOW}--- [ $1 ] ---${NC}"
}

# $1: Message
pcommand() {
    echo -e "${GREEN}>> $1...${NC}"
}

# $1: Message
perror() {
    echo -e "${RED}Error: $1${NC}" >&2
}

# --- Main Script ---

# 1. Check for Input
if [ "$#" -ne 1 ]; then
    perror "Usage: $0 <target_file>"
    exit 1
fi

TARGET_FILE="$1"

if [ ! -f "$TARGET_FILE" ]; then
    perror "File not found: '$TARGET_FILE'"
    exit 1
fi

pheader "Investigating: $TARGET_FILE"

# 2. Basic File Information
psubheader "Basic Information by 'file' command"
FILE_TYPE=$(file -b "$TARGET_FILE")
echo "$FILE_TYPE"

# 3. Analyze Based on File Type
case "$FILE_TYPE" in
    *"ELF"*)
        psubheader "Executable (ELF) Analysis"
        
        pcommand "Running 'strings' to find printable characters"
        strings "$TARGET_FILE"
        pcommand "Running 'readelf -h' for header information"
        readelf -h "$TARGET_FILE"
        pcommand "Running 'pwn checksec' for security properties"
        pwn checksec "$TARGET_FILE"
        pcommand "Running 'objdump -f' for file architecture"
        objdump -f "$TARGET_FILE"
        pcommand "Running 'objdump -t' for symbol table"
        objdump -t "$TARGET_FILE"
        # pcommand "Running 'objdump -d -M intel' for disassembly (first 30 lines)"
        # objdump -d -M intel "$TARGET_FILE" | head -n 30
        ;;

    *"ASCII text"*)
        psubheader "Text File Analysis"
        pcommand "Displaying contents"
        cat "$TARGET_FILE"
        pcommand "Running 'wc' for word/line/char count"
        wc "$TARGET_FILE"
        ;;

    *"Zip archive data"*)
        psubheader "ZIP Archive Analysis"
        pcommand "Listing contents with 'unzip -l'"
        unzip -l "$TARGET_FILE"
        ;;

    *"tar archive"*)
        psubheader "TAR Archive Analysis"
        pcommand "Listing contents with 'tar -tvf'"
        tar -tvf "$TARGET_FILE"
        ;;

    *"JPEG image data"*)
        psubheader "JPEG Image Analysis"
        pcommand "Running 'exiftool' for metadata"
        exiftool "$TARGET_FILE"
        pcommand "Running 'binwalk' for embedded files"
        binwalk "$TARGET_FILE"
        ;;

    *"PNG image data"*)
        psubheader "PNG Image Analysis"
        pcommand "Running 'exiftool' for metadata"
        exiftool "$TARGET_FILE"
        pcommand "Running 'binwalk' for embedded files"
        binwalk "$TARGET_FILE"
        pcommand "Checking for LSB steganography with 'zsteg'"
        zsteg "$TARGET_FILE"
        ;;

    *"pcap capture file"*)
        psubheader "Network Capture (PCAP) Analysis"
        pcommand "Running 'capinfos' for file statistics"
        capinfos "$TARGET_FILE"
        pcommand "Displaying protocol hierarchy with 'tshark'"
        tshark -r "$TARGET_FILE" -q -z io,phs
        ;;

    *)
        psubheader "Generic Analysis"
        echo "File type not specifically handled. Running generic commands."
        pcommand "Running 'strings' to find printable characters"
        strings "$TARGET_FILE"
        pcommand "Running 'hexdump' to view the first 256 bytes"
        hexdump -C "$TARGET_FILE" | head -n 16
        ;;
esac

pheader "Investigation Complete"

