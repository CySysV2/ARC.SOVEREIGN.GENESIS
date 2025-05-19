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