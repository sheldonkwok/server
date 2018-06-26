# Personal Server

## Terraform

```bash
cd terraform
terraform apply
```

### Issues encountered

AWS keys saved in the environment will override the profile setting in the configuration.
They can be temporarily removed with:

```bash
env -u AWS_ACCESS_KEY_ID -u AWS_SECRET_ACCESS_KEY terraform apply
```

## Ansible

```bash
cd ansible
ansible-playbook -i inventory playbook.yml
```
