// without viewportSize, another layout is used and the IBANs are not determined correctly
var casper = require('casper').create({viewportSize: {width: 1280, height: 800}});

var balancesAllAccounts = {};

casper.userAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:56.0) Gecko/20100101 Firefox/56.0');

if (casper.cli.has("verbose")) {
  casper.on('load.finished', function(status) {
    casper.echo(new Date() + " -- load.finished -- " + status, 'INFO');
  });
}

casper.start('https://www.dkb.de/banking');

casper.then(function() {
  if (!(casper.cli.has("username") && casper.cli.has("password"))) {
    casper.die("You're missing --username=xxx and --password=yyy");
  }
});

casper.then(function() {
  this.fill('#login', {
    'j_username': casper.cli.get("username"),
    'j_password': casper.cli.get("password")
  }, true);
});

casper.waitForText("Finanzstatus");

var getBalances = function () {
  var rows = document.querySelectorAll('.financialStatusTable tbody tr:nth-child(odd) td:nth-child(4)');
  return Array.prototype.map.call(rows, function(elem) {
    return elem.textContent.replace(/\s+/g, '');
  });
};
var getIBANs = function () {
  var rows = document.querySelectorAll('.financialStatusTable tbody tr:nth-child(odd) td:nth-child(1) div.iban');
  return Array.prototype.map.call(rows, function(elem) {
    return elem.textContent.replace(/\s+/g, '');
  });
};

casper.then(function() {
  var balances = this.evaluate(getBalances);
  var ibans = this.evaluate(getIBANs);
  // iterate over IBANs because it's the shorter of the 2 arrays
  ibans.forEach(function(iban, index) {
    var parsed_balance = parseFloat(balances[index].replace('.', '').replace(',', '.'));
    balancesAllAccounts[iban] = parsed_balance;
  });
});

casper.then(function() {
  this.clickLabel('Abmelden');
});

casper.then(function () {
  console.log(JSON.stringify({
    event: "bookkeeper:balances:read",
    balances: balancesAllAccounts,
    created_at: new Date()
  }));
});

casper.run();
