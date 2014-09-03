user_home = "/home/" + node["user"]

package "libssl-dev" do
  action :install
end

package "gcc" do
  action :install
end

package "libreadline-dev" do
  action :install
end

package "zlib1g-dev" do
  action :install
end

bash "ruby-build" do
    user node["user"]
    cwd user_home
    code <<-EOH
      git clone https://github.com/sstephenson/ruby-build.git ruby-build
      cd ruby-build
      sudo ./install.sh
      cd ..
      rm -rf ruby-build
    EOH
end
