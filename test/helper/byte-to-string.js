// Convert byte to 0x prefixed hex string
const byteToString = b => '0x' + b.toString('hex');

module.exports = {byteToString};