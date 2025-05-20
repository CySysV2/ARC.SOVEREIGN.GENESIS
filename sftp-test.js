import Client from 'ssh2-sftp-client';
import fs from 'fs';

const sftp = new Client();

const sftpConfig = {
  host: '198.58.109.140',
  port: 19199,
  username: 'renewabl',
  privateKey: fs.readFileSync('C:/ssh/dude-laptop'),
  passphrase: 'f0rdude+!',
};

sftp.connect(sftpConfig)
  .then(() => {
    console.log('SFTP connection successful!');
    return sftp.end();
  })
  .catch(err => {
    console.error('SFTP connection failed:', err.message);
  });

if (process.argv.includes('--ls-remote')) {
  const dir = process.argv[process.argv.length - 1];
  sftp.readdir(dir, (err, list) => {
    if (err) {
      console.error(`Error listing remote directory ${dir}:`, err.message);
      process.exit(1);
    }
    if (!list || list.length === 0) {
      console.log(`Remote directory ${dir} is empty or does not exist.`);
    } else {
      console.log(`Contents of remote directory ${dir}:`);
      list.forEach(f => console.log(f.filename));
    }
    sftp.end();
  });
} 