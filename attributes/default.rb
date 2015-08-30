default['firewall']['rules'] = [
  {"allow https from EVERYWHERE" => {
      "port" => "443",
      "source" => "0.0.0.0/0",
      "action" => "allow"
    }
  },
  # {"block ssh from EVERYWHERE" => {
  #     "port" => "22",
  #     "source" => "0.0.0.0/0",
  #     "action" => "deny"
  #   }
  # },
  {"allow ssh to Jumpbox" => {
      "dest_port" => "22",
      "destination" => "10.0.0.22",
      "action" => "allow"
    }
  },
  {"allow http to everywhere" => {
      "dest_port" => "80",
      "destination" => "0.0.0.0/0",
      "action" => "allow"
    }
  }
]
default['firewall']['securitylevel'] = ""
default["rails-app"]["repository"] = "https://github.com/mitre-cyber-academy/ctf-scoreboard.git"
default["rails-app"]["revision"] = "master"
default["rails-app"]["ssl"] = true
default["scoreboard"]["user"] = "ubuntu"