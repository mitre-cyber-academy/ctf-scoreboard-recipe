# allow all outbound access 
execute "allow outbound" do
  command "ufw default allow outgoing"
end