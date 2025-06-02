# Terraform Study
# Terraform AWS Infrastructure with Argo CD Integration

This project demonstrates how to use Terraform to provision AWS infrastructure and manage Kubernetes resources with Argo CD. It includes EC2, VPC, networking components, and Kubernetes manifests for namespace and PVC creation.

## 📁 Project Structure

```
terraform-study/
├── README.md                        # Project documentation
├── main.tf                          # Terraform configuration file
├── terraform.tfstate                # Terraform state file (auto-generated)
├── terraform.tfstate.backup         # Terraform state backup (auto-generated)
└── k8s-manifests/                   # Kubernetes manifests
    ├── my-app-pvc.yaml              # PersistentVolumeClaim manifest
    └── my-argo-managed-namespace.yaml  # Namespace managed by Argo CD
```

---

## 🚀 Terraform Setup

### 🔧 Prerequisites

* Terraform installed (`>= 1.0`)
* AWS CLI configured or manually provide AWS credentials
* SSH key pair for EC2 access
* (Optional) A Kubernetes cluster with Argo CD deployed

### 🔐 AWS Credentials

You can configure AWS credentials in `main.tf` (for learning only, not recommended for production):

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "<YOUR_AWS_ACCESS_KEY>"
  secret_key = "<YOUR_AWS_SECRET_KEY>"
}
```

For security, use environment variables or shared credentials in practice.

---

## ⚙️ Terraform Resources

### ✅ EC2 and Network Setup

Terraform creates the following:

* **VPCs**: `prod-vpc`, `terraform-study-vpc`, and `terraform-study-vpc-2`
* **Internet Gateway**
* **Route Table & Association**
* **Subnet**: `prod-subnet-1`
* **Security Group**: Allows SSH (port 22)
* **Key Pair**: For EC2 login
* **EC2 Instance**: Amazon Linux 2 with a basic user-data script

### 💻 EC2 User Data Script

The EC2 instance includes a basic bootstrapping script:

```bash
#!/bin/bash
echo "Hello, World!" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
```

> Note: Install `httpd` in the script if not included in your AMI.

---

## 📦 Kubernetes Manifests (Argo CD Ready)

Inside the `k8s-manifests/` folder:

### 1. PersistentVolumeClaim (`my-app-pvc.yaml`)

Creates a 1Gi volume:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: my-storage-class
```

### 2. Argo CD Managed Namespace (`my-argo-managed-namespace.yaml`)

Namespace configured with annotations for Argo CD:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-argo-managed-namespace
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
    argocd.argoproj.io/resource-ignore: |
      jsonPointers:
      - /metadata/labels/argocd.argoproj.io~1sync-options
      ...
```

> These annotations help Argo CD avoid unnecessary sync diffs on managed fields.

---

## 🛠️ Usage

### Initialize and Apply Terraform:

```bash
terraform init
terraform apply
```

> Confirm the plan and type `yes` to proceed.

---

## 🎯 Argo CD Integration (Optional)

To integrate with Argo CD:

1. Deploy Argo CD in your cluster.
2. Add this project as a Git repo source in Argo CD.
3. Create an `Application` resource pointing to `k8s-manifests/`.

Example `Application` YAML:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/DexRoku/terraform-study.git
    path: k8s-manifests
    targetRevision: HEAD
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 📚 Learnings

* Terraform basics: providers, resources, networking, EC2
* User data for EC2 bootstrapping
* Kubernetes manifests and PVCs
* Argo CD annotations and sync management

---

## ✅ TODO

* [ ] Add outputs and variables to improve reusability
* [ ] Secure credentials using environment variables or `~/.aws/credentials`
* [ ] Expand Kubernetes setup using Helm charts
* [ ] Add monitoring (Prometheus/Grafana)

---

## 🛉️ Cleanup

To destroy all resources:

```bash
terraform destroy
```

---

## 📌 Notes

* Avoid hardcoding credentials in production.
* Use remote state for team collaboration.
* This is a learning project — use modules and backend for real-world scenarios.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
