# Eilenach

> Eilenach is one of the seven [Warning beacons of Gondor](http://lotr.wikia.com/wiki/Warning_beacons_of_Gondor).

## What this does

This is a watcher for our family account balance:

1. Checks the balance by [scraping our bank's website](src/bookkeeper/balance.js)
2. Reports the balance
3. [Sends an e-mail](src/beacon/mailgun.js) when the balance is below threshold

Almost all of this runs on AWS (sending an e-mail is done via Mailgun, though).

**WARNING:** There's a _lot_ of assumptions here, and no tests!

## Build

I chose `make` to keep it all together. You'll need:

1. GNU Make
2. [Terraform](https://www.terraform.io/)
3. [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
4. wget

### Building beacon

This is the part that sends an e-mail (by far the simplest component).

1. Zips [`mailgun.js`](src/beacon/mailgun.js) — done.

### Building bookkeeper

This is [slightly more complicated](src/bookkeeper/Makefile).

1. Installs Javascript dependencies (mainly, CasperJS for now)
2. Downloads PhantomJS (pre-2.0 because I couldn't get them running on Lambda)
3. Zips all of it

### Building the infrastructure

This needs you to set up some configuration.

1. Create a new file `terraform.tfvars` and populate all variables declared in [`variables.tf`](infrastructure/variables.tf) like this:
   ```
   variable = "value"
   ```
2. Run `make` with `AWS_PROFILE` set (see [AWS docs for named profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html) for more info)

# Future plans

I'd like to switch this from scraping the website to e.g. [FinTS](https://github.com/jschyma/open_fints_js_client)
