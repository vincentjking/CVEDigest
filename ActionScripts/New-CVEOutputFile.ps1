. "$PSScriptRoot\..\CommonFunctions\Add-LogComment.ps1"
function New-CVEOutputFile
{
    param (
        [Parameter(Mandatory=$true)]
        [array] $cveData,

        [Parameter(Mandatory=$true)]
        [string] $outputFilePath,

        [Parameter(Mandatory=$false)]
        [string] $logPath
    )

    Add-LogComment "INFO" "New-CVEOutputFile.ps1" "Start" $logPath
    try {
        # Convert CVE date for CSV output
        $cveOutputObjectArray = @()
        
        foreach($cveObject in $cveData)
        {
            $referenceLinksOnly = ''
            $references = $cveObject.references
            foreach($referenceName in $references.Keys)
            {
                $referenceLinksOnly += $references[$referenceName] + '; '
            }
            $cveObjectForCVSOutput = New-Object -Type PSObject -Property @{
                'searchTerm' = $cveObject.searchTerm
                'cveID' = $cveObject.cveID
                'publishedDate' = $cveObject.publishedDate
                'lastModifiedDate' = $cveObject.lastModifiedDate
                'baseScore' = $cveObject.baseScore
                'baseSeverity' = $cveObject.baseSeverity
                'description' = $cveObject.description
                'references' = $referenceLinksOnly
            }
            $cveOutputObjectArray += $cveObjectForCVSOutput
        }

        try {
            $cveOutputObjectArray | Export-Csv $outputFilePath -NoTypeInformation
            Add-LogComment "INFO" "New-CVEOutputFile.ps1" "CSV file saved: $outputFilePath" $logPath
        }
        catch {
            Add-LogComment "FATAL" "New-CVEOutputFile.ps1" "Failed to save CSV file: $outputFilePath ($_)" $logPath
        }
    }
    catch {
        Add-LogComment "Error" "New-CVEOutputFile.ps1" "Failed to convert CVE date for CSV output" $logPath
    }
    
    Add-LogComment "INFO" "New-CVEOutputFile.ps1" "End" $logPath
}
