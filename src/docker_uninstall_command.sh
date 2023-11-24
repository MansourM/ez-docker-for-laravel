echo "# this file is located in 'src/docker_uninstall_command.sh'"
echo "# code for 'ez docker uninstall' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
