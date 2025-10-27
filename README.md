# InfraStore Kubernetes Deployment

This repository contains Kubernetes manifests for deploying InfraStore, a file storage application with a REST API.

## Architecture

The deployment consists of:
- Scalable InfraStore application pods
- Persistent storage for media files and database
- RBAC configuration for security
- Network policies for traffic control
- Horizontal Pod Autoscaler for automatic scaling
- Ingress for external access

## Architecture Overview

The solution consists of these key components:
1. Deployment for the InfraStore application with horizontal scaling
2. Service to expose the API endpoints
3. Ingress for routing external traffic
4. PersistentVolumeClaims for media files and database storage
5. ConfigMap and Secret for configuration and sensitive data
6. RBAC for security access control
7. HorizontalPodAutoscaler for automatic scaling based on load
8. NetworkPolicy to restrict pod communication

The architecture follows best practices by separating configuration from code, implementing least privilege principles, and ensuring data persistence.

## Prerequisites

- Kubernetes cluster (or local setup like Minikube, kind, or k3s)
- kubectl CLI configured to access your cluster
- Ingress controller installed (if using Ingress) - Not tested in my local minikube

## Deployment Options

### Option 1: Apply Kubernetes Manifests

1. Create namespace: 
`kubectl apply -f namespace.yaml`

2. Apply configuration: 
`kubectl apply -f configmap.yaml`
`kubectl apply -f secret.yaml`

3. Apply storage: 
`kubectl apply -f pvc.yaml`

4. Deploy application: 
`kubectl apply -f rbac.yaml`
`kubectl apply -f deployment.yaml`
`kubectl apply -f service.yaml`
`kubectl apply -f ingress.yaml`
`kubectl apply -f networkpolicy.yaml`
`kubectl apply -f hpa.yaml`

## Security Considerations

- Passwords are stored in Kubernetes Secrets
- Non-root user is configured in the container
- RBAC is implemented with least privilege principle
- Network policy restricts pod communications
- Security context drops unnecessary capabilities

## Scaling

The deployment is configured to scale automatically based on CPU and memory utilization using HPA. Initial setup includes:
- Minimum 2 replicas
- Maximum 10 replicas
- Scale up when CPU exceeds 70% utilization
- Scale up when memory exceeds 80% utilization

## Accessing the Application

After deployment, the application will be available at:
- When using Ingress: https://infrastore.example.com (Not used in local)
- Without Ingress: Use port-forwarding to access the service
`kubectl port-forward -n infrastore svc/infrastore 8000:80`

## Test the Application through bash shell
- Get a token: 
`curl -X POST http://localhost:8000/api/token/ -d "username=admin&password=********"`
- Upload a file: 
`curl -X POST http://localhost:8000/api/upload/ -H "Authorization: Token YOUR_TOKEN" -F "file=@test.txt"`
- List a file: 
`curl -H "Authorization: Token YOUR_TOKEN" http://localhost:8000/api/files/`
- Delete a file: 
`curl -X DELETE http://localhost:8000/api/files/1/ -H "Authorization: Token YOUR_TOKEN"`

## Troubleshooting

- Check pod status:
`kubectl get pods -n infrastore`
- View logs:
`kubectl logs -n infrastore deploy/infrastore`
- Check persistent volumes:
`kubectl get pvc -n infrastore`

## Future Improvements

- Implement database replication for high availability
- Add monitoring with Prometheus and Grafana
- Set up CI/CD pipeline for automated deployments
- Configure backup solutions for persistent data

## Architecture Diagram

