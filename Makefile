run:
	docker-compose run nlp

start:
	docker-compose up -d --build

stop:
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

demo:
	docker run --rm -tid \
		-e MLFLOW_S3_ENDPOINT_URL="http://minio:9000" \
		-e MLFLOW_TRACKING_URI="http://web:9000" \
		-v `pwd`:/work \
		-p 1234:1234 \
		--network mlflow-experiment_default \
		mlflow_nlp_demo ./nlp-demo/example.sh

test:
	@curl -X POST -H "Content-Type:application/json; format=pandas-split" --data '{"columns":["fixed acidity", "volatile acidity", "citric acid", "residual sugar", "chlorides", "free sulfur dioxide", "total sulfur dioxide", "density", "pH", "sulphates", "alcohol"], "data":[[7, 0.27, 0.36, 7.2, 0.055, 45, 168, 1.02, 3, 0.39, 12.8]]}' http://localhost:1234/invocations
