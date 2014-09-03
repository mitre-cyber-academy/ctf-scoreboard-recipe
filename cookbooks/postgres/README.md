Postgresql Cookbook
===================

This is a cookbook which installs the postgresql version which you specify in your node.json file.

This cookbook also requires the opscode apt cookbook to be included in the run list.

You specify it as follows: "passenger_version": "x.y.z", where x.y.z is a valid passenger version.

You will also have to include this cookbook in your run list and include it as a submodule in your project.
