// A normal app. It uses axios for one HTTP request.
// It does NOT mention plain-crypto-js anywhere.
// It does NOT import plain-crypto-js.
// Yet plain-crypto-js will end up in node_modules,
// and its postinstall hook will run.

const axios = require('axios');

console.log('my-app starting...');
console.log('axios version:', axios.VERSION || 'unknown');
console.log('Done. (No HTTP calls made in this demo.)');
