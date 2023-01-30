aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

kubectl get configmap -n kube-system aws-auth -o yaml | grep -v "creationTimestamp\|resourceVersion\|selfLink\|uid" | sed '/^  annotations:/,+2 d' > aws-auth.yaml

cat << EoF >> aws-auth.yaml
data:
  mapUsers: |
    - groups:
      - system:masters
      userarn: arn:aws:iam::502802710160:user/aseef.ahmed
      username: aseef.ahmed
    - groups:
      - system:masters
      userarn: arn:aws:iam::502802710160:user/orestes.polyzos
      username: orestes.polyzos
    - groups:
      - system:masters
      userarn: arn:aws:iam::502802710160:user/antonis.papakonstantinou
      username: antonis.papakonstantinou
    - groups:
      - system:masters
      userarn: arn:aws:iam::502802710160:user/gitlab-runner
      username: gitlab-runner
EoF

kubectl apply -f aws-auth.yaml

cat << EoF > rbac-cluster-role.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list","get","watch"]
- apiGroups: ["extensions","apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]
EoF

cat << EoF > rbacuser-cluster-role-binding.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-role-binding
subjects:
- kind: Group
  name: developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-role
  apiGroup: rbac.authorization.k8s.io
EoF

kubectl apply -f rbac-cluster-role.yaml
kubectl apply -f rbacuser-cluster-role-binding.yaml

rm aws-auth.yaml rbac-cluster-role.yaml rbacuser-cluster-role-binding.yaml
echo "Installing Matrics Server on k8s ......"
kubectl apply -f k8s/metrics_server.yaml
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.eu-west-3.amazonaws.com/eks/aws-efs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=efs-csi-controller-sa
