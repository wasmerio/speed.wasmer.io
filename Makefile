PROJECT_ID = wasmer
ZONE = us-central1-b
GIT_VERSION := $(shell git rev-parse --short HEAD)
CLUSTER = wasmer-cluster-prod
POD_NAME = wasmerspeed
HOST_IP := $(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

local_run:
	python backend/manage.py runserver

init_gcloud:
	gcloud config set project ${PROJECT_ID}
	gcloud config set compute/zone ${ZONE}
	# gcloud container clusters create ${CLUSTER} --num-nodes=1
	gcloud container clusters get-credentials ${CLUSTER}

image:
	docker build -t gcr.io/${PROJECT_ID}/wasmerspeed:${GIT_VERSION} .

publish_image: init_gcloud image
    # You may need to execute
	gcloud docker -- push gcr.io/${PROJECT_ID}/wasmerspeed:${GIT_VERSION}

init_cluster: init_gcloud
	# First we create the cluster
	# Then we create the service
	# kubectl run ${POD_NAME} --image=gcr.io/${PROJECT_ID}/wasmerspeed:${GIT_VERSION} --port 8080
	kubectl apply -f kubernetes/deployment.yaml
	kubectl apply -f kubernetes/ingress.yaml
	kubectl apply -f kubernetes/service.yaml
	# And expose this service in the load balancer
	# kubectl expose deployment ${POD_NAME} --type=LoadBalancer --port 8080 --target-port 8080
	# kubectl expose deployment ${POD_NAME} --type=LoadBalancer --port 3000 --target-port 3000

docker_cache:
	mkdir -p docker-cache
	docker save -o docker-cache/built-image.tar gcr.io/${PROJECT_ID}/wasmerspeed:${GIT_VERSION}

generate_secrets:
	# kubectl delete secret wasmerspeed-secrets
	kubectl create secret generic wasmerspeed-secrets --from-env-file=./.env.prod

update_deployment: init_gcloud image publish_image
	kubectl apply -f kubernetes/deployment.yaml
	kubectl set image deployment/${POD_NAME} wasmerspeed=gcr.io/${PROJECT_ID}/wasmerspeed:${GIT_VERSION}

# delete_cluster: init_gcloud
# 	# WARNING!
# 	kubectl delete service ${POD_NAME}
# 	gcloud compute forwarding-rules list
# 	gcloud container clusters delete ${CLUSTER}

docker_run: image
	docker run --env-file .env -p 8080:8080 gcr.io/${PROJECT_ID}/wasmerspeed:${GIT_VERSION}
