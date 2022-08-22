# Container

The container is build using Ubuntu 20.04 on which UNIX libgomp1 (required for Fragpipe tools), Java (for all Fragpipe tools) and python (including numpy and pandas) for database splitting. 

The container can be downloaded or built:

#### Downloading

    #Docker
    docker pull patrickvanzalm/ubuntu_fragpipe

    #Singularity
    singularity build ubuntu_fragpipe docker://patrickvanzalm/ubuntu_fragpipe

#### Build 

Singularity does not allow building from a Dockerfile. We suggest building it locally using Docker followed by pushing it to a container registry and converting it to singularity by downloading from such a registry as described above.

    #Docker
    docker build <your_container_name> .



