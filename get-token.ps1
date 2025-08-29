# PowerShell script to get AWS session token with MFA
# Usage: .\get-token.ps1 <MFA_TOKEN_CODE>

param(
    [Parameter(Mandatory=$true)]
    [string]$TokenCode
)

# Configuration
$ProfileName = "dev-mfa"
$MFASerial = "arn:aws:iam::597765856364:mfa/DevKhusanKhujakeldievMFA"

Write-Host "🔐 Getting AWS session token for profile: $ProfileName" -ForegroundColor Green
Write-Host "📱 Using MFA device: $MFASerial" -ForegroundColor Yellow

try {
    # Get session token
    $result = aws sts get-session-token --serial-number $MFASerial --token-code $TokenCode --profile dev-mfa | ConvertFrom-Json
    
    if ($result.Credentials) {
        # Extract credentials
        $accessKey = $result.Credentials.AccessKeyId
        $secretKey = $result.Credentials.SecretAccessKey
        $sessionToken = $result.Credentials.SessionToken
        $expiration = $result.Credentials.Expiration
        
        # Update AWS profile
        aws configure set aws_access_key_id $accessKey --profile $ProfileName
        aws configure set aws_secret_access_key $secretKey --profile $ProfileName
        aws configure set aws_session_token $sessionToken --profile $ProfileName
        
        Write-Host "✅ Session token obtained successfully!" -ForegroundColor Green
        Write-Host "🔑 Access Key: $accessKey" -ForegroundColor Cyan
        Write-Host "⏰ Expires: $expiration" -ForegroundColor Yellow
        
        # Test credentials
        Write-Host "🧪 Testing credentials..." -ForegroundColor Blue
        $identity = aws sts get-caller-identity --profile $ProfileName | ConvertFrom-Json
        Write-Host "👤 User: $($identity.Arn)" -ForegroundColor Green
        Write-Host "🏢 Account: $($identity.Account)" -ForegroundColor Green
        
    } else {
        Write-Host "❌ Failed to get credentials from response" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Error getting session token: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 Ready to use Terraform!" -ForegroundColor Green
