echo "# this file is located in 'src/docker_remove_command.sh'"
echo "# code for 'ez docker remove' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
