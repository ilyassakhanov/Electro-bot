# Description

```
This is an implementation of this telegram bot in Kubernetes
```

## Used software

```
kubectl v1.31.3
minikube v1.34.0
docker 27.2.0
```
## Quick start
After running these commands, telegram bot should be up
```
minikube start
kubectl apply -f selenium.yml
kubectl apply -f my-app.yml
```
## Removal
```
kubectl delete -f selenium.yml
kubectl delete -f my-app.yml
```