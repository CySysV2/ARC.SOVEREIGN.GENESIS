// Usage:
// node deploy.js [--site <site>] [--all] [--dry-run] [--log <logfile>]
//
// --site <site>   Deploy only the specified site (e.g., digital-fabrica, blog, civic, etc.)
// --all           Deploy all configured sites (default)
// --dry-run       Show what would be uploaded, but do not actually upload
// --log <logfile> Log output to the specified file

import Client from 'ssh2-sftp-client';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const config = [
  {
    name: 'digital-fabrica',
    local: path.join(__dirname, 'web-projects/digital-fabrica.com/src/pages/.vitepress/dist'),
    remote: '/home3/renewabl/digital-fabrica.com',
  },
  {
    name: 'ip',
    local: path.join(__dirname, 'sites/ip.digital-fabrica.com/.vitepress/dist'),
    remote: '/home/renewabl/ip.digital-fabrica.com',
  },
  {
    name: 'qic',
    local: path.join(__dirname, 'sites/qic.digital-fabrica.com/.vitepress/dist'),
    remote: '/home/renewabl/qic.digital-fabrica.com',
  },
  {
    name: 'civic',
    local: path.join(__dirname, 'sites/civic/.vitepress/dist'),
    remote: '/home/renewabl/civic.digital-fabrica.com',
  },
  {
    name: 'fabrics',
    local: path.join(__dirname, 'sites/fabrics/.vitepress/dist'),
    remote: '/home/renewabl/fabrics.digital-fabrica.com',
  },
  {
    name: 'blog',
    local: path.join(__dirname, 'sites/blog/.vitepress/dist'),
    remote: '/home/renewabl/blog.digital-fabrica.com',
  },
  {
    name: 'whitepaper',
    local: path.join(__dirname, 'sites/whitepaper/.vitepress/dist'),
    remote: '/home/renewabl/whitepaper.digital-fabrica.com',
  },
  {
    name: 'blog-api',
    local: path.join(__dirname, 'blog.digital-fabrica.com/api'),
    remote: '/home3/renewabl/blog.digital-fabrica.com/api',
  },
  {
    name: 'civic-api',
    local: path.join(__dirname, 'civic.digital-fabrica.com/api'),
    remote: '/home3/renewabl/civic.digital-fabrica.com/api',
  },
  {
    name: 'fabrics-api',
    local: path.join(__dirname, 'fabrics.digital-fabrica.com/api'),
    remote: '/home3/renewabl/fabrics.digital-fabrica.com/api',
  },
  {
    name: 'ip-api',
    local: path.join(__dirname, 'ip.digital-fabrica.com/api'),
    remote: '/home3/renewabl/ip.digital-fabrica.com/api',
  },
  {
    name: 'qic-api',
    local: path.join(__dirname, 'qic.digital-fabrica.com/api'),
    remote: '/home3/renewabl/qic.digital-fabrica.com/api',
  },
  {
    name: 'whitepaper-api',
    local: path.join(__dirname, 'whitepaper.digital-fabrica.com/api'),
    remote: '/home3/renewabl/whitepaper.digital-fabrica.com/api',
  },
  {
    name: 'monad-api',
    local: path.join(__dirname, 'monad.digital-fabrica.com/api'),
    remote: '/home3/renewabl/monad.digital-fabrica.com/api',
  },
  {
    name: 'tc-api',
    local: path.join(__dirname, 'tc.digital-fabrica.com/api'),
    remote: '/home3/renewabl/tc.digital-fabrica.com/api',
  },
  {
    name: 'ikl-api',
    local: path.join(__dirname, 'ikl.digital-fabrica.com/api'),
    remote: '/home3/renewabl/ikl.digital-fabrica.com/api',
  },
];

const sftpConfig = {
  host: '198.58.109.140',
  port: 19199,
  username: 'renewabl',
  privateKey: fs.readFileSync('C:/ssh/dude-laptop'),
  passphrase: 'f0rdude+!',
};

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { all: false, dryRun: false, log: null, site: null };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--all') opts.all = true;
    else if (args[i] === '--dry-run') opts.dryRun = true;
    else if (args[i] === '--log') opts.log = args[++i];
    else if (args[i] === '--site') opts.site = args[++i];
  }
  if (!opts.site && !opts.all) opts.all = true;
  return opts;
}

function logMsg(msg, logStream) {
  console.log(msg);
  if (logStream) logStream.write(msg + '\n');
}

async function uploadDir(sftp, localDir, remoteDir, dryRun, logStream) {
  // Ensure remote directory exists
  try {
    if (!dryRun) {
      await sftp.mkdir(remoteDir, true);
      logMsg(`Ensured remote directory exists: ${remoteDir}`, logStream);
    }
  } catch (e) {
    logMsg(`Error ensuring remote dir: ${remoteDir} - ${e.message}`, logStream);
  }
  logMsg(`Uploading directory: ${localDir} -> ${remoteDir}`, logStream);
  const files = fs.readdirSync(localDir);
  for (const file of files) {
    const localPath = path.join(localDir, file);
    const remotePath = remoteDir + '/' + file;
    if (fs.lstatSync(localPath).isDirectory()) {
      await uploadDir(sftp, localPath, remotePath, dryRun, logStream);
    } else {
      logMsg(`${dryRun ? '[DRY RUN] ' : ''}Uploading file: ${localPath} -> ${remotePath}`, logStream);
      if (!dryRun) {
        try {
          await sftp.fastPut(localPath, remotePath);
        } catch (e) {
          logMsg(`Error uploading file: ${localPath} -> ${remotePath} - ${e.message}`, logStream);
        }
      }
    }
  }
}

async function main() {
  const opts = parseArgs();
  const logStream = opts.log ? fs.createWriteStream(opts.log, { flags: 'a' }) : null;
  const targets = opts.all ? config : config.filter(c => c.name === opts.site);
  if (targets.length === 0) {
    logMsg('No matching site found for deployment.', logStream);
    process.exit(1);
  }
  const sftp = new Client();
  if (!opts.dryRun) await sftp.connect(sftpConfig);
  for (const { name, local, remote } of targets) {
    logMsg(`\n--- Deploying ${name} ---`, logStream);
    await uploadDir(sftp, local, remote, opts.dryRun, logStream);
  }
  if (!opts.dryRun) await sftp.end();
  logMsg('Deployment complete.', logStream);
  if (logStream) logStream.end();
}

main().catch(console.error); 