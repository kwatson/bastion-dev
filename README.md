# Simple SSH Bastion Container

Simple bastion container with some dev tools installed.

```bash
docker build \
  --build-arg default_ssh_key="YOUR SSH PUBLIC KEY" \
  --build-arg motd="SSH Bastion" \
  -t my-ssh-bastion:latest .
```
