

 ## Command line:
To build the docker the script `build_docker.sh` as follows:
```
./build_docker.sh -d <docker_image_name> -b <miopen_branch> -s <miopen_src_dir> --private --opencl
```

 ## Flags:
* The `-s <docker_image_name>` is the name of the final docker image.
* `-b <miopen_branch>` is the branch name. In this case, because we are defaulted to the public MIOpen repo, the default branch is `master`.
* `-s <miopen_src_dir>` is the MIOpen source directory. If this exists, it must be located in the Dockerfile directory. If it does not exist it is cloned from GitHub.
* `--private` specified whether to use the private MIOpen repo, or the public repo. By default it is public, and by adding this flag it makes the selection private.
* By default the backend selection is HIP, by using the `--opencl` flag it will create a OpenCL docker.
* To delete the docker cache add the flag `--no-cache`

The script will pull MIOpen from the private repo, and checkout the requested branch, if nothing is stated as the requested branch, the script will default to the `develop` branch.


 ## Running:
To run the docker:
```
alias drun="sudo docker run -it -v $HOME:/data --privileged --rm --device=/dev/kfd --device /dev/dri:/dev/dri:rw  --volume /dev/dri:/dev/dri:rw -v /var/lib/docker/:/var/lib/docker --group-add video"
```
Then:
```
drun <docker_image_name>
```
 Users can customize this of course, but I can't say it will always work.

  ## Sending commmands:
Once the docker is running on the remote system, this command can be used to execute the individual `MIOpenDriver` command:

```
docker exec -ti <my_container> sh -c "MIOpenDriver conv <args>"
```

