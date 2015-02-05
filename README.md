The Dude's Compute Env
=================

I use this to provision my env after applying some localized kickstarts.  So, if you wanna use it you can roll your own.  Eventually I'll post mine for those extra lazy peeps.

**Frosty's Edit**
This particular version is being modified to use Red Hat proper software and channels.  No, it's not done.  Yes, you can contribute.  No, It's not pretty.  No, I don't care.

Now back to your regularly scheduled README...

**DISCLAIMER:**

SYK: This is useless, and should be used by noone. Thanks SouthPark!!

**Requirements:**

- A properly installed, and configured server, or admin access to one
- A properly installed, and configured Ansible Host to run this from.

**This has been thoroughly tested on CentOS 6.6** 

Steps:

- On your 'Ansible Host' you'll need to ensure or perform the following:
	- identify, or (if needed) create ssh keys for your box
		- ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
	- copy the ssh keys to the vms that you want to provision:
		- ssh-copy-id root@${all your VMs}
		- OR use sshpass, ssh-add, ssh-agent, etc..

- Modify ./group_vars/all to reflect your environment's specifics.

- Modify ./hosts & ./site.yml to reflect your environment's specifics.
	- **Important: these two files MUST contain entries that resolve to the appropriate VMS. Whether DNS, or files based (/etc/hosts for ex).**

- Hit me up if you have any questions:
	- Michael McConachie <dude@thelinuxgeek.us>
