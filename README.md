# container-engine-accelerators/nvidia-driver-installer/ubuntu

## Build the image

```bash
docker build -t additional-lib .
``````

## Deploy the daemon set

In [ds-preload.yaml](ds-preload.yaml) change [line number 74](ds-preload.yaml#L74) and set the name of the docker image you built and pushed in Artifact Registry previously.

Then apply this daemonset : 


```bash
kubectl apply -f ds-preload.yaml
``````

## Deploy the daemon set without building the image (WIP)

You can deploy the nvdida driver installer+encode Library with this command : 

```bash
kubectl apply -f no-container-install/
``````

