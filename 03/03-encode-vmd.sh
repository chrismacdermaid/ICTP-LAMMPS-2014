#!/bin/sh

# renumber so the encoders are not confused.
t=0
for s in snap-03.*.tga
do \
  mv $s `printf snap-movie.%05d.tga $t`
  t=`expr $t + 1`
done

# encode using ffmpeg
echo "Encoding...."
rm -f movie-03.mp4
ffmpeg -i snap-movie.%05d.tga movie-03.mp4 \
  && rm -f snap-movie*.tga
