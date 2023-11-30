# container-engine-accelerators/nvidia-driver-installer/ubuntu

## Build the image

```bash
docker build -t additional-lib .
``````

In ds-preload.yaml change line number 74 and set the name of the docker image you build and pushed in Artifact registry previously.


