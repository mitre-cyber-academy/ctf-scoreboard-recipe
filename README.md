# ctf-scoreboard-recipe cookbook

This is a cookbook that allows for the automated creation of a scoreboard for the MITRE stem CTF. It also sets up syncing of keys between the VPN box and the scoreboard for users to download.

## Commands to use this recipe for deployment

If you want to run this recipe on your server without using a full chef server install, you can use the following commands.

* `curl -L https://www.chef.io/chef/install.sh | sudo bash` # Install chef
* `cd scoreboard-recipe` # Enter directory containing this code
* `berks vendor cookbooks` # fetch all cookbook dependencies and place in the cookbooks directory.
* `sudo chef-client -z -j (hs|college)-node.json` # Run the chef client in standalone mode using the hs and college node.json provided.

Note: When deploying this for an actual CTF, you can run 2 instances of the scoreboard side-by-side on the same machine, all you need to do is execute `sudo chef-client -z -j` on both the hs and college node.json files. They will not conflict with one another.