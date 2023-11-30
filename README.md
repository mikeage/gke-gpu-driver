# container-engine-accelerators/nvidia-driver-installer/ubuntu

## Build the image

```bash
docker build -t additional-lib .
``````

In ds-preload.yaml change line number 74 and set the name of the docker image you built and pushed in Artifact Registry previously.

Then apply this daemonset : 


```bash
kubectl apply -f ds-preload.yaml
``````
