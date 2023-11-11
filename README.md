# linux-infrastructure

First we need to build base ubuntu 22.04 image with dockerfile

```
docker build -t syntaxbender:22.04-ubuntu -f ./linux-infrastructure/Docker/ubuntu2204.dockerfile .
# If you want to rebuild add --no-cache parameter
```

Let's check if the image build is successful.

```
$ docker image ls

REPOSITORY                                                       TAG                  IMAGE ID       CREATED         SIZE
syntaxbender                                                     22.04-ubuntu         0db5658559a7   4 hours ago     1.44GB
homplatform-infrastructure-postgres15-dev                        latest               26d8a4cf8a9e   5 months ago    1.55GB
homplatform-infrastructure-redis7-dev                            latest               c7094a1bebde   5 months ago    1.45GB
homplatform-infrastructure-charon-service                        latest               0947a8cb9b7a   5 months ago    1.6GB
homplatform-infrastructure-charon-client                         latest               0bfd28553599   5 months ago    1.6GB
homplatform-infrastructure-node-1816-frontend-dev                latest               b2207a4537bd   5 months ago    1.6GB
homplatform-infrastructure-node-1816-backend-dev                 latest               63b712495c27   5 months ago    1.6GB
redis                                                            7.0.11-bullseye      116cad43b6af   6 months ago    117MB
```

Looks like build successfully.

We will create an container named "ubuntu-22.04" from "syntaxbender:22.04-ubuntu" image and take a bash shell for test.

```
docker container run -it --name ubuntu-22.04 syntaxbender:22.04-ubuntu bash
```

We can see this container with this command.

```
$ docker container ls --all

CONTAINER ID   IMAGE                                                                   COMMAND                  CREATED         STATUS                      PORTS                                     NAMES
cff326bfb5f2   syntaxbender:22.04-ubuntu                                               "bash"                   4 minutes ago   Exited (0) 4 minutes ago                                              ubuntu-22.04
776e9c54272b   homplatform-infrastructure-charon-client                                "bash"                   5 months ago    Exited (137) 4 months ago                                             homplatform-infrastructure-charon-client-1
db851ac261ba   homplatform-infrastructure-charon-service                               "bash"                   5 months ago    Exited (137) 4 months ago                                             homplatform-infrastructure-charon-service-1
```

We can start a container for before take a bash shell with this commands

```
docker start ubuntu-22.04
```

We can take a shell after starting container with this command

```
docker exec -it ubuntu-22.04 bash
```
