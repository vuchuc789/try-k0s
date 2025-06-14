# Try K0s

### Commands

```
ssh-keygen -t ed25519 -C "vuchuc"

terraform plan
terraform apply

ansible-playbook servers.yml -f 3 --check --diff
ansible-playbook servers.yml -f 3

k0sctl apply --config k0sctl.yaml
k0sctl kubeconfig > kubeconfig

export KUBECONFIG=$(pwd)/kubeconfig
kgno -o wide
```

_It's quite fun, tbh_
