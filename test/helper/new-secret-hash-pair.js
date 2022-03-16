const {sha256} = require("./sha256");
const {byteToString} = require("./byte-to-string");

// Create a new secret-hash pair object.
// Secret value defaults to bytes32.
const newSecretHashPair = () => {
  const secret = crypto.randomBytes(32);
  const hash = sha256(secret)
  return {
    secret: byteToString(secret),
    hash: byteToString(hash),
  };
}

module.exports = {newSecretHashPair};