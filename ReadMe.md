# Plane on AWS ECS with Terraform

This project brings together Docker, Amazon ECS Fargate, Terraform and CI/CD to self-host [Plane Community Edition](https://plane.so/) on AWS.

I chose Plane because I use it to manage my dissertation timeline. It helps me break the project into tasks, organise milestones and track my progress towards submission. Hosting it myself gives me a practical reason to build and maintain the infrastructure behind the application.

**Application domain:** [tm.saeedproject.com](https://tm.saeedproject.com)

## Technology stack


### Infrastructure and deployment

![Infrastructure and deployment](https://skillicons.dev/icons?i=aws,docker,terraform,bash,githubactions)

### Database and messaging

![Database and messaging](https://skillicons.dev/icons?i=postgres,redis,rabbitmq)

## Contents

- [Overview of my setup](#overview-of-my-setup)
- [Project Architecture](#project-architecture)
- [Application services](#application-services)
- [CI/CD workflow](#cicd-workflow)
- [IAM and CircleCI authentication](#iam-and-circleci-authentication)
- [Reproducing the setup](#reproducing-the-setup)
- [Deployment verification and screenshots](#deployment-verification-and-screenshots)
- [Challenges and lessons learned](#challenges-and-lessons-learned)
- [Cost and clean-up](#cost-and-clean-up)

## Overview of my setup

My Terraform design places the application in a custom VPC across three Availability Zones, with three public subnets and three private subnets. An internet-facing Application Load Balancer accepts HTTPS requests in the public subnets and forwards them to Plane workloads running on ECS Fargate in the private subnets.

My NAT gateway is located in Public Subnet 1 (`10.0.1.0/24`) in `eu-west-2a`. The private subnets use routes pointing to this gateway when their workloads need internet access. The gateway forwards that traffic through the VPC internet gateway, allowing the ECS tasks to make outbound connections while remaining in private subnets. I chose one NAT gateway to reduce costs while maintaining outbound internet access.

I chose ECS Fargate because Plane has several connected services: user interfaces, an API, real-time collaboration, background workers and database migrator. Fargate lets me run those containers without managing the underlying EC2 hosts. ECS also provides service scheduling, health monitoring and rolling deployments. This gives me practical experience with container orchestration while keeping the infrastructure manageable for a personal project. I am the main user of the environment, although Plane is also suitable for students, researchers and small teams organising their work.

| Component | Role in my design |
| --- | --- |
| Docker | Packages Plane services using my custom Dockerfiles |
| Terraform | Defines and provisions the AWS infrastructure |
| Custom VPC | Separates public entry points from private workloads |
| Application Load Balancer | Routes incoming HTTPS requests to healthy application targets |
| ECS Fargate | Runs Plane containers without EC2 host administration |
| ECR | Stores application images for deployment |
| Cloudflare | Hosts the parent domain's DNS and delegates the application subdomain to Route 53 |
| Route 53 and ACM | Provide application DNS and the ALB's TLS certificate |
| NAT gateway | Provides outbound internet connectivity for private workloads |
| RDS PostgreSQL | Provides the application's relational database |
| ElastiCache Valkey | Provides Redis-compatible caching |
| RabbitMQ on ECS | Provides messaging for background processing |
| Object storage | Stores upload application files |
| CloudWatch | Collects container logs for troubleshooting |
| GitHub Actions | Validates changes pushed to GitHub |
| CircleCI | Builds container images and initiates ECS deployments |
| IAM OIDC provider and deployment role | Establish CircleCI's AWS access through temporary credentials |
| S3 remote state | Stores Terraform state centrally with state locking |

## Project Architecture

![Project Architecture](/Images/ECS%20Project%20Architecture.png "Project Architecture")

Route 53 resolves the application domain to the ALB. The browser connects to the ALB over HTTPS, using the certificate issued through ACM. The ALB then routes the request to a healthy application target in the private subnets.

The NAT gateway serves a separate purpose as it allows private workloads to initiate outbound internet connections. Application requests reach the containers through the ALB. Security groups control which connections are permitted between the load balancer, application and other services.

CircleCI runs outside the VPC. Its access to ECR and the ECS deployment APIs uses an IAM OpenID Connect (OIDC) provider and a deployment role at the AWS account level. These are separate from the application's inbound and outbound network paths.

### Terraform state

My remote-state configuration uses S3 with encryption and S3 lock files. The backend bucket is separate from application storage and must exist before Terraform initialises the backend. The state key is `plane/prod/terraform.tfstate` in `eu-west-2`.

## Application services

| Service | Purpose |
| --- | --- |
| `web` | Main Plane interface for projects, tasks and milestones |
| `admin` | Instance administration and God Mode |
| `space` | Public and shared content interface |
| `api` | Backend application logic and API endpoints |
| `live` | Real-time collaboration |
| `worker` | Asynchronous background processing |
| `beat-worker` | Scheduled background processing |
| `migrator` | One-off database schema migrations |

I build the application images from the Plane source using custom Dockerfiles. The application depends on PostgreSQL, Valkey, RabbitMQ and object storage in addition to the user-facing services.

## CI/CD workflow

My workflow starts when I push a commit to GitHub. GitHub Actions runs the repository validation workflow, while CircleCI handles the container build and deployment workflow for the configured deployment branch. Terraform defines the AWS infrastructure, ECR stores the images and ECS performs the rolling deployment.

The release sequence is:

1. I commit my changes locally and push them to GitHub.
2. GitHub Actions runs the validation checks defined in the repository workflow.
3. The GitHub push also triggers the configured CircleCI pipeline for the deployment branch.
4. CircleCI exchanges its OIDC token for temporary AWS credentials through the IAM deployment role.
5. CircleCI builds the application images using my custom Dockerfiles, tags them with the commit identifier and pushes them to ECR.
6. The deployment job prepares ECS task-definition revisions that reference the new images.
7. A one-off migration task runs before the application rollout when database schema changes are required.
8. CircleCI updates the ECS services, and ECS replaces the tasks through a rolling deployment.
9. Service stability and application checks confirm the result of the rollout.

GitHub Actions validation and CircleCI are separate workflows triggered by the GitHub event. This design does not establish a dependency between their results.

Pushing an image to ECR stores the new build. The subsequent ECS service update deploys it to the running application.

## IAM and CircleCI authentication

The CI/CD design uses OIDC federation for CircleCI's AWS access, avoiding stored, long-lived AWS access keys. The IAM identity provider identifies CircleCI as a trusted token issuer; the deployment role defines the access granted to a qualifying job.

| Setting | Configuration |
| --- | --- |
| Identity provider type | OpenID Connect (OIDC) |
| Provider URL | `https://oidc.circleci.com/org/<circleci-organisation-id>` |
| Audience | CircleCI organisation ID |
| Role trust | CircleCI provider, with audience and project restrictions |
| Role assumption action | `sts:AssumeRoleWithWebIdentity` |

The organisation and project IDs are CircleCI identifiers, separate from the AWS account ID. The role's trust policy controls which jobs can assume it while the permissions policy controls the AWS operations those jobs can perform.

AWS Security Token Service (STS) validates the job's token against the configured trust relationship and returns temporary credentials. CircleCI uses those credentials for the permitted build and deployment operations.

### Deployment permissions

The deployment role's permission requirements cover ECR authentication and image pushes, ECS task-definition registration, migration task execution, service updates and deployment status checks. Passing the task and execution roles to ECS requires `iam:PassRole`, restricted to the roles used by this application. Resource restrictions apply wherever the AWS action supports them.

### Separate roles for deployment and runtime

| IAM role | Purpose |
| --- | --- |
| CircleCI deployment role | Allows pipeline jobs to publish images and deploy the application |
| ECS task execution role | Allows the ECS agent to pull images, publish container logs and retrieve referenced secrets when configured |
| ECS task role | Grants application code inside a running container access to the AWS services it needs |

Terraform provisioning uses the AWS identity running Terraform. Infrastructure permissions are separate from the release permissions described above.

## Reproducing the setup

### Running the Application Locally

Copy and configure the example environment file from `app/.env.example` to `app/.env`, update the required local values, then start the Plane stack with Docker Compose:

```bash
cd app
# To start Plane stack container:
docker compose up -d --build
# To stop and remove container:
docker compose down
```

### 1. Tools and AWS access

My local workflow uses Git, Docker with Compose, AWS CLI v2 and Terraform. CircleCI is connected to the application repository, and my AWS CLI profile is `plane-ecs`.

```bash
git clone <repository-url>
cd <repository-directory>
export AWS_PROFILE=plane-ecs
export AWS_DEFAULT_REGION=eu-west-2
aws sts get-caller-identity
```

The identity check confirms which AWS account and role the local deployment commands use.

### 2. Remote-state backend

The backend depends on an existing S3 bucket with versioning, encryption and public access blocking. Its configuration follows this structure, with a globally unique bucket name for the environment:

```hcl
terraform {
  backend "s3" {
    bucket       = "<state-bucket-name>"
    key          = "plane/prod/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
```

The state bucket remains available throughout deployment and clean-up. Credentials and sensitive variable values belong outside the repository.

### 3. Infrastructure configuration

My environment configuration covers the AWS region, VPC and subnet ranges, application domain, image references, task sizes and supporting services. I use `terraform.tfvars` for environment-specific values, with variable names and types defined in the root module's `variables.tf`.

The network design uses the following values:

| Setting | Value |
| --- | --- |
| Region | `eu-west-2` |
| Application domain | `tm.saeedproject.com` |
| VPC CIDR | `10.0.0.0/16` |
| Availability Zones | `eu-west-2a`, `eu-west-2b`, `eu-west-2c` |
| Public subnets | `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24` |
| Private subnets | `10.0.4.0/24`, `10.0.5.0/24`, `10.0.6.0/24` |

Credentials and secret values remain outside version control. Backend settings are defined separately from `terraform.tfvars`.

With the environment values configured, the Terraform commands are:

```bash
cd infra
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

`terraform init` initialises the backend and providers. The formatting and validation checks run before the plan. Review the saved plan before applying it so that the changes being applied are the changes you have inspected.

The initial deployment depends on image availability: ECR repositories and initial images must be ready before ECS can start tasks that reference them. The CircleCI OIDC provider and deployment role must also exist before the first authenticated pipeline run.

### 4. DNS and HTTPS

My application hostname is `tm.saeedproject.com`. The DNS design uses a delegated Route 53 zone for the application subdomain, with delegation configured at the parent domain's DNS provider. Route 53 points the application hostname to the ALB, and ACM supplies the certificate for the HTTPS listener.

DNS delegation and certificate validation must complete before HTTPS verification can succeed.

### 5. CircleCI AWS access

The pipeline's AWS authentication configuration consists of the IAM OIDC provider, role trust policy, deployment permissions and deployment role ARN. The CircleCI job authenticates before calling ECR or ECS. The provider URL and audience use the CircleCI organisation ID, while the role trust also restricts access to the project.

The job configuration supplies the role ARN, AWS region, ECR repositories, ECS cluster, service identifiers and task definitions used by the release. An `aws sts get-caller-identity` check within the authenticated job identifies the assumed role.

### 6. Application deployment

A deployment-branch change starts the build and release workflow described above.

The deployment is ready for application testing when the migration task has succeeded, the ECS services have stabilised and the relevant ALB targets are healthy.

## Deployment verification and screenshots

I verified the application through its HTTPS domain during the initial console deployment. That environment has since been removed. Screenshots of the complete Terraform deployment can be found in Images folder.

My verification covers the following:

| Check | Result I am verifying |
| --- | --- |
| Public HTTPS endpoint | Plane loads through `tm.saeedproject.com` with a trusted certificate |
| ECS services | Desired and running task counts match and services remain stable |
| ALB target groups | Application targets report healthy |
| CircleCI workflow | Image builds, ECR pushes and ECS deployment jobs complete successfully |
| CircleCI AWS identity | The authenticated job assumes the intended IAM deployment role |
| Application behaviour | I can open my workspace and create or update dissertation tasks |
| Container logs | No recurring startup, connection or application errors |
| God Mode redirect | The redirect retains HTTPS without exposing internal port `3000` |

My public endpoint checks are:

```bash
curl -I https://tm.saeedproject.com
curl -I https://tm.saeedproject.com/api/instances/
curl -I https://tm.saeedproject.com/god-mode/
```

## Challenges and lessons learned

### Choosing health-check endpoints

I learned that a running container can still fail a health check. The route, listening port and expected response all matter: a missing endpoint, authentication requirement or redirect can make a check fail even when the process is running.

Plane’s Commercial Edition provides dedicated health-check endpoints, including `/api/live/`, `/api/ready/` and `/api/health/`. Community Edition does not include these dedicated probes, although it provides a basic API root check at `/`. In my deployment, I used `/api/instances/` as the API target group’s health-check path, with HTTP `200` as the expected success code. The logs confirmed successful responses from this endpoint, demonstrating that the API could respond to requests without establishing the health of every application dependency.

### Adjusting the health-check threshold

During deployment, the service was being reported as unhealthy. After I increased the health-check threshold, the service became healthy. This taught me that health-check configuration can affect how a deployment is evaluated, alongside the application's endpoint and response.

This also helped me distinguish thresholds from startup grace periods. The unhealthy threshold controls consecutive failures before a target becomes unhealthy; the healthy threshold controls successful checks needed for recovery. The ECS health-check grace period separately controls how long the scheduler ignores unhealthy checks after a task starts.

### Separating image delivery from deployment

I learned that uploading an image to ECR is only one stage of a release. The ECS service must use the new image reference before the application changes. This distinction shaped my CircleCI workflow: build and push the images, then update the task definitions and services and check the rollout.

### Understanding the request path

Working through the architecture helped me distinguish incoming requests through the ALB from outgoing connections through NAT. It also taught me to test application redirects as well as the homepage. The `/god-mode` issue showed that a working HTTPS page can coexist with an incorrect redirect that exposes an internal port.


## Cost and clean-up

This is a personal learning environment, so I balance availability with running costs. The single NAT gateway is one example of that trade-off. Spreading subnets across three Availability Zones provides a foundation for resilience, but actual application availability also depends on task placement, replica counts and the configuration of the data services.

When I no longer need the environment, my clean-up sequence is:

```bash
# From the infra root
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

I review the destruction plan and retain any required database backups or uploaded files before removing stateful resources. The remote-state bucket stays available until the managed infrastructure has been removed and Terraform has recorded the final state.

---

Plane is developed by its upstream contributors. This repository documents my infrastructure and deployment work; Plane retains its original licence and attribution requirements.