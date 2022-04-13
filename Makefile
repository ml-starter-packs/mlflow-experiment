run:
	docker-compose run nlp

start:
	docker-compose up -d --build

stop:
	docker rm -f \
	mlflow_s3 \
	mc \
	mlflow_db \
	mlflow_server \
	mlflow_client

clean: stop
	docker volume rm mlflow-experiment_dbdata mlflow-experiment_minio_data
