# devops-terraform
Demo for terraforming Argo, Drone and deploying applications into them.

There are currently two pipelines:
- terraform - Sets up the initial infrastructure
- terraform_drone_setup - (Needs renaming) Sets up applications and pipelines in Argo and Drone

This split exists as the Argo and Drone providers cannot work without those apps being in place

## Pre-requisites
Certain steps can't be terraformed and need to be carried out prior to running this pipeline

### Argo GitHub integration
You will need to create an OAuth application within GitHub with access to the relevant Organisations.

This allows those with GitHub access to access Argo, levels of access are governed by membership of GitHub groups:

- In GitHub go to your account settings (from menu top right)
- Select *Developer Settings* from the bottom of the menu on the left.
- Select *OAuth Apps* on the right and hit the *New OAuth App* button
- Fill out the form as follows, replace the host name as necessary (in this demo we are using argo.paulpbrandon.uk):

  ![add repo](./img/createOAuth.png)
- You will then see something like this when you register the app:

  ![add repo](./img/createdOAuthApp.png)
- Take note of the client id
- Click the *Generate a new client secret* button, and note down the value you get back (you won't be able to get it later)
- The client and secret values will correspond to the *argo_github_client_id* and *argo_github_client_secret* values in tfvars

### Drone GitHub integration
You will need to do exactly the same as above but for Drone, in order to allow it to build from GitHub repositories.
- The homepage will be https://drone.paulpbrandon.uk
- The callback will be https://drone.paulpbrandon.uk/login
- Again note the client and secret ids and store securely
- The client and secret values will correspond to the *drone_github_client_id* and *drone_github_client_secret* values in tfvars

### Drone token
The pipeline will create an initial drone user that we can then use with the argo provider. 

The token for this user can be generated up front with:
`openssl rand -hex 32`

Store this value securely, this value will go into the **drone_admin_token** variable in tfvars

## Pre-requisites for setup pipeline
These are the steps you should carry out before running the second setup pipeline for the first time

### Login to Drone and Argo
Ensure the GitHub integration works and sort out any final authorisation that may need to be carried out

### Argo restart
It seems to be advisable to hard restart a couple of services after the first pipeline has been run ***for the very first time*** otherwise you may get strange behaviour with Argo SSO:
- `kubectl scale deployment argocd-server --replicas=0 -n argocd`
- `kubectl scale deployment argocd-dex-server --replicas=0 -n argocd`
- Then bring back however many replicas you need

### Argo SSH key
We are configuring Argo to connect to GitHub repositories via SSH, we are going to encrypt it so that it can be stored in this repo safely
- Install kubeseal - `brew install kubeseal`
- Get credentials for cluster - `az aks get-credentials`
- Generate a new key/value pair (e.g. with ssh-keygen)
- Add the public key to a suitable user in GitHub
- Copy this file [argo-github-repo.yaml](./templates/argo-github-repo.yaml)
- Change the repository accordingly and add the private key
- Run `kubeseal --format=yaml <argo-github-repo.yaml >sealed-argo-repo-secret.yaml`
- Copy the **sealed** file into the **secrets** directory and commit this repo (if there are any secrets there already they won't work and file can be removed)

### Argo token
A token is required for the Argo provider to connect to Argo, this can only be done once Argo is deployed. 

This pipeline will create a machine user, but it will not have a token. To get a token:
- Log into Argo
- Navigate to `https://argo.paulpbrandon.uk/settings/accounts/machine` (replace host as necessary)
- Select *Generate New* in the middle of the page (you will need to be part of what GitHub group has been defined as the admin group in Argo this corresponds to the *argo_github_admin_group* variable in tfvars)
- An expiry can be set, but it does mean the pipeline will periodically stop working until you set a new one
- Take note of the token and store securely, this corresponds to **argo_token** variable in tfvars

## Adding applications to Argo
Argo will get the manifest for an application from a git repo. See the [applications.tf](./terraform_drone_setup/applications.tf) file for an example of how to add them from this pipeline.

This demo will currently deploy 2 versions of a helloworld app as defined in https://github.com/nimbleapproach/argo-demo/tree/main/kustomizehelloworld 