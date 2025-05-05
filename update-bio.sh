. ./login.sh

playerctl metadata --player cantata --follow --format "{{artist}} - {{album}}" |
tcc -run debounce.c |
sed -u 's%/ Covered.*%(cover)%' |
while read -r song; do

echo "$song"

bio=$(jq -n --arg song "$song" \
'"https://rinici.de

\($song)"')

err=$(curl -sG https://bsky.social/xrpc/com.atproto.repo.getRecord \
  -H "Authorization: $auth" \
  -d repo=$IDENTIFIER -d collection=app.bsky.actor.profile -d rkey=self |
  jq '{ "repo": env.IDENTIFIER
      , "collection": "app.bsky.actor.profile"
      , "rkey": "self"
      , "record": (.value | .description = '"$bio"')
      , "swapRecord": .cid
      }' |
  curl -s https://bsky.social/xrpc/com.atproto.repo.putRecord \
  -H "Authorization: $auth" --json @- |
  jq -r '.error')

if [ "$err" = "InvalidToken" ] || [ "$err" = "ExpiredToken" ]; then
  . ./refresh.sh
fi

[ "$err" != "null" ] && echo "$err"

done
