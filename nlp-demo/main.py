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

# for loading environment variables from a file:
# the .env file contains values required by MLFlow
# pip install python-dotenv~=0.20.0
# from dotenv import load_dotenv  # load secrets from `.env`
import mlflow
import mlflow.pytorch
from transformers import pipeline

#load_dotenv('.env')

logging.basicConfig(level=logging.WARN)
logger = logging.getLogger(__name__)

# TODO load data from newline-delimited txt file
with open("models.txt", "r") as f:
    models = [s.replace("\n", "") for s in f.readlines()]

with open("data.txt", "r") as f:
    data = [s.replace("\n", "") for s in f.readlines()]

experiment = mlflow.set_experiment("demo")

for model_uri in models:
    with mlflow.start_run(experiment_id=experiment.experiment_id):
        mlflow.log_param("model", model_uri)
        # set tags that are meaningful for you
        mlflow.set_tag("type", "exploration")

        # the following tags are "reserved" by mlflow:
        desc = f"{model_uri} being used in a demo evaluation."
        mlflow.set_tag("mlflow.note.content", desc)
        mlflow.set_tag("mlflow.user", "data-scientist-1")
        model = pipeline(model=model_uri, return_all_scores=True)
        predictions = model(data)

        # demonstrate storing artifacts (any kind)
        os.makedirs("data", exist_ok=True)  # can use folders
        fname = "data/predictions.json"
        with open(fname, "w", encoding="utf-8") as f:
            json.dump(predictions, f, indent=2)
        mlflow.log_artifact(fname)

        # can log individual predictions as well
        for idx, pred in enumerate(predictions):
            mlflow.log_dict(pred, f"data/pred_{idx}.json")

        # compute metrics here somehow
        # need to look up expected answers
        metrics = {"metric": random.random()}
        mlflow.log_metrics(metrics)
    print(f"{predictions}\n")
