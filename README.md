# azure-revdepcheck

Setting up a machine for revdepchecks on Azure, based on [a "Getting started" example](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-create-complete-vm) and [Rocker](https://github.com/rocker-org).

## Setup

1. In `tf`, copy `terraform.tfvars.example` to `terraform.tfvars`, populate variable names following [Azure instructions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure).

2. Run the following commands to provision the machine:
    
    ```sh
    cd tf
    terraform init
    terraform apply
    ```
    
    When the provisioning is finished, the `cloud-init` script that installs Docker and starts the containers still may be running.

3. When done, an `ssh` command is printed on the terminal that allows entering the machine. Ingress HTTP is not allowed, RStudio must be accessed through tunneling.

4. To destroy the machine, run `terraform destroy` in the `tf` directory. To recreate again, run `terraform apply`.
