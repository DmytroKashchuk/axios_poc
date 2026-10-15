// setup.js - simulated payload (HARMLESS)
// In the real attack, this script downloaded a RAT from sfrclak[.]com:8000
// Here we just write a marker file to prove the postinstall hook ran.

const fs = require('fs');
const os = require('os');
const path = require('path');

const marker = path.join(os.tmpdir(), 'pwned.txt');

const evidence = [
  '=== POSTINSTALL HOOK EXECUTED ===',
  'time:     ' + new Date().toISOString(),
  'package:  plain-crypto-js@4.2.1',
  'platform: ' + os.platform(),
  'user:     ' + os.userInfo().username,
  'cwd:      ' + process.cwd(),
  'parent:   ' + (process.env.npm_package_name || 'unknown'),
  '',
  'In a real attack this script would:',
  '  - contact a C2 server',
  '  - download a platform-specific RAT',
  '  - establish persistence',
  '',
  'This is a controlled replication. No harm done.',
  ''
].join('\n');

fs.writeFileSync(marker, evidence);

console.log('[plain-crypto-js postinstall] wrote evidence to', marker);
