# MLflow Deployment and Usage with docker-compose

Easily deploy an MLflow tracking server with 1 command.


## Architecture

The MLflow tracking server is composed of 4 docker containers:
* MLflow client (runs experiments)
* MLflow server (receives data from experiments)
* MinIO object storage server [`minio`](https://hub.docker.com/r/minio/minio) (holds artifacts from experiments)
* (temporary) MinIO client [`mc`](https://hub.docker.com/r/minio/mc) (to create initial `mlflow` bucket upon startup)
* MySQL database server [`mysql`](https://hub.docker.com/r/mysql/mysql-server) (tracks tabular experimental results)


## Quickstart

0. Install [Docker](https://docs.docker.com/get-docker/) and ensure you have [docker-compose](https://docs.docker.com/compose/install/) installed. Make sure you have `make` and `curl` installed as well.

1. Clone (download) this repository

    ```bash
    git clone https://github.com/ml-starter-packs/mlflow-experiment.git
    ```

2. `cd` into the `mlflow-experiment` directory

3. Build and run the containers with `docker-compose up -d --build`:

    ```bash
    make
    ```

4. Access MLflow UI with [http://localhost:5000](http://localhost:5000)

5. Watch as runs begin to populate in the [`demo` experiment](http://localhost:5000/#/experiments/1)) as the script [./nlp-demo/main.py](/nlp-demo/main.py) executes.


6. (optional) Access MinIO UI with [http://localhost:9000](http://localhost:9000) to see how MLflow artifacts are organized in the S3-compatible object storage (default credentials are `minio` / `minio123`).


## Cleanup

To stop all containers and remove all volumes (i.e., purge all stored data), run

```bash
make clean
```

To stop all running containers _without_ removing volumes, run

```bash
make stop
```


## Training + Serving Example

A complete example that would resemble local usage can be found at `[./nlp-demo/example.sh](./nlp-demo/example.sh)` and run with

```bash
make serve
```

You have just trained a model from [mlflow/mlflow-example](https://github.com/mlflow/mlflow-example) under the `Default` experiment (you can see it in your [localhost MLflow UI](http://localhost:5000/#/experiments/0)) and begun to serve it as an API endpoint.
Give it a set of samples to predict on using `curl` with

```bash
make post
```

Note: you can run `[./nlp-demo/example.sh](./nlp-demo/example.sh)` locally if you prefer (it is designed as a complete example). Take note that you may want to omit the `--no-conda` flags if you want to use the default behavior of `mlflow serve` which leverages [Anaconda](https://www.anaconda.com/).


You can stop serving your model (perhaps if you want to try running the serving demo a second time) with

```bash
make kill
```

## Running New Experiments

Edit `./nlp-demo/main.py` and re-run the experiment service (if you commit your code, it should be visible in MLflow) using `docker-compose run nlp`:

```bash
make run
```

You will find your new results populated in the existing `demo` experiment.
