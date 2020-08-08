# extracted from https://github.com/dcycle/starterkit-drupal8site
# https://dev.to/destrodevshow/docker-201-use-nginx-as-a-proxy-for-nodejs-server-in-2020-practical-guide-57ji
APP_NAME=https-reverse-proxy
# requires this to be saved in a host file too for localhost
VIRTUAL_HOST=$APP_NAME.local
PORT=80
CERTSDIR="$HOME/.docker-compose-certs"

docker build -t $APP_NAME .
docker run -d -e VIRTUAL_HOST=$VIRTUAL_HOST -e VIRTUAL_PROTO=https --name=node-server $APP_NAME

echo '---STARTING NGINX REVERSE PROXY---'
echo 'First check if the reverse proxy is running'
docker container ls -f 'name=/nginx-proxy' | grep nginx-proxy && RUNNING=1 || RUNNING=0
if [ "$RUNNING" == 0 ]; then
  echo 'nginx-proxy is not running'
  echo 'checking if nginx-proxy exists'
  docker container ls -a -f 'name=/nginx-proxy' | grep nginx-proxy && EXISTS=1 || EXISTS=0
  if [ "$EXISTS" == 0 ]; then
    docker run -d -p $PORT:80 -p 443:443 \
      --name nginx-proxy \
      -v "$HOME"/.docker-compose-certs:/etc/nginx/certs:ro \
      -v /etc/nginx/vhost.d \
      -v /usr/share/nginx/html \
      -v /var/run/docker.sock:/tmp/docker.sock:ro \
      -e HTTPS_METHOD=nohttp \
      jwilder/nginx-proxy
  else
    echo 'nginx-proxy exists but is not running; start it'
    docker start nginx-proxy
  fi
else
  echo 'nginx-proxy is running'
fi
echo ''

echo "Certs directory is $CERTSDIR"
ls "$CERTSDIR/$VIRTUAL_HOST.crt" 2>/dev/null && CERTEXISTS=1 || CERTEXISTS=0
if [ "$CERTEXISTS" == 0 ]; then
  echo "$CERTSDIR/$VIRTUAL_HOST.crt does not exist, will attempt to create it"
  docker run -v "$CERTSDIR:/certs"  jwilder/nginx-proxy /bin/bash -c "cd /certs && openssl req -x509 -out $VIRTUAL_HOST.crt -keyout $VIRTUAL_HOST.key -newkey rsa:2048 -nodes -sha256 -subj '/CN=localhost' -extensions EXT -config <(printf "'"'"[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$VIRTUAL_HOST\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth"'"'")"
else
  echo "$CERTSDIR/$VIRTUAL_HOST.crt exists"
fi

echo "Restarting nginx-proxy"
docker restart nginx-proxy
echo ''
echo '---ACCESSING YOUR APPLICATION ON PORT 443---'
echo "Your application should be accessible on https://$VIRTUAL_HOST"
curl -I --insecure "https://$VIRTUAL_HOST"
