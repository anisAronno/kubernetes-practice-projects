# Laravel Kubernetes Deployment

This repository contains a Laravel application configured for deployment on Kubernetes. The setup includes MySQL, Redis, Nginx with a load balancer, and PHPMyAdmin.

## Prerequisites

- Docker installed and running
- Minikube installed
- kubectl CLI installed
- Basic knowledge of Kubernetes concepts

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/anisAronno/kubernetes-practice-projects.git
cd kubernetes-practice-projects
```

### 2. Start Minikube

```bash
minikube start
```

Verify Minikube is running:
```bash
minikube status
```

### 3. Deploy the Application

The configuration files are organized in the `k8s` directory. Deploy them step by step:

#### Create Namespace

```bash
kubectl apply -f k8s/namespace.yaml
```

Verify the namespace was created:
```bash
kubectl get namespaces
# You should see 'laravel-app' in the list
```

#### Create Secrets

```bash
kubectl apply -f k8s/mysql-secret.yaml
kubectl apply -f k8s/laravel-env-secret.yaml
kubectl apply -f k8s/redis-secret.yaml
```

Verify secrets were created:
```bash
kubectl get secrets -n laravel-app
# You should see all three secrets listed
```

#### Create Storage Resources

```bash
kubectl apply -f k8s/storage.yaml
```

Verify persistent volume claims were created:
```bash
kubectl get pvc -n laravel-app
# You should see 'mysql-pvc' and 'redis-pvc'
```

#### Deploy Database & Redis

```bash
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/redis.yaml
```

Verify MySQL and Redis pods are running:
```bash
kubectl get pods -n laravel-app -l app=mysql
kubectl get pods -n laravel-app -l app=redis
# Wait until status shows 'Running' for both
```

#### Create Nginx ConfigMap

```bash
kubectl apply -f k8s/nginx-configmap.yaml
```

Verify configmap was created:
```bash
kubectl get configmaps -n laravel-app
# You should see 'nginx-config' in the list
```

#### Deploy Laravel Application

```bash
kubectl apply -f k8s/laravel.yaml
```

Verify Laravel pods are running:
```bash
kubectl get pods -n laravel-app -l app=laravel-app
# You should see multiple pods with 'Running' status
```

#### Deploy Nginx

```bash
kubectl apply -f k8s/nginx.yaml
```

Verify Nginx pods are running:
```bash
kubectl get pods -n laravel-app -l app=nginx
# You should see multiple pods with 'Running' status
```

#### Deploy PHPMyAdmin

```bash
kubectl apply -f k8s/phpmyadmin.yaml
```

Verify PHPMyAdmin pod is running:
```bash
kubectl get pods -n laravel-app -l app=phpmyadmin
# Wait until status shows 'Running'
```

Verify all services are created:
```bash
kubectl get services -n laravel-app
# You should see all your services listed
```

### 4. Set Up SSL for Local Development

```bash
# Install cert-manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.8.0/cert-manager.yaml
```

Verify cert-manager is installed:
```bash
kubectl get pods -n cert-manager
# Wait until all pods show 'Running' status
```

Wait for cert-manager to be ready:
```bash
kubectl wait --for=condition=Ready pods -n cert-manager --all --timeout=300s
```

Create the self-signed certificate issuer:
```bash
kubectl apply -f k8s/self-signed-issuer.yaml
```

Verify certificate issuer was created:
```bash
kubectl get clusterissuer
# You should see 'selfsigned-issuer' in the list
```

Create the ingress with SSL:
```bash
kubectl apply -f k8s/ingress.yaml
```

Verify ingress was created:
```bash
kubectl get ingress -n laravel-app
# You should see your ingress configuration
```

Enable ingress in minikube:
```bash
minikube addons enable ingress
```

### 5. Configure Local Hosts

Get your Minikube IP:
```bash
minikube ip
```

Add entries to your hosts file:
```bash
sudo bash -c "echo '$(minikube ip) laravel.local phpmyadmin.local' >> /etc/hosts"
```

Verify hosts file was updated:
```bash
cat /etc/hosts | grep laravel.local
# Should show the minikube IP with both domains
```

## Accessing the Application

- Laravel Application: https://laravel.local
- PHPMyAdmin: https://phpmyadmin.local

Check if applications are accessible:
```bash
# For HTTP status code
curl -k -I https://laravel.local
curl -k -I https://phpmyadmin.local
# Should return HTTP 200 OK
```

## Verifying Deployments

Check if all components are running correctly:

```bash
kubectl get pods -n laravel-app
# All pods should show 'Running' status

kubectl get services -n laravel-app
# All services should be listed

kubectl get deployments -n laravel-app
# All deployments should show desired replicas as available
```

## Troubleshooting

### View Logs

```bash
# Get pod names
kubectl get pods -n laravel-app

# View logs for a specific pod
kubectl logs -n laravel-app [pod-name]
```

### Check Pod Details

```bash
# Get detailed information about a pod
kubectl describe pod -n laravel-app [pod-name]
```

### Check Service Details

```bash
# Get detailed information about a service
kubectl describe service -n laravel-app [service-name]
```

### Alternative Access via Port Forwarding

If the Ingress setup isn't working, you can use port forwarding:

```bash
# For Laravel application
kubectl port-forward -n laravel-app svc/nginx-service 8080:8080

# For PHPMyAdmin
kubectl port-forward -n laravel-app svc/phpmyadmin-service 8081:8081
```

Then access via:
- Laravel: http://localhost:8080
- PHPMyAdmin: http://localhost:8081

## Production Deployment Notes

For production deployment:

1. Update domain names in the ingress configuration
2. Set up a proper SSL certificate issuer using Let's Encrypt
3. Update Laravel environment variables with production values

## Clean Up

To remove all resources:

```bash
kubectl delete namespace laravel-app
```

Verify the namespace was deleted:
```bash
kubectl get namespaces
# 'laravel-app' should no longer be in the list
```

## Configuration Details

- **Laravel**: PHP 8.3 with Redis extension, 3 replicas for production, 1 for staging
- **MySQL**: Persistent storage, credentials stored in secrets
- **Redis**: Persistent storage for data
- **Nginx**: Configured as a load balancer with 3 replicas
- **PHPMyAdmin**: Web interface for database management

## License

[MIT](LICENSE)
