const crypto = require('crypto');

const sha256 = x =>
  crypto
    .createHash('sha256')
    .update(x)
    .digest();

const isSha256Hash = hashStr => /^0x[0-9a-f]{64}$/i.test(hashStr);

module.exports = {sha256, isSha256Hash};