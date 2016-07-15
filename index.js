require('coffee-script/register');
module.exports = {
  github: require('./src/github'),
  common: require('./src/common'),
  webhooks: require('./src/webhooks'),
  diffbot: require('./src/diffbot')
};
