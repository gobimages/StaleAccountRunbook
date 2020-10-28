$Properties = @()
$Login = Get-AutomationPSCredential -Name 'Login'
$UserLogin = Get-AutomationPSCredential -Name 'UserLogin'
Connect-AzureAD -Credential $UserLogin
$GDate = ((Get-Date).AddMonths(-1)).ToString("yyyy-MM-dd")
Get-AzureADUser -All $true | foreach $_ {
    if ($_.userPrincipalName -notmatch "#EXT#") {
        if ((Get-AzureADAuditSignInLogs -Filter "userPrincipalName eq '$($_.UserPrincipalName)' and CreatedDateTime gt $GDate") -eq $null) {
            $properties += [PSCustomObject]@{
                UserPrincipalName = $_.UserPrincipalName
                DisplayName       = $_.DisplayName
                "Account Enabled" = $_.AccountEnabled
            }
            $Properties | export-csv "c:\temp\data.csv" -NoTypeInformation -Append
        }
        $properties = $null
    }
    
}
Send-MailMessage -From "$($Login.UserName)" -To 'v-gomage@microsoft.com ' -Subject 'Sending the Attachment' -Body "Forgot to send the attachment. Sending now." -Attachments c:\temp\data.csv -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'outlook.office365.com' -Credential $Login -UseSSL -Port 587
Remove-Item "c:\temp\data.csv" -force

