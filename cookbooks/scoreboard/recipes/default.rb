user_home = "/home/" + node["user"]
rails_app_path = "/opt/scoreboard"

package "libxml2-dev" do
  action :install
end

package "libxslt1-dev" do
  action :install
end

package "unison" do
  action :install
end

remote_directory rails_app_path do
  source "scoreboard"
  owner node["user"]
  group node["user"]
  mode 0755
end

directory "/opt/keys" do
  owner "ubuntu"
  group "ubuntu"
  mode 00755
  action :create
end

ruby_block "setup-environment" do
  block do
    if File.exists?("#{rails_app_path}/.rbenv-version")
        ENV['RUBY_VERSION'] = File.read("#{rails_app_path}/.rbenv-version").strip
    elsif File.exists?("#{rails_app_path}/.ruby-version")
        ENV['RUBY_VERSION'] = File.read("#{rails_app_path}/.ruby-version").strip
    else
        Chef::Application.fatal!("No .ruby-version or .rbenv-version file found...Exiting.", 10)
    end
    ENV['RUBY_PATH'] = user_home + "/local/" + ENV['RUBY_VERSION']
    ENV['RUBY_BIN_PATH'] = ENV['RUBY_PATH'] + '/bin'
    ENV['RAILS_ENV'] = "production"
    ENV['PATH'] = ENV['RUBY_BIN_PATH'] + ":" + ENV['PATH']
  end
end

# Install make and compiler required by passenger-install
package "build-essential" do
  action :install
end

bash "setup-ruby" do
  user node['user']
  cwd rails_app_path
  code <<-EOF
    ruby-build $RUBY_VERSION $RUBY_PATH
    echo "export PATH=\"$RUBY_BIN_PATH:\\$PATH\"" >> #{user_home}/.bashrc
    gem install bundler --no-rdoc --no-ri
    gem install passenger -v #{node['passenger-version']} --no-rdoc --no-ri
  EOF
end

bash "setup-scoreboard" do
  user node['user']
  cwd rails_app_path
  code <<-EOH
    bundle install --deployment --without development test
    bundle exec rake db:create
    bundle exec rake db:schema:load
    bundle exec rake db:seed
    bundle exec rake assets:precompile
    rm -f db/seeds.rb
  EOH
end

# Required for passenger-install-nginx-module
package "libcurl4-openssl-dev" do
  action :install
end

bash "passenger-install-nginx-module" do
  user "root"
  cwd user_home
  code <<-EOH
    passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx
  EOH
end

ruby_block "create /opt/nginx/conf/nginx.conf from template" do
  block do
    res = Chef::Resource::Template.new "/opt/nginx/conf/nginx.conf", run_context
    res.source "nginx.conf.erb"
    res.cookbook cookbook_name.to_s
    res.variables(
      passenger_root: "#{ENV["RUBY_PATH"]}/lib/ruby/gems/1.9.1/gems/passenger-#{node['passenger-version']}",
      passenger_ruby: "#{ENV["RUBY_PATH"]}/bin/ruby",
      root: "#{rails_app_path}/public"
    )
    res.run_action :create
  end
end

bash "setup_ssh_config" do
  user node['user']
  cwd user_home
  code "echo 'StrictHostKeyChecking no' >> .ssh/config"
end

ruby_block "sync_jumpbox_keys" do
  block do
    res = Chef::Resource::Cron.new "sync_jumpbox_keys", run_context
    res.action :create
    res.minute "*"
    res.user node['user']
    res.command "PATH=\"#{ENV['RUBY_PATH']}/bin:$PATH\" && cd #{rails_app_path} && RAILS_ENV=production bundle exec rake scoreboard:certificates:copy"
    res.run_action :create
  end
end

ruby_block "backup_scoreboard_database" do
  block do
    res = Chef::Resource::Cron.new "backup_scoreboard_database", run_context
    res.action :create
    res.minute "5"
    res.user node['user']
    res.command "PATH=\"#{ENV["RUBY_PATH"]}/bin:$PATH\" && cd #{rails_app_path} && RAILS_ENV=production bundle exec rake scoreboard:db:backup"
    res.run_action :create
  end
end

cookbook_file "/etc/init.d/nginx" do
  source "init_d_script"
  mode 0755
end

cookbook_file "/etc/logrotate.d/scoreboard" do
  source "logrotate"
  owner "root"
  group "root"
  mode 0644
end

bash "setup-ssl" do
  user "root"
  code <<-EOH
    # generate the keys 
    ssh-keygen -q -t rsa -N "" -f scoreboard.key
    cp scoreboard.key #{user_home}/.ssh/id_rsa
    mv scoreboard.key.pub #{user_home}/.ssh/id_rsa.pub
    chown #{node['user']}:#{node['user']} #{user_home}/.ssh/id_rsa
    chmod 600 #{user_home}/.ssh/id_rsa
    openssl req -new -key scoreboard.key -batch -out scoreboard.csr
    openssl x509 -req -days 365 -in scoreboard.csr -signkey scoreboard.key -out scoreboard.crt
    
    # remove csr
    rm scoreboard.csr
    
    # put keys next to conf
    sudo mv scoreboard.key /opt/nginx/conf/scoreboard.key
    sudo mv scoreboard.crt /opt/nginx/conf/scoreboard.crt
    sudo chmod 644 /opt/nginx/conf/scoreboard.{key,crt}
  EOH
end

service "nginx" do
  supports :start => true, :stop => true, :restart => true
  action [:enable, :start]
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