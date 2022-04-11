#!/usr/bin/env python3
"""
Source: https://huggingface.co/blog/sentiment-analysis-python
Modifications:
 - mlflow integration for experiment tracking
 - iteration over multiple models
 - load data from file
"""

import json
import logging
import os
import random
import time
from typing import Any, Dict, List

import mlflow.pytorch
from transformers import pipeline

# for loading environment variables from a file:
# the .env file contains values required by MLFlow
# pip install python-dotenv~=0.20.0
# from dotenv import load_dotenv  # load secrets from `.env`
import mlflow

# load_dotenv('.env')

logging.basicConfig(level=logging.WARN)
logger = logging.getLogger(__name__)


def log_predictions(predictions: List[Dict[str, Any]], fdir="out") -> str:
    """Logs predictions to single file.
    Needs refactoring to avoid file collisions if this
    is to be made multi-threaded. (e.g. use /tmp/{process_id})
    """
    os.makedirs(f"{fdir}", exist_ok=True)  # can use folders
    fname = f"{fdir}/predictions.json"
    preds = [max(p, key=lambda x: x["score"]) for p in predictions]
    with open(fname, "w", encoding="utf-8") as f:
        json.dump(preds, f, indent=2)
    return fname


def run_experiment(
    experiment_name="demo", model_file="models.txt", data_file="data.txt"
):
    with open(model_file, "r") as f:
        models = [s.replace("\n", "") for s in f.readlines()]

    with open(data_file, "r") as f:
        data = [s.replace("\n", "") for s in f.readlines()]

    experiment = mlflow.set_experiment(experiment_name)

    for model_uri in models:
        with mlflow.start_run(experiment_id=experiment.experiment_id):
            mlflow.log_param("model", model_uri)
            mlflow.log_artifact(
                "main.py", artifact_path="in"
            )  # store current file
            mlflow.log_artifact("data.txt", artifact_path="in")
            # set tags that are meaningful for you
            mlflow.set_tag("type", "exploration")

            # the following tags are "reserved" by mlflow:
            desc = f"{model_uri} being used in a demo evaluation."
            mlflow.set_tag("mlflow.note.content", desc)
            mlflow.set_tag("mlflow.user", "data-scientist-1")

            start_time = time.time()
            model = pipeline(model=model_uri, return_all_scores=True)
            time_load = time.time() - start_time

            start_time = time.time()
            predictions = model(data)
            time_infer = time.time() - start_time

            # demonstrate storing artifacts (any kind)
            # here we extract the predictions with the highest score
            fname = log_predictions(predictions)
            mlflow.log_artifact(fname, artifact_path="out")

            # can log predictions as files directly (no saving to disk)
            for idx, pred in enumerate(predictions):
                mlflow.log_dict(pred, f"out/pred/{idx:08d}.json")

            # compute metrics here somehow
            # need to look up expected answers
            metrics = {
                "metric": random.random(),
                "duration": time_load + time_infer,
                "inference-time": time_infer,
                "loading-time": time_load,
            }
            mlflow.log_metrics(metrics)

        logging.info(f"PREDICTIONS: {predictions}\n")

    return experiment


if __name__ == "__main__":
    experiment = run_experiment()
    logging.info(f"EXPERIMENT: {experiment}")
