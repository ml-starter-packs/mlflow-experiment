# MLflow Deployment and Usage with docker-compose

Easily deploy an MLflow tracking server with 1 command.

MinIO S3 is used as the artifact store and MySQL server is used as the backend store.

## How to run
0. Install [Docker](https://docs.docker.com/get-docker/) and ensure you have [docker-compose](https://docs.docker.com/compose/install/) installed.

1. Clone(download) this repository

    ```bash
    git clone https://github.com/ml-starter-packs/mlflow-experiment.git
    ```

2. `cd` into the `mlflow-experiment` directory

3. Build and run the containers with `docker-compose up -d --build`:

    ```bash
    make
    ```

4. Access MLflow UI with [http://localhost:5000](http://localhost:5000)

5. Watch as experiments begin to populate as they run from [./nlp-demo/main.py](/nlp-demo/main.py).


6. (optional) Access MinIO UI with [http://localhost:9000](http://localhost:9000) to see how MLflow artifacts are organized in the S3-compatible object storage.


## Running New Experiments

Edit `./nlp-demo/main.py` and re-run the experiment service (if you commit your code, it should be visible in MLflow) using `docker-compose run nlp`

    ```bash
    make run
    ```


## Architecture

The MLflow tracking server is composed of 4 docker containers:
* MLflow client (runs experiments)
* MLflow server (receives data from experiments)
* MinIO object storage server [`minio`](https://hub.docker.com/r/minio/minio) (holds artifacts from experiments)
* (temporary) MinIO client [`mc`](https://hub.docker.com/r/minio/mc) (to create initial `mlflow` bucket upon startup)
* MySQL database server [`mysql`](https://hub.docker.com/r/mysql/mysql-server) (tracks tabular experimental results)


## Local Example
If you want to interact with the MLflow server from other computers or environments, consult the following:

1. Install Python (perhaps with [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html)) and activate your environment.

2. Install MLflow with extra dependencies and `boto3`

    ```bash
    pip install mlflow[extras] boto3
    ```

3. Set environmental variables (replace `<ip address>` with `localhost` or your remote server's IP)

    ```bash
    export MLFLOW_TRACKING_URI=http://<ip address>:5000
    export MLFLOW_S3_ENDPOINT_URL=http://<ip address>:9000
    ```

4. Set MinIO credentials

    ```bash
    cat <<EOF > ~/.aws/credentials
    [default]
    aws_access_key_id=minio
    aws_secret_access_key=minio123
    EOF
    ```

5. Train a sample MLflow model

    ```bash
    mlflow run https://github.com/mlflow/mlflow-example.git -P alpha=0.42
    ```

 6. Serve the model (replace with your model's actual path)

    ```bash
    mlflow models serve -m S3://mlflow/0/98bdf6ec158145908af39f86156c347f/artifacts/model -p 1234
    ```

 7. You can check the input with this command (replacing `<ip address>` again)

    ```bash
    curl -X POST -H "Content-Type:application/json; format=pandas-split" --data '{"columns":["alcohol", "chlorides", "citric acid", "density", "fixed acidity", "free sulfur dioxide", "pH", "residual sugar", "sulphates", "total sulfur dioxide", "volatile acidity"],"data":[[12.8, 0.029, 0.48, 0.98, 6.2, 29, 3.33, 1.2, 0.39, 75, 0.66]]}' http://<ip address>:1234/invocations
    ```
