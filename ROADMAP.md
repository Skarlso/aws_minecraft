Roadmap for aws_minecraft
=========================

0.2.0
-----

* Working on coverage is important. Adding unit tests for ssh, uploader and negative scenarios for
aws_helper would be Next.
* Some of the error cases are not handled really well at the moment. They just raise an error.
* Upload world is not working yet.
* Everything Minecraft related could be extracted.
* Would be nice if it wouldn't re-upload.
* start-server doesn't tell you if starting the tmux session was successful or not.
* World backup isn't there yet.
 * Could be to an S3 or, even downloaded.

0.1.0
-----

* This is an MVP at this stage, with everything working and the most important parts have unit tests.


0.0.4
-----

* Stopping minecraft server
* Attaching to PID to see output and to run commands
* Investiage tmux to run minecraft and attach to later (This would save a lot of trouble)
* Use tmux like this:
```bash
# runs a tmux session and detaches from it
tmux new -d -s minecraft 'java -jar minecraft_server.jar nogui'
# can attach to the running session so that we can control minecraft
tmux attach -t minecraft
```

0.0.3
-----

* Ready the CLI for starting a minecraft server
  * Includes uploading a minecraft jar
  * Remote execution on the host
  * Saving PID id of the minecraft process

0.0.2
-----

* Ready the CLI for starting, stopping, terminating, creating ec2 instance
