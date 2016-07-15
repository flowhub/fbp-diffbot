require('coffee-script/register');
module.exports = {
  github: require('./src/github'),
  common: require('./src/common'),
  diffbot: require('./src/diffbot')
};
