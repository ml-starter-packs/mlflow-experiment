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
