. ./.env

[ -f session.json ] || {
  echo "creating session"

  jq -n '{ identifier: env.IDENTIFIER, password: env.APP_PASSWORD }' |
  curl -s https://bsky.social/xrpc/com.atproto.server.createSession --json @- |
  jq '{ accessJwt, refreshJwt }' > session.json
}

auth="Bearer $(jq -r .accessJwt session.json)"

export auth
