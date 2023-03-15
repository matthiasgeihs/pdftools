#!/usr/bin/env zsh

FN=$1
PADDING_X=10
PADDING_Y=10

# Determine bounding box
MINMAX_AWK='{
if (NR==1) {left = $1; bottom = $2; right=$3; top=$4;}
else {
if ($1 < left) left = $1;
if ($2 < bottom) bottom = $2;
if ($3 > right) right = $3;
if ($4 > top) top = $4;
}}
END {print left, bottom, right, top}'
BBOX=(`gs -q -dBATCH -dNOPAUSE -sDEVICE=bbox $FN 2>&1 | grep -v HiResBoundingBox | sed 's/.*: *//' | awk "$MINMAX_AWK"`)
# BBOX=(left bottom right top)

# Compute offset and new size
OFFSET_X=`expr $BBOX[1] - $PADDING_X`
OFFSET_Y=`expr $BBOX[2] - $PADDING_Y`
NEW_WIDTH=`expr "(" $BBOX[3] - $OFFSET_X + $PADDING_X ")" "*" 10`
NEW_HEIGHT=`expr "(" $BBOX[4] - $OFFSET_Y + $PADDING_Y ")" "*" 10`


# Crop PDF
gs \
  -o cropped.pdf \
  -sDEVICE=pdfwrite \
  -g"$NEW_WIDTH"x"$NEW_HEIGHT" \
  -c "<</PageOffset [-$OFFSET_X -$OFFSET_Y]>> setpagedevice" \
  -f input.pdf
