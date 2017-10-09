#/bin/bash

IN_FILE=$1
if [ -z "$IN_FILE" ]; then
    IN_FILE="assignment-4.md"
fi

OUT_FILE=$(mktemp)
mv "$OUT_FILE" "$OUT_FILE.pdf"
OUT_FILE="$OUT_FILE.pdf"

pandoc "$IN_FILE" -o "$OUT_FILE" \
    --variable="linestretch=1.5" \
    --variable="margin-left=2cm" \
    --variable="margin-right=2cm" \
    --variable="margin-top=2cm" \
    --variable="margin-bottom=2cm"
open "$OUT_FILE"
sleep 1
rm "$OUT_FILE"
