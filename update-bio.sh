. ./login.sh

playerctl metadata --player cantata --follow --format "{{artist}} - {{album}}" |
tcc -run debounce.c |
sed -u 's%/ Cover.*%(cover)%' |
while read -r song; do

echo "$song"

bio=$(jq -n --arg song "$song" \
'"denpa girl ~ https://rinici.de

\($song)
https://www.last.fm/user/rnii"')

req=$(curl -sG -H "Authorization: $auth" $XRPC/com.atproto.repo.getRecord \
  -d"repo=$IDENTIFIER" -d"collection=app.bsky.actor.profile" -d"rkey=self" |
  jq '{ "repo": env.IDENTIFIER
      , "collection": "app.bsky.actor.profile"
      , "rkey": "self"
      , "record": (.value | .description = '"$bio"')
      , "swapRecord": .cid
      }')

while
  res=$(! curl --fail-with-body -sH "Authorization: $auth" $XRPC/com.atproto.repo.putRecord --json "$req")
do
  err=$(echo "$res" | jq .error)

  if [ "$err" = "InvalidToken" ] || [ "$err" = "ExpiredToken" ]; then
    . ./refresh.sh
  elif [ "$err" != "null" ]; then
    echo "error: $err"
    break
  fi
done

done
