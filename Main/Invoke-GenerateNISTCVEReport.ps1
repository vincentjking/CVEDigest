. "$PSScriptRoot\..\Config\Config.ps1"
. "$PSScriptRoot\..\Config\SearchTerms.ps1"
. "$PSScriptRoot\..\ActionScripts\Get-NISTCVEData.ps1"
. "$PSScriptRoot\..\ActionScripts\New-CVEHTMLOutput.ps1"
. "$PSScriptRoot\..\ActionScripts\New-CVEOutputFile.ps1"
. "$PSScriptRoot\..\CommonFunctions\Invoke-SendHTMLEmail.ps1"
. "$PSScriptRoot\..\CommonFunctions\Add-LogComment.ps1"

function Invoke-GenerateNISTCVEReport
{
    #region  Set constants
    $logPath = $config['cveLogFolder']+'\cveReport.log'
    $yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
    $saveCSVFilePath = $config['cveOutputFolder']+'\CVEReport-'+$yesterday+'.csv'
	#endregion
    Add-LogComment "INFO" "Invoke-GenerateNISTCVEReport.ps1" "Start" $logPath
    
    Add-LogComment "INFO" "Invoke-GenerateNISTCVEReport.ps1" "Target date: $yesterday" $logPath
    $cveData = Get-NISTCVEData $yesterday $searchTerms $logPath

    if($cveData.Count -ne 0)
    {
        try {
            Add-LogComment "INFO" "Invoke-GenerateNISTCVEReport.ps1" "Save CSV file" $logPath
            New-CVEOutputFile $cveData $saveCSVFilePath $logPath
        }
        catch {
            Add-LogComment "FATAL" "Invoke-GenerateNISTCVEReport.ps1" "Failed to save file ($_)" $logPath
            break
        }
    
        try {
            Add-LogComment "INFO" "Invoke-GenerateNISTCVEReport.ps1" "Set email details" $logPath
            $from = $config['cveEmailFrom']
            $to = $config['cveEmailTo'] 
            $subject = "CVE Report - $yesterday"
            $messageBody = New-CVEHTMLOutput $cveData $searchTerms $saveCSVFilePath $logPath
    
            Invoke-SendHTMLEmail $from $to $subject $messageBody $logPath
        }
        catch {
            Add-LogComment "FATAL" "Invoke-GenerateNISTCVEReport.ps1" "Failed to email info ($_)" $logPath
            break
        }
        Add-LogComment "INFO" "Invoke-GenerateNISTCVEReport.ps1" "End" $logPath
    }
    else {
        Add-LogComment "INFO" "Invoke-GenerateNISTCVEReport.ps1" "Search returned no results" $logPath
        $from = $config['cveEmailFrom']
        $to = $config['cveEmailTo'] 
        $subject = "CVE Report - $yesterday"
        
        $messageBody = ''
        $messageBody += '<!DOCTYPE html>'
        $messageBody += '<html>'
        $messageBody += '<head>'
        $messageBody += '</head>'
        $messageBody += '<body>'
        $messageBody += '<h1>Summary</h1>'
        $messageBody += '<h3>CVE Reporting search returned no results.</h3>'
        $messageBody += '</body>'
        $messageBody += '</html>'

        try {
            Invoke-SendHTMLEmail $from $to $subject $messageBody $logPath
        }
        catch {
            Add-LogComment "FATAL" "Invoke-GenerateNISTCVEReport.ps1" "Failed to email info ($_)" $logPath
            break
        }
    }
}

Invoke-GenerateNISTCVEReport
<# Testing
$resp = Invoke-GenerateNISTCVEReport
$resp
#>
