Param(
    [string]$Namespace = "infrastore"
)

$ErrorActionPreference = "Stop"

function Fail-AndExit {
    param($msg)
    Write-Host "❌ ERROR: $msg" -ForegroundColor Red
    exit 1
}

Write-Host ">>> Verifying cluster connectivity..."
try {
    kubectl version --client | Out-Null
}
catch {
    Fail-AndExit "Unable to communicate with Kubernetes cluster. Check your kubeconfig / cluster access."
}

function Apply-IfExists {
    param($filePath, $useNamespace = $true)

    if (Test-Path $filePath) {
        try {
            if ($useNamespace) {
                kubectl apply -n $Namespace -f $filePath
            } else {
                kubectl apply -f $filePath
            }
        }
        catch {
            Fail-AndExit "Failed applying $filePath"
        }
    } else {
        Write-Host "Skipping -> $filePath not found"
    }
}

Write-Host ">>> Creating namespace..."
Apply-IfExists "./namespace.yml" $false

Write-Host ">>> Applying RBAC..."
Apply-IfExists "./rbac.yml"

Write-Host ">>> Applying ConfigMap and Secret..."
Apply-IfExists "./configmap.yml"
Apply-IfExists "./secret.yml"

Write-Host ">>> Applying Persistent Volume Claims..."
Apply-IfExists "./pvc.yml"

Write-Host ">>> Deploying application..."
Apply-IfExists "./deployment.yml"
Apply-IfExists "./service.yml"

Write-Host ">>> Applying Networking & Security..."
Apply-IfExists "./networkpolicy.yml"
Apply-IfExists "./ingress.yml"

Write-Host ">>> Applying Autoscaling..."
Apply-IfExists "./hpa.yml"

Write-Host ">>> Waiting for deployment rollout..."
try {
    kubectl rollout status deployment/infrastore -n $Namespace --timeout=120s | Out-Null
}
catch {
    Fail-AndExit "Deployment rollout failed. Pods did not reach Ready state."
}

Write-Host "SUCCESS: Script executed successfully." -ForegroundColor Green


