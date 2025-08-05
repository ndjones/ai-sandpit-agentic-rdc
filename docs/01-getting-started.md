# 1. Getting Started Guide

This guide provides step-by-step instructions to set up your local development environment and deploy the project's infrastructure on the NeSI OpenStack cloud.

### Step 1: Prerequisites

Ensure you have the following installed:
* **Terraform:** [Installation Guide](https://developer.hashicorp.com/terraform/downloads)
* **direnv:** [Installation Guide](https://direnv.net/docs/installation.html)
* **OpenStack Client (for verification):** Requires Python.
    ```bash
    # Recommended: use a Python virtual environment
    python3 -m venv .venv
    source .venv/bin/activate
    pip install python-openstackclient
    ```

You must also have downloaded your `openrc.sh` file from the NeSI OpenStack dashboard.

### Step 2: Local Environment Setup

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/njon001/ai-sandpit-agentic-rdc.git](https://github.com/njon001/ai-sandpit-agentic-rdc.git)
    cd ai-sandpit-agentic-rdc
    ```

2.  **Configure Environment Variables:**
    Create a file named `.envrc` in the root of the repository. Copy the `export` commands from your downloaded `openrc.sh` file into it. It should look like this:
    ```bash
    # .envrc
    export OS_AUTH_URL="[https://keystone.akl-1.cloud.nesi.org.nz](https://keystone.akl-1.cloud.nesi.org.nz)"
    export OS_IDENTITY_API_VERSION=3
    export OS_PROJECT_NAME="[Your NeSI Project Name]"
    export OS_PROJECT_ID="[Your NeSI Project ID]"
    export OS_USERNAME="[Your NeSI Username]"
    export OS_USER_DOMAIN_NAME="[Your User Domain Name]"
    export OS_PASSWORD="[Your OpenStack API Password]"
    export OS_REGION_NAME="akl-1"

    echo "NeSI OpenStack environment loaded for project: $OS_PROJECT_NAME"
    ```

3.  **Activate `direnv`:**
    Run the following command to allow `direnv` to load the variables.
    ```bash
    direnv allow .
    ```

### Step 3: SSH Key Setup

You need an SSH key to access the compute instances.
1.  **Generate a new key:**
    ```bash
    # This creates a private (nesi_key) and public (nesi_key.pub) key pair.
    ssh-keygen -t ed25519 -f ./nesi_key -C "your_email@example.com"
    ```
2.  **IMPORTANT:** The private key (`nesi_key`) is automatically ignored by the `.gitignore` file. Never commit a private key.

### Step 4: Verify OpenStack Connection

Before using Terraform, verify that your credentials are correct using the OpenStack Client.
```bash
# Ensure your direnv and python environments are active
openstack token issue
```
If this command succeeds and shows you a token, your authentication is working.

### Step 5: Deploying with Terraform

1.  **Initialize Terraform:**
    This downloads the required OpenStack provider. The `-upgrade` flag ensures you have the latest compatible version.
    ```bash
    terraform init -upgrade
    ```

2.  **Plan the Deployment:**
    This command shows you what changes Terraform will make to your cloud infrastructure without actually doing anything. It's a critical review step.
    ```bash
    terraform plan
    ```

3.  **Apply the Changes:**
    This command executes the plan and builds the infrastructure.
    ```bash
    terraform apply
    ```
    Terraform will show the plan again and ask for confirmation. Type `yes` to proceed.

### Step 6: Accessing the Instance

1.  **Get the Floating IP:** After `terraform apply` completes, the public IP address will be displayed in the `Outputs:` section.

2.  **Connect via SSH:** Use the IP address and the SSH key you generated. The default user for the Ubuntu image is `ubuntu`.
    ```bash
    ssh -i ./nesi_key ubuntu@<your_floating_ip>
    ```

### Step 7: CI/CD with GitHub Actions

This repository is configured to automatically manage infrastructure via GitHub Actions.
* **GitHub Secrets:** Your `OS_PASSWORD` and other credentials must be added to the repository's **Settings > Secrets and variables > Actions** page.
* **Workflow:**
    * When a **Pull Request** is created, the workflow runs `terraform plan` to show the proposed changes.
    * When a commit is **merged into the `main` branch**, the workflow runs `terraform apply` to deploy the changes automatically.