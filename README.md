

To build the docker the script `build_docker.sh` as follows:
```
./build_docker.sh -d <docker_image_name> -b <miopen_branch> -s <miopen_src_dir> --private --opencl
```

* The `-s <docker_image_name>` is the name of the final docker image.
* `-b <miopen_branch>` is the branch name. In this case, because we are defaulted to `--private` MIOpen repo, the default branch is `develop`.
* `-s <miopen_src_dir>` is the MIOpen source directory. If this exists, it must be located in the Dockerfile directory. If it does not exist it is cloned from GitHub.
* `--private` specified whether to use the private MIOpen repo, or the public repo. By default it is public, and by adding this flag it makes the selection private.
* By default the backend selection is HIP, by using the `--opencl` flag it will create a OpenCL docker.


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

*Note:* MIOpenDriver is mapped to the PATH, so that it can be called from any directory.

Future work is to allow for any home directory to be mapped to the docker.
