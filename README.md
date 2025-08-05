# ai-sandpit-agentic-rdc

# Project: AI Sandpit Agentic RDC Infrastructure

This repository contains the Infrastructure as Code (IaC) for the Agentic RDC project, managed with Terraform and deployed on the NeSI OpenStack cloud.

[![Terraform IaC Workflow](https://github.com/njon001/ai-sandpit-agentic-rdc/actions/workflows/terraform.yml/badge.svg)](https://github.com/njon001/ai-sandpit-agentic-rdc/actions/workflows/terraform.yml)

## Overview

The Terraform code in this repository defines and manages all necessary cloud resources, including:
* Compute Instances (VMs)
* Persistent Block Storage (Volumes)
* Networking (Floating IPs)
* Security Groups (Firewall Rules)

## Prerequisites

Before you begin, you will need the following tools installed on your local machine:
* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* [direnv](https://direnv.net/docs/installation.html)
* Your NeSI OpenStack RC file.

## Getting Started

For a complete guide on setting up your local environment, deploying the infrastructure for the first time, and accessing the resources, please see our **[Getting Started Guide](./docs/01-getting-started.md)**.

## Documentation

All detailed project documentation can be found in the [`/docs`](./docs) directory.
