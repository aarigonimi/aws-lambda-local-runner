# AWS Lambda (Python) in a Docker Container — Run Locally, Deploy Optionally

This example shows how to build a Python AWS Lambda function as a Docker image, run it entirely locally with Docker (no AWS account required), and optionally deploy it to AWS when ready.

## What you get

- Containerized Lambda using the official `public.ecr.aws/lambda/python:3.11` base image
- Ready-to-run local setup with simple scripts
- Minimal sample handler returning structured JSON
- Optional AWS CLI setup and deploy steps with safe placeholders

## Repository layout

- `Dockerfile` — Container image definition (Lambda base + your code)
- `lambda_function.py` — Sample Lambda function handler
- `requirements.txt` — Python dependencies (empty by default)
- `test_event.json` — Example event for local testing
- `run_local.sh` — Build and run the container locally
- `test_function.sh` — Hit the local endpoint with a few test events

## Prerequisites (local-only)

- Docker
  - macOS: Docker Desktop (`brew install --cask docker`) or Colima (`brew install colima docker && colima start`)
  - Linux/Windows: Install Docker Engine or Docker Desktop
- No AWS account or AWS CLI is required for local testing

Verify Docker works:
```bash
docker --version
docker run hello-world
```

## Quick start (no AWS required)

```bash
# From this folder
./run_local.sh
# In another terminal, send test requests
./test_function.sh
```

- The container listens at `http://localhost:9000` (Lambda emulator HTTP endpoint)
- Or use curl directly:
```bash
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -H "Content-Type: application/json" \
  -d @test_event.json
```

## Expected response

A 200 response with a JSON body similar to:
```json
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"message\": \"Hello, World!\", ... }"
}
```

## How it works

- The image uses `public.ecr.aws/lambda/python:3.11`, which includes the Lambda Runtime Interface Client.
- Your handler is set via the image `CMD` to `lambda_function.lambda_handler`.
- When you `docker run -p 9000:8080 ...`, the Lambda runtime exposes an HTTP endpoint to invoke your function locally.

## Customize

- Add dependencies to `requirements.txt`, then rebuild:
```bash
docker build -t test-lambda .
```
- Modify your handler in `lambda_function.py` and rebuild to pick up changes.

---

## Optional: Set up AWS credentials (for deployment)

If you want to deploy to AWS later, set up the AWS CLI and credentials.

1) Install AWS CLI v2
- macOS (Homebrew): `brew install awscli`
- Other platforms: see `https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html`

2) Configure credentials
```bash
aws configure
# Provide AWS Access Key ID, Secret Access Key, default region (e.g., us-east-1), and output format (e.g., json)
```

3) Confirm identity
```bash
aws sts get-caller-identity
```

> Tip: For best practices, use IAM users/roles with least-privilege and avoid committing any secrets.

## Optional: Push image to Amazon ECR

Replace placeholders before running commands:
- `ACCOUNT_ID` — your AWS account ID (12 digits)
- `REGION` — e.g., `us-east-1`
- `REPO` — ECR repository name (e.g., `test-lambda`)

```bash
# Create (or ensure) an ECR repository
aws ecr create-repository --repository-name $REPO --region $REGION || true

# Authenticate Docker to ECR
aws ecr get-login-password --region $REGION \
  | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Tag and push
docker tag test-lambda:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest
```

## Optional: Create the Lambda function from the image

Placeholders to replace:
- `ACCOUNT_ID`, `REGION`, `REPO` as above
- `ROLE_ARN` — an IAM role with a trust policy for Lambda and a basic execution policy (e.g., CloudWatch logs)
- `FUNCTION_NAME` — your Lambda name (e.g., `test-lambda`)

```bash
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --package-type Image \
  --code ImageUri=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest \
  --role $ROLE_ARN \
  --region $REGION
```

Update code later by pushing a new image tag, then running `aws lambda update-function-code --function-name $FUNCTION_NAME --image-uri ...`.

---

## Troubleshooting

- Port in use: change `-p 9000:8080` to another host port (e.g., `-p 9001:8080`).
- Docker not running: start Docker Desktop (macOS: `open -a Docker`) or start your Docker service.
- Cannot reach `localhost:9000`: check `docker ps` and container logs `docker logs <container>`.
- Permissions (AWS deploy): ensure your IAM user/role has ECR and Lambda permissions.

## FAQ

- Do I need AWS to run locally?  
  No, Docker-only is enough.

- Why is the image ~1GB?  
  The Lambda base image includes runtime components. Multi-stage builds won’t reduce the base image; keep dependencies minimal.

- Can I use a different Python version?  
  Yes, change the tag in the `FROM` line, e.g., `python:3.12` if supported by Lambda.

- Do I need the Runtime Interface Emulator (RIE)?  
  The official Lambda base image already includes the runtime client. Using Docker as shown is sufficient for local HTTP invocations.

## License

MIT — use freely with attribution.
