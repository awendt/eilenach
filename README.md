# Eilenach

> Eilenach is one of the seven [Warning beacons of Gondor](http://lotr.wikia.com/wiki/Warning_beacons_of_Gondor).

This is a watcher for our family account balance.

<details>
<summary>How does it work?</summary>

1. [Checks the balance](src/bookkeeper/bookkeeper.py) of your bank account over [FinTS](https://en.wikipedia.org/wiki/FinTS)
2. Reports the balance
3. [Sends an e-mail](src/beacon/mailgun.js) when the balance is below threshold

</details>

<details>
<summary>What do I need to run this?</summary>

- a German bank account with [one of these banks](https://github.com/raphaelm/python-fints#limitations) (so far only tested with DKB)
- an AWS account (everything you need to build the infrastructure
  is [included in this project](infrastructure/bookkeeper.tf))
- a [Mailgun account](https://www.mailgun.com/)

</details>

<details>
<summary>Wait, did you say AWS? What are the operating costs for this?</summary>

💰 The whole project fits into the Free Tier, so **operating costs are likely to be zero.**

In case you already consumed all of your Free Tier,
estimated operating costs per month are:

| AWS Service          | Free Tier | This project | Best case | Worst case |
|----------------------|-----------|--------------|----------:|-----------:|
| Lambda (requests)    | 1M        | ~4,320       | $0     | $0.00 |
| Lambda (duration)    | 3.2M secs | ~22,000 secs | $0     | $0.05 |
| CloudWatch (alarms)  | 10        | 2            | $0     | $0.20 |
| CloudWatch (metrics) | 10        | 1            | $0     | $0.30 |
| SNS (publishes)      | 1M        | <4,320       | $0     | $0.01 |
| SNS (HTTP deliveries)| 100,000   | <4,320       | $0     | $0.01 |
| **Sum**     ||| **$0** | **$0.57** |

</details>

## Getting started

### Prerequisites

This is the software you need:

1. GNU Make
2. [Terraform](https://www.terraform.io/) 0.10.3 or newer
3. A working [Python 3](https://www.python.org/) environment (including `pip`)
4. [ZIP](http://www.info-zip.org/Zip.html)

<details>
<summary>How do I know I have everything installed?</summary>

Run the following, every line should have a check mark:

```bash
$ make check
✔ pip3
✔ terraform
✔ zip
```
</details>

<details>
<summary>What's the recommended way to install the requirements on OSX?</summary>

Assuming you have [brew](https://github.com/Homebrew/brew)
installed (you should!), run this to install all required software:

```
brew bundle
```
</details>

### Building the project

Once you have all required software, in the root directory of this project, run:

```bash
$ make
```

This will create 2 ZIP files but fail on the infrastructure part (keep reading).

#### Building the infrastructure

This requires some first-time setup.

1. [Initialize terraform](https://www.terraform.io/docs/commands/init.html) for this project to download dependencies:
   ```bash
   $ cd infrastructure
   $ terraform init
   ```
2. Create a new file `terraform.tfvars` and populate all variables declared in [`variables.tf`](infrastructure/variables.tf) like this:
   ```INI
   banking_blz = "Your bank code"
   banking_username = "The username you use for banking"
   banking_pin = "The password you use for banking (not your card PIN!)"
   banking_endpoint = "The PIN/TAN URL for your bank as found on http://www.hbci-zka.de/institute/institut_auswahl.htm"
   shared_account_number = "The account number for which you'd like to monitor the balance"
   mailgun_key = "You API Key for Mailgun, find it on your dashboard"
   mailgun_domain = "The domain you set up (can be a sandbox domain)"
   mail_recipient = "E-mail address you'd like to send notifications to"
   ```
3. It is recommended to set up a [named profile for your AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html)
   to avoid credential configuration in this project.
4. Choose a [region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) for your infrastructure and create a file `aws.tf`:
   ```HCL
   provider "aws" {
     region = "eu-central-1" # your prefered AWS region
     profile = "name of the AWS profile you created"
   }
   ```
5. This should be enough to get a plan to add a number of resources:
   ```bash
   $ terraform plan
   [long output]
   Plan: [n] to add, 0 to change, 0 to destroy.
   ```
6. Build the infrastructure:
   ```bash
   $ make
   ```
   - Terraform will then create a [state file](https://www.terraform.io/docs/backends/state.html) (`terraform.tfstate`) in the project directory
   - You can [destroy](https://www.terraform.io/intro/getting-started/destroy.html)
   the infrastructure whenever you want
   - You can also run `make` on the top-level directory now
7. **(optional)** If you're up for a more permanent solution,
   consider switching to remote state, e.g. where your state file is stored in
   [S3](https://www.terraform.io/docs/backends/types/s3.html).

#### Building the other components

The build process creates a number of AWS resources and 2 Lambda functions:

<details>
<summary>bookkeeper</summary>

This part is written in Python because
[python-fints](https://github.com/raphaelm/python-fints) is the only
decent FinTS library out there that I could get running.

Its job is to query the account balance and report it to stdout in JSON format
where it's being picked up a metric filter and sent to CloudWatch Metrics.

</details>

<details>
<summary>beacon</summary>

This part is written in Javascript because it's my goto language for AWS Lambda.

It sends an e-mail, and it is by far the simplest component (it has no dependencies).
That's also why NodeJS is not listed anywhere as dependency. If you want to hack on it,
you need a working Node environment though.

I hadn't planned to write this part but Amazon SNS
[doesn't yet support SMS in my prefered region](https://docs.aws.amazon.com/sns/latest/dg/sms_supported-countries.html), and Terraform doesn't support the `email` protocol for
subscribing to SNS topics.

The upside is that I can control the subject and the body of the e-mail being sent.

</details>

---

The top-level `Makefile` will pick up any changes you make and re-package the code
but you can run `make` in any of them by yourself.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details