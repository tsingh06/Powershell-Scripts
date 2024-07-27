#Parameters
$InactiveDays = 2
$CSVPath = "C:\Temp\InactiveUsers.csv"
$InactiveUsers = @()
$ThresholdDate = (Get-Date).AddDays(-$InactiveDays)
 
#Connect to Microsoft Graph
Connect-MgGraph -Scopes "AuditLog.Read.All", "User.Read.All"
 
#Set the Graph Profile
Select-MgProfile beta
 
#Properties to Retrieve
$Properties = @(
    'Id','DisplayName','Mail','UserPrincipalName','UserType', 'AccountEnabled', 'SignInActivity'   
)
 
#Get All users along with the properties
$AllUsers = Get-MgUser -All -Property $Properties
 
ForEach ($User in $AllUsers)
{
    $LastLoginDate = $User.SignInActivity.LastSignInDateTime
    If($LastLoginDate -eq $null)
    {
        $LastSignInDate = "Never Signed-in!"
    }
    Else
    {
        $LastSignInDate = $LastLoginDate
    }
 
    #Collect data
    If(!$LastLoginDate -or ($LastLoginDate -and ((Get-Date $LastLoginDate) -lt $ThresholdDate)))
    {
        $InactiveUsers += [PSCustomObject][ordered]@{
            LoginName       = $User.UserPrincipalName
            Email           = $User.Mail
            DisplayName     = $User.DisplayName
            UserType        = $User.UserType
            AccountEnabled  = $User.AccountEnabled
            LastSignInDate  = $LastSignInDate
        }
    }
}
 
$InactiveUsers
#Export Data to CSV
$InactiveUsers | Export-Csv -Path $CSVPath -NoTypeInformation


#Read more: https://www.sharepointdiary.com/2023/01/find-inactive-users-in-office-365.html#ixzz8gUT5Psdz