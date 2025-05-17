import config from '../../../.vitepress/config';
export default config; 

// Test IPFS CLI
console.log(require('child_process').execSync('ipfs --version').toString());