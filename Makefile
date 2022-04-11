run:
	docker-compose run nlp

start:
	docker-compose up -d --build


# TODO: docker-compose support for GPU?
#gpu-test:
#	docker run --gpus all -it --rm nvcr.io/nvidia/pytorch:22.03-py3
