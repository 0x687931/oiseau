#!/usr/bin/env bash

# Test if fold breaks emoji

text="📁 file.txt"

echo "Original: '$text'"
echo "Length: ${#text}"

echo ""
echo "After fold -s -w 54:"
folded=$(echo "$text" | fold -s -w 54)
echo "'$folded'"
echo "Length: ${#folded}"

echo ""
echo "Byte by byte:"
echo "$text" | od -An -tx1