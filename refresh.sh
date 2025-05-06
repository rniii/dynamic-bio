echo "refreshing session"

auth="Bearer $(jq -r .refreshJwt session.json)"

sess=$(curl -sX POST -H "Authorization: $auth" https://bsky.social/xrpc/com.atproto.server.refreshSession)
err=$(echo "$sess" | jq .error)

if [ "$err" = "null" ]; then
  echo "$sess" | jq '{ accessJwt, refreshJwt }' > session.json
  auth=$(echo "$sess" | jq .accessJwt)
else
  echo "invalid session: $sess"
  . ./login.sh
fi

export auth
