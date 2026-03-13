const http = require("http");

const server = http.createServer((req, res) => {
  res.end("DevOps Test App Running");
});

server.listen(3000, () => {
  console.log("Running on 3000");
});