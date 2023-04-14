# Fragmenty

## What is the project?

This is a small side project that crawls the [Fragment](fragment.com/numbers) Telegram platform to extract data about phone numbers, and provides a RESTful API, WebSocket API, and visualization of the data through a chart.

The goal of this project is to extract data and basic insights about Telegram numbers auction, also learn more about the Play framework, Scala, Terraform and AWS.

## Stack:

- [Scrapy framework](https://docs.scrapy.org/en/latest/) and Python language for Crawler part
- [Play framework](https://www.playframework.com/documentation/2.8.x/ScalaHome) and Scala language for API server
- [Plotly](https://plotly.com/graphing-libraries/) for data visualization
- [MongoDB](https://www.mongodb.com/docs/) as data persistence
- [Terraform](https://terraform.io/) infrastructure automation for provisioning
- [AWS service](https://aws.amazon.com/) cloud infrastructure
- [MongoDB Atlas](https://www.mongodb.com/atlas/database) cloud database service

## Infrastructure Architecture

![AWS Infrastructure Architecture](https://user-images.githubusercontent.com/9904514/232056685-59e7a744-c581-41db-be9c-7eca62dd7f5d.png)

This project uses Amazon Web Services (AWS) for infrastructure provisioning. The infrastructure is organized into different components, with each component residing in its own directory under the `fragmenty-infra` directory.

### Components:

1. Elastic Container Service (ECS) - Deploy and manage the containerized applications
2. MongoDB Atlas - Host the MongoDB instance for data persistence

#### Elastic Container Service (ECS)

The ECS infrastructure is set up using Terraform and includes the following resources:

- Elastic Container Registry (ECR) for storing container images
- ECS Cluster, ECS Service, and ECS Task Definition for running the containerized applications
- AWS Lambda for running the Scrapy crawler periodically
- Application Load Balancer (ALB) for distributing traffic to the ECS tasks
- Route 53 for managing DNS records
- AWS Certificate Manager (ACM) for SSL certificate provisioning

#### MongoDB Atlas

The MongoDB Atlas infrastructure is also set up using Terraform and consists of the following resources:

- MongoDB Atlas Cluster
- MongoDB Atlas Database Users

![graphviz terraform graph](https://user-images.githubusercontent.com/9904514/232057419-4d79fc97-0260-49de-a5d0-e5ec9e804178.svg)
<p align="center">
  Visualized Terraform graph
</p>


## Deployment Workflow

The deployment process is automated using Terraform. The `external.tf` file is used to extract the latest Git commit SHA for the `spider` and `api` modules. These SHAs are used as container image tags. Terraform uses `container_build_push.tf` to build and push the container images to the ECR. The `ecs.tf` file contains the resources required to run the containerized applications on ECS.

The Lambda function, defined in `lambda.tf`, is responsible for running the Scrapy crawler periodically. The function is triggered by a CloudWatch Event Rule that specifies the desired frequency.

The `loadbalancer.tf` file defines an Application Load Balancer (ALB) that routes traffic to the ECS tasks. Route 53 is used to create a custom domain name and an SSL certificate, as specified in the `route53.tf` file.

## Git Submodules

This project consists of two Git submodules:

1. [fragmenty-api](https://github.com/Maders/fragmenty-api.git) - This submodule contains the source code for the API server, which is built using the Play framework and Scala. The `fragmenty-api` directory contains a Dockerfile for building the container image, configuration files, and the application's source code.

2. [fragmenty-spider](https://github.com/Maders/fragmenty-spider.git) - This submodule contains the source code for the Scrapy crawler that extracts data from Telegram's Fragment platform. The `fragmenty-spider` directory contains a Dockerfile for building the container image, a build script, a sample environment file, and the Scrapy spider's source code.

These submodules are automatically checked out when the main repository is cloned with the `--recurse-submodules` option:

```sh
git clone --recurse-submodules https://github.com/Maders/fragmenty.git
```

## Useful Commands

To apply the infrastructure changes, run the following command in the respective directories:

```sh
terraform apply
```

To destroy the infrastructure resources, run the following command in the respective directories:

```sh
terraform destroy
```
