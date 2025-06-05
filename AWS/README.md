# AWS Skeleton

```bash
# list profile
aws configure list

# configure profile
aws configure --profile <profile_name>

# active profile 
export AWS_DEFAULT_PROFILE=<profile_name>

aws sso login
```

## Using EKS

```bash
aws eks update-kubeconfig --region region-code --name my-cluster
```
