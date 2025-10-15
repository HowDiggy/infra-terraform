#!/usr/bin/env bash
set -euo pipefail
terraform fmt -recursive
terraform init -upgrade
terraform validate
terraform plan
