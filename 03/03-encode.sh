#!/bin/sh

# renumber so the encoders are not confused.
t=0
for s in snap-03.*.jpg
do \
  mv $s `printf snap-movie.%05d.jpg $t`
  t=`expr $t + 1`
done

# encode using ffmpeg
rm -f movie-03.mp4
ffmpeg -r 25 -b 2400k -i snap-movie.%05d.jpg movie-03.mp4 \
  && rm -f snap-movie*.jpg
