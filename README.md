Minecraft Server In The Cloud
=============================

This is a fully provisinable minecraft server on a configurable EC2 instance under AWS. This Gem
provides the ability to manage both, an EC2 instance and a Minecraft server which is executed on
that EC2 instance.

# Reasons

I have a fully operational minecraft server at home running on my laptop. My problem was, that
I don't have the infrastructure or the processing power, neither the networking capabilities to host
a server which can handle more than 2 people. All the other solutions out there, costed a lot of
money and investment.

All I needed was a good enough server for at least 5-6 hours / week. This is a rough estimate.
With this kind of usage, my cost, with an t2.large EC2 instance would be around ~3-5 USD / month!
This is a price none of the services currently providing could beat any time soon. A t2.large can
handle a fair amount of people without breaking a sweat. I can shut it down, and start it up again
at any given time. If I'm not using it for a week, it just sits there, and will not incur any costs.
This is again, something that no competitors would be able to match.

The only thing that competitors are matching is maybe ease of usage. And hence, the reason for this
Gem. This CLI ruby gem, will make it so that it's easy, and straightforward to manage an instance
from the command line and to manage a minecraft server from the command line as well. And here is
how you do that.

# Setup

## AWS

In order for this to work, you'll have to set up an AWS account, which you can do here:[AWS Account Creation](Create Account - Amazon Web Services).
Once that is done, you will need to save your api creds. After that, you'll need to set up the CLI
tool of AWS in order for your environment to be correctly configured for this Gem's CLI tool. To
do that, run through this document: [AWS CLI Setup Runbook](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

TL;DR; => Run `aws configure` and enter your `AWS Access Key ID`, `AWS Secret Access Key`, and default
`region` to use. The region should be a place near you so latency won't be an issue. If you are using
multiple profiles, please set the environment property accordingly `export AWS_DEFAULT_PROFILE=user2`.

Test your CLI by running an AWS command like this one: `aws ec2 describe-instances --output table --region us-east-1`.

## AWS Minecraft

### Instance

The instance configuration that is used can be found here: [ec2_config](cfg/ec2_config.json). This
will configure and create an EC2 instance for you. Couple of things to note here. The instance uses
an ssh key import which is than used to execute commands on the instance. So in order for this to work
you'll have to create an SSH key with `ssh-keygen`. Enter your **PUBLIC** key, something like `/Users/youruser/.ssh/ida_rsa.pub`,
into the file called `minecraft.key` as a *base64* encoded string.

AWS Minecraft uses tmux to run a minecraft server in the background. The tmux is a multiplexer client
and will allow us to attach to it later on, if the user would like to run some commands on the server.

All this is pre installed on the starting server by this script: [user_data](cfg/user_data.sh).

### AWS Minecraft

AWS Minecraft uses a sqlite3 database to store some information about the instance that the user just
created. This is so, that it's readily available should any query occur so as to not continuously
query amazon for information about the instance.

The [config.yml](cfg/config.yml) file configures this gem. Currently, two settings are available. A
Logger level setting information which can be overridden any time. And second, it's the location from
where files will be uploaded to the instance like, minecraft.jar or craftbukkit.jar. These than will
be executed during starting a minecraft server.

# Usage


The following commands are available from the CLI tool:
```
Commands:
  aws_minecraft.rb attach-to-server    # Attach to a minecraft server.
  aws_minecraft.rb create-instance     # Creates an EC2 instance.
  aws_minecraft.rb help [COMMAND]      # Describe available commands or one specific command
  aws_minecraft.rb init-db             # Initialize the databse.
  aws_minecraft.rb ssh                 # SSH into a running EC2 instance.
  aws_minecraft.rb start-instance      # Starts an EC2 instance.
  aws_minecraft.rb start-server NAME   # Starts a minecraft server.
  aws_minecraft.rb stop-instance       # Stops an EC2 instance.
  aws_minecraft.rb stop-server         # Stops a minecraft server.
  aws_minecraft.rb terminate-instance  # Terminates an EC2 instance.
  aws_minecraft.rb upload-files        # Uploads everything from drop, not just the world.
  aws_minecraft.rb upload-world        # Upload world.
```
