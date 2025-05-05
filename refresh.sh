echo "refreshing session"

auth="Bearer $(jq -r .refreshJwt session.json)"

curl -s https://bsky.social/xrpc/com.atproto.server.refreshSession \
  -H "Authorization: $auth" |
  jq '{ accessJwt, refreshJwt }' > session.json

[ "$(jq .accessJwt session.json)" = "null" ] && {
  echo "invalid session"
  rm session.json
}
