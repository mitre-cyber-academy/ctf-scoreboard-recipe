root      = File.expand_path("..", __FILE__)
solo_json = File.join(root, "node.json")

Vagrant.configure("2") do |config|
	# Every Vagrant virtual environment requires a box to build off of.
	# The url from where the 'config.vm.box' box will be fetched if it
	# doesn't already exist on the user's system.
	#
  # Install the latest version of Chef (uses https://github.com/schisamo/vagrant-omnibus)
  config.omnibus.chef_version = :latest

  config.vm.box = "hashicorp/precise64"
  config.vm.network :forwarded_port, guest: 443, host: 4343, auto_correct: true

	config.vm.provider :virtualbox do |vb|
		vb.customize ["modifyvm", :id, 
			"--memory", "1024", 
			"--cpus", "2",
			"--ioapic", "on"
		]
	end

	config.vm.provision :chef_solo do |chef|
		chef.cookbooks_path = "cookbooks"
		chef.json = JSON.parse(File.open(solo_json, &:read))
		chef.json["user"] = "ubuntu"
		chef.json["run_list"].each do |recipe_name|
			chef.add_recipe recipe_name
		end
	end
end
