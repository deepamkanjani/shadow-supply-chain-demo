const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem'),
};

https.createServer(options, (req, res) => {
  let data = '';
  req.on('data', chunk => data += chunk);
  req.on('end', () => {
    console.log('[Captured Exfil]', data);
    res.writeHead(200);
    res.end('received');
  });
}).listen(3000, () => {
  console.log('🔐 Exfil server running on https://localhost:3000');
});