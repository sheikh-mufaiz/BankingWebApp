param (
    [string]$Region = "ap-south-1"
)

Write-Host "Searching for running servers in $Region..." -ForegroundColor Cyan

$serverNames = @("Ansible_Server", "Jenkins_Master", "Jenkins_SlaveNode_Build_Server", "Dedicated_Monitoring_Server")
$filter = "Name=tag:Name,Values=$($serverNames -join ',')"

$runningInstances = aws ec2 describe-instances `
    --region $Region `
    --filters $filter "Name=instance-state-name,Values=running" `
    --query "Reservations[*].Instances[*].InstanceId" `
    --output text

if (-not $runningInstances -or $runningInstances.Trim() -eq "") {
    Write-Host "No running instances found to stop." -ForegroundColor Yellow
    exit 0
}

$instanceIds = ($runningInstances -split "\s+") | Where-Object { $_ -ne "" }
Write-Host "Stopping $($instanceIds.Count) instances: $($instanceIds -join ', ')..." -ForegroundColor Yellow

aws ec2 stop-instances --region $Region --instance-ids $instanceIds --output table

Write-Host "`nAll instances are shutting down!" -ForegroundColor Green
Write-Host "Your data, tools, and configurations remain completely safe on the EBS disks." -ForegroundColor Green
Write-Host "Compute ($0.00/hr) and IPv4 charges have stopped." -ForegroundColor Green
