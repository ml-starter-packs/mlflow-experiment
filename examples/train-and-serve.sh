#!/bin/sh

echo "Creating environment"
pip install --quiet mlflow[extras] boto3

export MLFLOW_TRACKING_URI=http://web:5000
export MLFLOW_S3_ENDPOINT_URL=http://minio:9000

echo "Setting credentials"
mkdir -p ~/.aws
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id=minio
aws_secret_access_key=minio123
EOF

echo "Running example"
mlflow run --no-conda https://github.com/mlflow/mlflow-example.git -P alpha=0.42

echo "Serving latest trained model"
LATEST_RUN_ID=`mlflow runs list --experiment-id 0 | head -3 | tail -1 | awk '{print $4}'`
mlflow models serve --no-conda -m "s3://mlflow/0/${LATEST_RUN_ID}/artifacts/model" -p 1234 -h 0.0.0.0
