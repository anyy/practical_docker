#!/bin/bash

docker-compose up -d

docker container exec -it manager docker network create --driver=overlay --attachable todoapp
docker container exec -it manager docker swarm init
SWMTKN=$(docker container exec -it manager docker swarm join-token -q worker)

for no in 01 02 03
do
    docker container exec -it worker$no docker swarm join --token $SWMTKN "manager:2377"
done

docker exec -it manager docker stack deploy -c /stack/todo-mysql.yml todo_mysql
docker exec -it manager docker stack deploy -c /stack/todo-app.yml todo_app
docker exec -it manager docker stack deploy -c /stack/todo-frontend.yml todo_frontend
docker exec -it manager docker stack deploy -c /stack/todo-ingress.yml todo_ingress
