#!/bin/sh

template="$(readlink -f "$0" | xargs dirname)/template/gnuplot.js"

mv "$1" "${1}.blk"

grep //{{output.js}} -B 999 "$template" > "$1"
sed 's/document.currentScript/currentScript/g' "${1}.blk" >> "$1"
grep //{{output.js}} -A 999 "$template" >> "$1" 