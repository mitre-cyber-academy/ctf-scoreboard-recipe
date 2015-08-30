# ctf-scoreboard-recipe cookbook

This is a cookbook that allows for the automated creation of a scoreboard for the MITRE stem CTF. It also sets up syncing of keys between the VPN box and the scoreboard for users to download.

## Commands to use this recipe for deployment

If you want to run this recipe on your server without using a full chef server install, you can use the following commands.

* `curl -L https://www.chef.io/chef/install.sh | sudo bash` # Install chef
* `cd scoreboard-recipe` # Enter directory containing this code
* `berks vendor cookbooks` # fetch all cookbook dependencies and place in the cookbooks directory.
* `sudo chef-client -z -j node.json` # Run the chef client in standalone mode using the node.json provided.

## To Do

* Update recipe to use Berkshelf.
* Update scoreboard to be downloaded from GitHub instead of using a local copy.
* Update to use official cookbooks instead of ours.
