var fs = require('fs');
var childProcess = require('child_process');
var path = require('path');

exports.handler = function(event, context) {

  // Set the path as described here: https://aws.amazon.com/blogs/compute/running-executables-in-aws-lambda/
  process.env['PATH'] = process.env['PATH'] + ':' + process.env['LAMBDA_TASK_ROOT'];

  // Set the path to the phantomjs binary
  var casperPath = path.join(__dirname, 'node_modules/casperjs/bin/casperjs');

  if (!fs.existsSync(casperPath)) {
    throw new Error('Not able to find "casperjs" executable in "node_modules". Please run `$ npm install` to install the project dependencies.');
  }

  // Arguments for the casper script
  var processArgs = [
    path.join(__dirname, 'balance.js'),
    '--username=' + process.env['USERNAME'],
    '--password=' + process.env['PASSWORD']
  ];

  // Launch the child process
  var ps = childProcess.execFile(casperPath, processArgs, function(error, stdout, stderr) {
    if (error) {
      context.fail(error);
      return;
    }
    if (stderr) {
      context.fail(error);
      return;
    }
    context.succeed(stdout);
  });

  ps.stdout.on('data', function(data) {
    console.log(data);
  });

}
