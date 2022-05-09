run:
	docker-compose run -d nlp
	@echo "Experiment running. Visit http://localhost:5555 to watch experiments begin to populate in 'demo'. Run 'docker logs mlflow_client' to see the status of the experiment"

start:
	docker-compose up -d --build
	@echo "mlflow server started in background"

stop: kill
	@docker rm -f \
	mlflow_s3 \
	mc \
	mlflow_db \
	mlflow_server \
	mlflow_client
	@echo "\t>> containers for services removed"

clean-runs:
	@docker ps -a | grep nlp_run | awk '{print $$1}' | xargs docker rm -f
	@echo "\t>> containers for docker-compose runs removed"

clean: stop clean-runs
	@docker volume rm -f mlflow-experiment_dbdata mlflow-experiment_minio_data
	@docker network rm mlflow-experiment_default || echo "no networks left"
	@echo "\n\t>> all containers, volumes, and networks from the experiment have been deleted"

serve:
	docker run --rm -tid \
		-e MLFLOW_S3_ENDPOINT_URL="http://minio:9000" \
		-e MLFLOW_TRACKING_URI="http://web:9000" \
		-v `pwd`/examples/train-and-serve.sh:/tmp/run.sh \
		-p 1234:1234 \
		--name mlflow_serve_demo \
		--network mlflow-experiment_default \
		mlflow_nlp_demo /tmp/run.sh

post:
	@curl -X POST -H "Content-Type:application/json; format=pandas-split" --data '{"columns":["fixed acidity", "volatile acidity", "citric acid", "residual sugar", "chlorides", "free sulfur dioxide", "total sulfur dioxide", "density", "pH", "sulphates", "alcohol"], "data":[[7, 0.27, 0.36, 7.2, 0.055, 45, 168, 1.02, 3, 0.39, 12.8]]}' http://localhost:1234/invocations

kill:
	@docker rm -f \
	mlflow_serve_demo
	@echo "\t>> container for model serving removed"
