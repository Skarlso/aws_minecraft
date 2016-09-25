Roadmap for aws_minecraft
=========================

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
