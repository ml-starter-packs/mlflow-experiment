start:
	docker-compose up -d --build
	@echo "mlflow server started in background"
	@echo "Experiment running. Visit http://localhost:5555 to watch experiments begin to populate in 'demo'. Run 'docker logs mlflow_client' to see the status of the experiment"

run:
	docker-compose run -d nlp
	@echo "Experiment running. Visit http://localhost:5555 to watch experiments begin to populate in 'demo'. Run 'docker logs mlflow_client' to see the status of the experiment"


clean: stop rm
	@docker volume rm -f mlflow-experiment_dbdata mlflow-experiment_minio_data
	@echo "\n\t>> all containers, volumes, and networks from the experiment have been deleted"

serve:
	docker run --rm -tid \
		--env-file examples/.env \
		-v `pwd`/examples/train-and-serve.sh:/tmp/run.sh \
		-p 1234:1234 \
		--name mlflow_serve_demo \
		--network mlflow-experiment_default \
		mlflow_nlp_demo /tmp/run.sh

post:
	@curl -X POST -H "Content-Type:application/json; format=pandas-split" --data '{"columns":["fixed acidity", "volatile acidity", "citric acid", "residual sugar", "chlorides", "free sulfur dioxide", "total sulfur dioxide", "density", "pH", "sulphates", "alcohol"], "data":[[7, 0.27, 0.36, 7.2, 0.055, 45, 168, 1.02, 3, 0.39, 12.8]]}' http://localhost:1234/invocations

stop:
	@docker-compose down
	@echo "\t>> containers for services removed"

rm:
	@docker ps -a | grep -e nlp_run -e nlp_demo | awk '{print $$1}' | xargs docker rm -f|| exit 0
	@echo "\t>> containers for docker-compose runs removed"
