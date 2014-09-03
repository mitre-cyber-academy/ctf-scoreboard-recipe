user_home = "/home/" + node["user"]

apt_repository "postgresql" do
  uri "http://apt.postgresql.org/pub/repos/apt/"
  distribution node['lsb']['codename'] + "-pgdg"
  components ["main"]
  key "http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc"
end

package "postgresql-#{node['pgsql-version']}" do
  action :install
end

package "postgresql-server-dev-#{node['pgsql-version']}" do
  action :install
end

execute "create-postgres-user" do
  command "sudo -u postgres createuser --superuser \"#{node['user']}\""
  user node["user"]
  action :run
end

cookbook_file "/etc/postgresql/#{node['pgsql-version']}/main/pg_hba.conf" do
  source "pg_hba.conf"
  owner "postgres"
  group "postgres"
  mode 0420
end

service "postgresql" do
  supports :start => true, :stop => true, :restart => true
  action :restart
end