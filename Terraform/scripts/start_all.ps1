param (
    [string]$Region = "ap-south-1"
)

Write-Host "Searching for stopped servers in $Region..." -ForegroundColor Cyan

$serverNames = @("Ansible_Server", "Jenkins_Master", "Jenkins_SlaveNode_Build_Server", "Dedicated_Monitoring_Server")
$filter = "Name=tag:Name,Values=$($serverNames -join ',')"

$stoppedInstances = aws ec2 describe-instances `
    --region $Region `
    --filters $filter "Name=instance-state-name,Values=stopped" `
    --query "Reservations[*].Instances[*].InstanceId" `
    --output text

if (-not $stoppedInstances -or $stoppedInstances.Trim() -eq "") {
    Write-Host "No stopped instances found to start." -ForegroundColor Yellow
} else {
    $instanceIds = ($stoppedInstances -split "\s+") | Where-Object { $_ -ne "" }
    Write-Host "Starting $($instanceIds.Count) instances: $($instanceIds -join ', ')..." -ForegroundColor Cyan
    aws ec2 start-instances --region $Region --instance-ids $instanceIds --output table
}

Write-Host "`nWaiting for instances to reach 'running' state..." -ForegroundColor Cyan
aws ec2 wait instance-running --region $Region --filters $filter

Write-Host "Instances are running! Fetching new public IPs..." -ForegroundColor Green

$instancesInfo = aws ec2 describe-instances `
    --region $Region `
    --filters $filter "Name=instance-state-name,Values=running" `
    --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value, InstanceId:InstanceId, PublicIp:PublicIpAddress}" `
    --output json | ConvertFrom-Json

$ipMap = @{}
foreach ($item in $instancesInfo) {
    $ipMap[$item.Name] = $item.PublicIp
    Write-Host "  $($item.Name): $($item.PublicIp)" -ForegroundColor White
}

# Update ansible_inventory.ini and ansible/inventory.ini with fresh public IPs
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$tplPath = Join-Path $projectRoot "templates\inventory.ini.tpl"
$invPath = Join-Path $projectRoot "ansible_inventory.ini"
$ansibleDirInvPath = Join-Path $projectRoot "ansible\inventory.ini"

if (Test-Path $tplPath) {
    $tpl = Get-Content $tplPath -Raw
    $invContent = $tpl `
        -replace '\$\{ansible_server_ip\}', $ipMap["Ansible_Server"] `
        -replace '\$\{jenkins_master_ip\}', $ipMap["Jenkins_Master"] `
        -replace '\$\{jenkins_slave_ip\}', $ipMap["Jenkins_SlaveNode_Build_Server"] `
        -replace '\$\{monitoring_ip\}', $ipMap["Dedicated_Monitoring_Server"]
    
    Set-Content -Path $invPath -Value $invContent -Encoding utf8
    Write-Host "`nUpdated $invPath with new public IPs." -ForegroundColor Green

    Set-Content -Path $ansibleDirInvPath -Value $invContent -Encoding utf8
    Write-Host "Updated $ansibleDirInvPath with new public IPs." -ForegroundColor Green
}

Write-Host "`nWeb Management Dashboards:" -ForegroundColor Cyan
Write-Host "  Jenkins UI:    http://$($ipMap['Jenkins_Master']):8080" -ForegroundColor White
Write-Host "  Prometheus UI: http://$($ipMap['Dedicated_Monitoring_Server']):9090" -ForegroundColor White
Write-Host "  Grafana UI:    http://$($ipMap['Dedicated_Monitoring_Server']):3000" -ForegroundColor White

Write-Host "`nSSH Login Commands:" -ForegroundColor Cyan
Write-Host "  Ansible:    ssh -i banking_key.pem ubuntu@$($ipMap['Ansible_Server'])" -ForegroundColor White
Write-Host "  Jenkins M:  ssh -i banking_key.pem ubuntu@$($ipMap['Jenkins_Master'])" -ForegroundColor White
Write-Host "  Jenkins S:  ssh -i banking_key.pem ubuntu@$($ipMap['Jenkins_SlaveNode_Build_Server'])" -ForegroundColor White
Write-Host "  Monitoring: ssh -i banking_key.pem ubuntu@$($ipMap['Dedicated_Monitoring_Server'])" -ForegroundColor White
