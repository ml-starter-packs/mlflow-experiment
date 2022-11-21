#!/bin/sh

echo Tracking URI: ${MLFLOW_TRACKING_URI}
echo "Creating environment"
pip install --quiet mlflow[extras]~=1.27 boto3

echo "Setting credentials"
mkdir -p ~/.aws
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF

echo "Running example"
mlflow run --env-manager=local https://github.com/mlflow/mlflow-example.git -P alpha=0.42 --run-name test-example

echo "Serving latest trained model"
mlflow runs list --experiment-id 0
LATEST_RUN_ID=`mlflow runs list --experiment-id 0 | head -3 | tail -1 | awk '{print $5}'`
mlflow models serve --env-manager=local -m "s3://mlflow/0/${LATEST_RUN_ID}/artifacts/model" -p 1234 -h 0.0.0.0
