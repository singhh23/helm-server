# helm-servers

Initial install:
- Get docker for windows and enable kubernetes
- Install helm (https://helm.sh/docs/intro/install/)
- Manually install argocd:
    - `kubectl create namespace argocd`
    - `helm install argocd argo-cd/ --namespace argocd`
- Install the argocdcli:
    - `curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64`
    - `sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd`
    - `rm argocd-linux-amd64`
- Update admin password:
    - `argocd admin initial-password -n argocd`
    - `argocd login localhost:30443`
    - `argocd account update-password`
- Bootstrap argocd into argocd
    - Go to https://<ip>:30443/
    - Use 'admin' and new password to login
    - Add this repo via Settings -> Repositories using a private ssh key
    - Add the argocd application using the correct folder - you must use the name `argocd`

For sabnzbd:
    - Create a folder: c:/sabnzbd
    - To change (e.g. d:/sabnzbd), update 'winPath' field in sabnzbd/values.yaml

For referencing each other:
    - use `<service-name>.<namespace>.svc.cluster.local:<targetPort, NOT nodePort>`
    - e.g.: `sabnzbd.sabnzbd.svc.cluster.local:10097`
