$Login = Get-AutomationPSCredential -Name 'Login'
$UserLogin = Get-AutomationPSCredential -Name 'UserLogin'
Connect-AzureAD -Credential $UserLogin -TenantId $TenantID
$GDate = ((Get-Date).AddMonths(-1)).ToString("yyyy-MM-dd")
$ADUsersAll = Get-AzureADUser -All $true
$Result = @()
foreach ($U in $user) {
    if (Get-AzureADAuditSignInLogs -Filter "UserId eq '$($U.ObjectId)' and CreatedDateTime gt $GDate") {
        $Result += [PSCustomObject]@{
            Displayame        = $U.DisplayName
            UserPrincipalName = $U.UserPrincipalName
            ActiveAccount     = "Yes"
        }
    }
    Else {
        $Result += [PSCustomObject]@{
            Displayame        = $U.DisplayName
            UserPrincipalName = $U.UserPrincipalName
            ActiveAccount     = "No"
        }
    }
    $Result | Export-Csv "c:\temp\data.csv" -NoTypeInformation -Append
}

Send-MailMessage -From "$($Login.UserName)" -To $Destination -Subject 'Sending the Attachment' -Body "Forgot to send the attachment. Sending now." -Attachments c:\temp\data.csv -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'outlook.office365.com' -Credential $Login -UseSSL -Port 587
Remove-Item "c:\temp\data.csv" -force
