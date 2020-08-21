# Purpose

This is an attempt to get localhost on macOS working with HTTPS using a reverse proxy. I extracted the important bits from [starterkit-drupal8site](https://github.com/dcycle/starterkit-drupal8site) for:

1. Pulling and building a Docker image locally from jwilder/nginx-proxy
1. Runing a container from the image that mounts a volume for a localhost cert
1. Adding a localhost cert to the container

I used the Node.js sample app from [this blog post](https://dev.to/destrodevshow/docker-201-use-nginx-as-a-proxy-for-nodejs-server-in-2020-practical-guide-57ji).

After I'm done I should be able to get a 200 status code by navigating to https://https-reverse-proxy.local.

# Progress

- [x] Add hard coded localhost domain to my macOS `host` file with:
```
sudo vim /etc/host
```
and then append this to the bottom of the file:
```
127.0.0.1 https-reverse-proxy.local
```

- [x] Build and run a container
- [ ] Get a 200 status code with
```
curl -I --insecure "https://https-reverse-proxy.local"
```
This is currently failing with a 502 bad gateway error. I am suspicous that this is related to how I have the port bindings configured.

I also found this issue https://github.com/nginx-proxy/nginx-proxy/issues/1476 (open at the time of this writing) that describes what's happening for me, but even disabling the `http2` isn't working.

What am I doing wrong?
