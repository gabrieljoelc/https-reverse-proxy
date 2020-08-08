// https://dev.to/destrodevshow/docker-201-use-nginx-as-a-proxy-for-nodejs-server-in-2020-practical-guide-57ji
var http = require('http');

var server = http.createServer(function (request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.end("Node & Docker Running...");
});

server.listen(3333);

console.log("Node HTTP Server started at http://localhost:3333/");
