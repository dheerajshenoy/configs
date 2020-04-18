ARTIST=$(spotify-now -i "%artist")
SONG=$(spotify-now -i "%title")
get=$(lyrics $ARTIST "$SONG")
echo $ARTIST,$SONG 
