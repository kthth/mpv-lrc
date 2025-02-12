#!/bin/sh
# are there mpv hooks that can run this script when song changes?
mediafile=$(printf %s\\n '{ "command": ["get_property", "path"] }' | socat - UNIX-CONNECT:/tmp/mpv-socket | jq -r .data) || exit 1
mediadir=$(printf %s\\n '{ "command": ["get_property", "working-directory"] }' | socat - UNIX-CONNECT:/tmp/mpv-socket | jq -r .data) || exit 1

case $mediafile in
  /*) mediapath=$(printf %s "$mediafile" );;
  *) mediapath=$(printf %s/%s "$mediadir" "$mediafile" );;
esac
case $lrc_path in
  */'(unavailable)') exit 1 ;;
esac
lrc_path=${mediapath%.*}.lrc
if [ -e "$lrc_path" ]; then
  exec $EDITOR "$lrc_path"
else
  python3 ~/src/dev/kimono/lrcmaker.py "$mediapath"
  exec $EDITOR + "$lrc_path"
fi

#metadata=$(printf %s\\n '{ "command": ["get_property", "metadata"] }' \
#    | socat - /tmp/mpv-socket | jq .data)
# The keys are lower case in ID3 tags and upper case in Vorbis comments.
#artist=$(printf %s "$metadata" | jq -r 'if has("artist") then .artist else .ARTIST end')
#title=$(printf %s "$metadata" | jq -r 'if has("title") then .title else .TITLE end')
