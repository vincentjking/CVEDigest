function Add-LogComment
{
<#
.SYNOPSIS
    Gets details for a with a username

.DESCRIPTION
    Function takes a Level (ALL, DEBUG, INFO, WARN, ERROR, FATAL), a Message, and a file location.  The function adds a datetime stamp and appends to the file.  
		
.PARAMETER 
    MANDATORY [string] $level - the importance
    MANDATORY [string] $filename - file from which the message has been sent
	MANDATORY [string] $message - log message
	MANDATORY [string] $path - log file path

.NOTES
.EXAMPLE
#>
	param ( 
        [Parameter(Mandatory=$true)]
        [string] $level,

        [Parameter(Mandatory=$true)]
        [string] $filename,

		[Parameter(Mandatory=$true)]
        [string] $message,

		[Parameter(Mandatory=$true)]
        [string] $path
    )

    $dateTime = get-date -Format "yyyy-MM-dd HH:mm:ss"
	$messageToLog = "$dateTime $level $filename $message"
	$messageToLog | Out-File $path -Append
}

<# Testing
Add-LogComment "INFO" "Testfile.ps1" "Test Message" "\\Istd\tvm\TVMAutomation\DEV\LoggingcveReport.log"
<##>
