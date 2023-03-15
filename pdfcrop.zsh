# Determine bounding box
PROG='{
if (NR==1) {left = $1; bottom = $2; right=$3; top=$4;}
else {
if ($1 < left) left = $1;
if ($2 < bottom) bottom = $2;
if ($3 > right) right = $3;
if ($4 > top) top = $4;
}}
END {print left, bottom, right, top}'
BBOX=(`gs -q -dBATCH -dNOPAUSE -sDEVICE=bbox input.pdf 2>&1 | grep -v HiResBoundingBox | sed 's/.*: *//' | awk "$PROG"`)

# e.g. BBOX=(73 139 540 697)


# Extract width and height
# WIDTH=`mdls input.pdf | grep kMDItemPageWidth | sed 's/.*= *//'`
# HEIGHT=`mdls input.pdf | grep kMDItemPageHeight | sed 's/.*= *//'`

# e.g. WIDTH=612 HEIGHT=792

# Compute margins
# MARGIN_LEFT=$BBOX[1]
# MARGIN_RIGHT=`expr $WIDTH - $BBOX[3]`
# MARGIN_BOTTOM=$BBOX[2]
# MARGIN_TOP=`expr $HEIGHT - $BBOX[4]`

# Compute new size
# PADDING_X=10
# PADDING_Y=10
# OFFSET_X=`expr $MARGIN_LEFT - $PADDING_X`
# OFFSET_Y=`expr $MARGIN_BOTTOM - $PADDING_Y`
# NEW_WIDTH=`expr "(" $WIDTH - $OFFSET_X - $MARGIN_RIGHT + $PADDING_X ")" "*" 10`
# NEW_HEIGHT=`expr "(" $HEIGHT - $OFFSET_Y - $MARGIN_TOP + $PADDING_Y ")" "*" 10`

PADDING_X=10
PADDING_Y=10
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
