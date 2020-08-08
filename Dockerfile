FROM mhart/alpine-node
COPY server.js .
EXPOSE 3333
CMD node server.js
