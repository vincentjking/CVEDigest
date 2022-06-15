. "$PSScriptRoot\..\Config\Config.ps1"
. "$PSScriptRoot\..\CommonFunctions\Add-LogComment.ps1"

function Invoke-SendHTMLEmail
{
    param (
        [Parameter(Mandatory=$true)]
        [string] $fromAddress,

        [Parameter(Mandatory=$true)]
        [string] $toAddress,

        [Parameter(Mandatory=$true)]
        [string] $subject,

        [Parameter(Mandatory=$true)]
        [string] $body,

        [Parameter(Mandatory=$false)]
        [string] $logPath
    )

    Add-LogComment "INFO" "Invoke-SendHTMLEmail.ps1" "Start" $logPath
    try
    {
        Add-LogComment "INFO" "Invoke-SendHTMLEmail.ps1" "Send email to $toAddress" $logPath
        [string[]]$recipients = $toAddress.Split(',')
        Send-MailMessage -From $fromAddress -To $recipients -Subject $subject -Body $body -SmtpServer $config['smtpServer'] -BodyAsHtml
    }
    catch
    {
        Add-LogComment  "FATAL" "Invoke-SendHTMLEmail" "Failed to send email: $_" $logPath
    }
    Add-LogComment "INFO" "Invoke-SendHTMLEmail.ps1" "End" $logPath
}
