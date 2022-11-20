# MLflow Deployment and Usage with docker-compose

Easily deploy an MLflow tracking server with 1 command.


## Architecture

The MLflow tracking server is composed of 4 docker containers:
* MLflow client (runs experiments)
* MLflow server / web interface at [`localhost:5555`](http://localhost:5555/) (receives data from experiments)
* MinIO object storage server [`minio`](https://hub.docker.com/r/minio/minio) (holds artifacts from experiments)
* MySQL database server [`mysql`](https://hub.docker.com/r/mysql/mysql-server) (tracks tabular experimental results)
* (and a fifth temporary) MinIO client [`mc`](https://hub.docker.com/r/minio/mc) (to create initial `s3://mlflow/` bucket upon startup)


## Quickstart

0. Install [Docker](https://docs.docker.com/get-docker/) and ensure you have [docker-compose](https://docs.docker.com/compose/install/) installed. Make sure you have `make` installed as well (and `awk`, `grep`, `curl`, `head`, and `tail` for the [serving example](#training-and-serving-example).

1. Clone (download) this repository

    ```bash
    git clone https://github.com/ml-starter-packs/mlflow-experiment.git
    ```

2. `cd` into the `mlflow-experiment` directory

3. Build and run the containers with `docker-compose up -d --build`:

    ```bash
    make
    ```

4. Access MLflow UI with [http://localhost:5555](http://localhost:5555)

5. Watch as runs begin to populate in the [`demo` experiment](http://localhost:5555/#/experiments/1) as the script [./examples/main.py](/examples/main.py) executes.


6. (optional) Access MinIO UI with [http://localhost:9000](http://localhost:9000) to see how MLflow artifacts are organized in the S3-compatible object storage (default credentials are `minio` / `minio123`).


## Cleanup

To stop all containers and remove all volumes (i.e., purge all stored data), run

```bash
make clean
```

To stop all running containers _without_ removing volumes (i.e. you want the state of the application to persist), run

```bash
make stop
```


## Training and Serving Example

A complete example that would resemble local usage can be found at [`./examples/train-and-serve.sh`](./examples/train-and-serve.sh) and run with

```bash
make serve
```

This demo trains a model using [mlflow/mlflow-example](https://github.com/mlflow/mlflow-example) under the [`Default` experiment](http://localhost:5555/#/experiments/0)) and then serves it as an API endpoint.


Give it a set of samples to predict on using `curl` with

```bash
make post
```

You can stop serving your model (perhaps if you want to try running the serving demo a second time) with

```bash
make stop
```

Note: you can run [`./examples/train-and-serve.sh`](./examples/train-and-serve.sh) locally if you prefer (it is designed as a complete example) but you need to change the URLs to point to your local IP address and reflect that mlflow is _exposed_ on port `5555` (the service runs on `5000` within its container but this is a commonly used port so it is changed to avoid potential conflicts with existing services on your machine). Take note that you may want to omit the `--no-conda` flags if you want to use the default behavior of `mlflow serve` which leverages [Anaconda](https://www.anaconda.com/).


## Running New Experiments

Edit [`./examples/main.py`](./examples/main.py) and re-run the experiment service (if you commit your code, the latest git hash will be reflected in MLflow) using `docker-compose run nlp`:

```bash
make run
```

When it completes after a few minutes, you will find new results populated in the existing [`demo` experiment](http://localhost:5555/#/experiments/1), and a stopped container associated with the run will be visible when running `docker ps -a`.

The container associated with the example runs can be removed with

```bash
make rm
```

Note: This instruction is also run by `make clean`.


## A Note on Docker Setup
This may be of more relevance to some than others, depending on which container-orchestration client you are using.
If you get credential errors from trying to pull the images, it is because your program is not sure what domain name to infer (some private registry or docker's default?).

You can make explicit where you want images that are not prepended with a domain name to come from by setting your docker config file:

```sh
cat ~/.docker/config.json 
{
  "experimental" : "disabled",
  "credStore" : "desktop",
  "auths" : {
    "https://index.docker.io/v1/" : {

    }
  }
}
```

Be aware that it may be `credStore` or `credsStore` depending on your setup.
