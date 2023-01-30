wget -qO - https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
export AWS_DEFAULT_REGION=eu-west-3
sudo apt install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt install -y unzip gitlab-runner jq \
                    docker.io maven kubectl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

mkdir ~/.m2
aws s3 cp s3://anesthesia-config/maven_settings.xml ~/.m2/settings.xml
aws s3 cp s3://anesthesia-config/aws_credentials ~/.aws/credentials
aws s3 cp s3://anesthesia-config/aws_config ~/.aws/config

aws eks --region eu-west-3 update-kubeconfig --name anesthesia-eks-adeg3r0t

gitlab_runner_token=$(aws secretsmanager get-secret-value --secret-id gitlab/runner/token --query SecretString --output text | jq -r '.gitlab_runner_registration_token_anesthesia')
sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --registration-token $gitlab_runner_token \
  --description "gitlab-runner" \
  --executor "docker" \
  --docker-image ubuntu:latest