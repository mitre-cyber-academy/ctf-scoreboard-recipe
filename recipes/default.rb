rails_app_path = "#{node['rails-app']['path']}/current"
bundle_path = "/usr/local/bin"

package "unison" do
  action :install
end

directory "/opt/keys" do
  owner node["scoreboard"]["user"]
  group node["scoreboard"]["user"]
  mode 00755
  action :create
end

cron 'sync_jumpbox_keys' do
  action :create
  minute "*"
  user node["scoreboard"]["user"]
  path "/usr/local/bin:/usr/bin:$PATH"
  command "cd #{rails_app_path} && RAILS_ENV=production bundle exec rake scoreboard:certificates:copy"
end

cron 'backup_scoreboard_database' do
  action :create
  minute "0" # Backup on every hour.
  user node["scoreboard"]["user"]
  path "/usr/local/bin:/usr/bin:$PATH"
  command "cd #{rails_app_path} && RAILS_ENV=production bundle exec rake scoreboard:db:backup"
end

# open access with ufw for port 80
firewall_rule "http" do
  port 80
  action :allow
end

# open access with ufw for port 443
firewall_rule "ssl" do
  port 443
  action :allow
end

# deny all outbound access 
execute "deny outbound" do
  command "ufw default deny outgoing"
end

# allow ssh out for openvpn server
execute "allow ssh" do
  command "ufw allow out ssh"
end