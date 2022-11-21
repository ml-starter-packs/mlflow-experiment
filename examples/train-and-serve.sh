#!/bin/sh

source .env
echo "Creating environment"
pip install --quiet mlflow[extras] boto3

echo "Setting credentials"
mkdir -p ~/.aws
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF

echo "Running example"
mlflow run --no-conda https://github.com/mlflow/mlflow-example.git -P alpha=0.42

echo "Serving latest trained model"
LATEST_RUN_ID=`mlflow runs list --experiment-id 0 | head -3 | tail -1 | awk '{print $4}'`
mlflow models serve --no-conda -m "s3://mlflow/0/${LATEST_RUN_ID}/artifacts/model" -p 1234 -h 0.0.0.0
