include .env
export $(shell sed 's/=.*//' .env)

HOST_PORT ?= 8080
PORT ?= $(HOST_PORT)

gh-create-repo:
	gh repo create diincompany/$(REPO_DEST) --template diincompany/template-store --private --description "$(REPO_DESC)" && echo "Repository $(REPO_DEST) created"
	sleep 5
	git clone git@github.com:diincompany/$(REPO_DEST).git ../$(REPO_DEST)
	echo "Repository $(REPO_DEST) ready to use"

gh-secret-set:
	gh secret set $(SECRET_KEY) --body "$(SECRET_VALUE)" --repo $(GH_REPO)

install:
	docker compose run --rm php composer install

update:
	docker compose run --rm php composer update

start:
	docker compose up -d --build

status:
	docker compose ps

build:
ifdef PLATFORM
	docker build --platform $(PLATFORM) -t ${CONTAINER_NAME} .
else
	docker build -t ${CONTAINER_NAME} .
endif

run:
ifdef YII_ENV
	docker run -it --rm -p ${PORT}:80 -e YII_ENV=${YII_ENV} ${CONTAINER_NAME}
else
	docker run -it --rm -p ${PORT}:80 ${CONTAINER_NAME}
endif

push:
	aws ecr get-login-password --region ${AWS_REGION} --profile ${AWS_PROFILE} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}
	docker tag ${IMAGE_NAME}:latest ${ECR_REPOSITORY}/${REPO_NAME}:latest
	docker push ${ECR_REPOSITORY}/${REPO_NAME}:latest

migrate:
	docker compose run --rm php php yii migrate

migrate/create:
	docker compose run --rm php php yii migrate/create ${CMD}

require:
	docker compose run --rm php composer require ${PACKAGES}