#!/bin/bash

echo "=== Starting Kubernetes Cleanup ==="

# 1. Reset kubeadm (if cluster was initialized)
echo "Resetting kubeadm..."
sudo kubeadm reset -f

# 2. Stop and disable services
echo "Stopping Kubernetes services..."
sudo systemctl stop kubelet
sudo systemctl disable kubelet
sudo systemctl stop containerd
sudo systemctl disable containerd

# 3. Remove Kubernetes packages
echo "Removing Kubernetes packages..."
sudo apt-mark unhold kubelet kubeadm kubectl
sudo apt-get purge -y kubeadm kubectl kubelet kubernetes-cni
sudo apt-get autoremove -y

# 4. Remove containerd
echo "Removing containerd..."
sudo apt-get purge -y containerd
sudo apt-get autoremove -y

# 5. Clean up configuration files
echo "Removing configuration files..."
sudo rm -rf ~/.kube
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/cni
sudo rm -rf /opt/cni
sudo rm -rf /var/lib/cni
sudo rm -rf /run/flannel
sudo rm -rf /etc/containerd
sudo rm -rf /var/lib/containerd

# 6. Remove module loading configuration
echo "Removing kernel module configs..."
sudo rm -f /etc/modules-load.d/k8s.conf

# 7. Unload kernel modules
echo "Unloading kernel modules..."
sudo modprobe -r overlay 2>/dev/null || true
sudo modprobe -r br_netfilter 2>/dev/null || true

# 8. Remove sysctl configuration
echo "Removing sysctl configs..."
sudo rm -f /etc/sysctl.d/k8s.conf
sudo sysctl --system

# 9. Remove Kubernetes apt repository
echo "Removing Kubernetes apt repository..."
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# 10. Re-enable swap
echo "Re-enabling swap..."
sudo sed -i '/swap/s/^#//' /etc/fstab
sudo swapon -a

# 11. Clean up iptables rules
echo "Flushing iptables rules..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# 12. Remove any remaining network interfaces
echo "Cleaning up network interfaces..."
sudo ip link delete cni0 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true

# 13. Update package cache
echo "Updating package cache..."
sudo apt-get update

# 14. Reboot prompt
echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "Summary of what was removed:"
echo "  - kubeadm, kubectl, kubelet"
echo "  - containerd"
echo "  - All Kubernetes configuration files"
echo "  - Kernel module configurations"
echo "  - Network configurations"
echo "  - Swap has been re-enabled"
echo ""
echo "It's recommended to reboot your system now."
echo "Reboot now? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    sudo reboot
fi
