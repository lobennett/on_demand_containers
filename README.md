# Sherlock OnDemand Template

> This repository contains a template for opening containerized applications in Sherlock OnDemand.

## Documentation

### SSH into Sherlock 

```bash
ssh <username>@login.sherlock.stanford.edu
```
### Clone the repository

```bash
mkdir -p $HOME/ondemand/dev && git clone https://github.com/lobennett/on_demand_containers.git $HOME/ondemand/dev/on_demand_containers
```

### Rename `manifest.yml` metadata

Go to [./manifest.yml](./manifest.yml) and rename `name`, `category`, `subcategory`, and `description`. 

For example, one of my applications has the following [./manifest.yml](./manifest.yml). 

```yml
---
name: LB Containers
category: Computing
subcategory: Reproducibility
role: batch_connect
description: "Launch apptainer image into Jupyter notebook or VSCode.\r\n"
```

### Pull example image

This will pull an example apptainer image to `$SCRATCH/.apptainer/base.sif` and write the name and path to `./container_options.json`.

```bash
./pull_image.sh
```


### Add other containers as needed

Add a dropdown for another image under `container` in [./form.yml](./form.yml#L48). 

```yml
container:
    label: "Container/Environment"
    widget: select
    options:
      - "base"
      - [name_of_my_container]
```

Add an if statement to load the apptainer image by the name and provide its path in [./template/script.sh.srb](./template/script.sh.erb#L22). 

`INSTANCE_NAME` needs to match the image name in [./form.yml](./form.yml#L48) and `CONTAINER_PATH` needs to be the path to the apptainer image. 