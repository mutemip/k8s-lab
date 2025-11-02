# Initialize with Calico's recommended pod network CIDR
sudo kubeadm init --apiserver-advertise-address=192.168.5.5 --pod-network-cidr=192.168.0.0/16

# Set up kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sleep 5
# Verify control plane is up
kubectl get nodes

sleep 5

# Install Calico operator and custom resource definitions
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

# Download the custom resources manifest
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O

# Apply the custom resources (this creates the Calico installation)
kubectl create -f custom-resources.yaml

# Watch Calico pods come up (this may take 2-3 minutes)
watch kubectl get pods -n calico-system

# Or without watch:
kubectl get pods -n calico-system -w
# Press Ctrl+C when all pods show Running status