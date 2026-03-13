const http = require("http");

const PORT = process.env.PORT || 3000;
const APP_NAME = process.env.APP_NAME || "DevOps Test App";
const VERSION = process.env.VERSION || "1_prod";

const server = http.createServer((req, res) => {
  if (req.url === "/") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end(`${APP_NAME} Running | Version: ${VERSION}\n`);
    return;
  }

  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        status: "ok",
        version: VERSION,
        time: new Date(),
      })
    );
    return;
  }

  if (req.url === "/info") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        app: APP_NAME,
        version: VERSION,
        port: PORT,
        env: process.env.NODE_ENV || "dev",
      })
    );
    return;
  }

  res.writeHead(404);
  res.end("Not Found");
});

server.listen(PORT, () => {
  console.log(`🚀 ${APP_NAME} running on ${PORT}`);
  console.log(`Version: ${VERSION}`);
});