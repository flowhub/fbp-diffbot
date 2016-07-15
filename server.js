require('coffee-script/register');
var web = require('./web/app');
web.start({}, function (err, app, port) {
  if (err) {
    throw err;
    process.exit(1);
  }
  console.log('fbp-diffbot server running on port', port);
});
