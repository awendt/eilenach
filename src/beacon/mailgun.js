var querystring = require('querystring');
var https = require('https');

exports.handler = function(event, context) {

  var post_data = querystring.stringify({
    from: `Kontoüberwachung <mailgun@${process.env['MAILGUN_DOMAIN']}>`,
    to: process.env['MAIL_RECIPIENT'],
    subject: JSON.parse(event.Records[0].Sns.Message).AlarmDescription
  });

  var options = {
    auth: 'api:' + process.env['MAILGUN_KEY'],
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(post_data)
    },
    hostname: 'api.mailgun.net',
    port: 443,
    path: `/v3/${process.env['MAILGUN_DOMAIN']}/messages`,
    method: 'POST'
  };

  // Set up the request
  var post_req = https.request(options, function(res) {
    console.log('statusCode:', res.statusCode);
    console.log('headers:', res.headers);

    res.setEncoding('utf8');
    res.on('data', function (d) {
      process.stdout.write(d);
    });
  });

  // post the data
  post_req.write(post_data);
  post_req.end();

}