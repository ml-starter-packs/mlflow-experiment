run:
	docker-compose up -d --build

test:
	docker run --rm -ti --name mlflow-demo -v `pwd`:/work -w /work nlp-exp python main.py

#gpu-test:
#	docker run --gpus all -it --rm nvcr.io/nvidia/pytorch:22.03-py3
