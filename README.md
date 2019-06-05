
This dockerfile assumes the user `miopenpdb` exists:

To build the docker the script `build_docker.sh` as follows:
```
./build_docker.sh -s <miopen_src_path> -d <docker_image_name> -b <miopen_branch>
```

Required arguments to `build_docker.sh` are the local MIOpen source directory `<miopen_src_path>`, and the name of the docker image `<docker_image_name>`.

The script will pull MIOpen from the private repo, and checkout the requested branch, if nothing is stated as the requested branch, the script will default to the `develop` branch.


To run the docker:
```
alias drun="sudo docker run -it -v $HOME:/data --privileged --rm --device=/dev/kfd --device /dev/dri:/dev/dri:rw  --volume /dev/dri:/dev/dri:rw -v /var/lib/docker/:/var/lib/docker --group-add video"
```
Then:
```
drun <docker_image_name>
```

The command above will change directory to the directory to `/home/miopenpdb` and mount the home directory. The `PATH` is set up with to have MIOpenDriver callable and the user database file directory is located in miopenpdb's home directory.

Once the docker is running on the remote system, this command can be used to execute the individual `MIOpenDriver` command:

```
docker exec -ti <my_container> sh -c "MIOpenDriver conv <args>"
```
