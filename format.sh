#!/usr/bin/env bash

FILE="mmosga.sh"

echo "Formatting $FILE"
shfmt -w -i 2 "$FILE"
