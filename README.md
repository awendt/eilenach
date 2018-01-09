# Eilenach

> Eilenach is one of the seven [Warning beacons of Gondor](http://lotr.wikia.com/wiki/Warning_beacons_of_Gondor).

## What this does

This is a watcher for our family account balance:

1. [Checks the balance](src/bookkeeper/bookkeeper.py) of your bank account over [FinTS](https://en.wikipedia.org/wiki/FinTS)
2. Reports the balance
3. [Sends an e-mail](src/beacon/mailgun.js) when the balance is below threshold

Almost all of this runs on AWS, the code necessary to build the infrastructure
is [here](infrastructure/bookkeeper.tf).

**WARNING:** There's a _lot_ of assumptions here, and no tests!

This is [supposed to work](https://github.com/raphaelm/python-fints#limitations)
with several German banks, but so far I've only verified this with DKB.

## Building the project

I chose `make` to keep it all together. You'll need:

1. GNU Make
2. [Terraform](https://www.terraform.io/)
3. A working [Python 3](https://www.python.org/) environment (including `pip`)
4. wget

### Building beacon

This is the part that sends an e-mail (by far the simplest component, it has no dependencies).

1. Zips [`mailgun.js`](src/beacon/mailgun.js) — done.

### Building bookkeeper

This is [slightly more complicated](src/bookkeeper/Makefile).

1. Installs dependencies
2. Zips all of it

Why Python? Because [python-fints](https://github.com/raphaelm/python-fints) is the only
decent FinTS library out there that I could get running.

### Building the infrastructure

This needs you to set up some configuration.

1. Create a new file `terraform.tfvars` and populate all variables declared in [`variables.tf`](infrastructure/variables.tf) like this:
   ```
   variable = "value"
   ```
2. Run `make` with `AWS_PROFILE` set (see [AWS docs for named profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html) for more info)
