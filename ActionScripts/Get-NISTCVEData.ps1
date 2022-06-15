. "$PSScriptRoot\..\CommonFunctions\Add-LogComment.ps1"

function Get-NISTCVEData
{
    param (
        [Parameter(Mandatory=$true)]
        [string] $yesterday,

        [Parameter(Mandatory=$true)]
        [array] $searchTerms,

        [Parameter(Mandatory=$false)]
        [string] $logPath
    )

    Add-LogComment "INFO" "Get-NISTCVEData.ps1" "Start" $logPath

    [System.Net.WebRequest]::DefaultWebProxy = new-object System.Net.WebProxy('<# Enter details for proxy #>')
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [System.Net.WebRequest]::DefaultWebProxy.BypassProxyOnLocal = $true

    $startDateTime = $yesterday+'T00:00:00:000 UTC%2B01:00'
    $endDateTime = $yesterday+'T23:59:59:000 UTC%2B01:00'
    $callURLModified = "https://services.nvd.nist.gov/rest/json/cves/1.0/?resultsPerPage=2000&modStartDate=$($startDateTime)&modEndDate=$($endDateTime)"
    Add-LogComment "INFO" "Get-NISTCVEData.ps1" "callURL: $callURLModified" $logPath
    $searchResults = @()
    
    $response = Invoke-RestMethod -Uri $callURLModified  -Method Get

    Add-LogComment "INFO" "Get-NISTCVEData.ps1" "Total CVEs returned: $($response.result.CVE_Items.Count)" $logPath
    foreach($searchTerm in $searchTerms)
    {
        [array]$searchResult = $response.result.CVE_Items | Where-Object {$_.cve.description.description_data.value -match $searchTerm}
        Add-LogComment "INFO" "Get-NISTCVEData.ps1" "Search term: $searchTerm - Results: $($searchResult.Count)" $logPath
        if($searchResult.Count -ne 0)
        {
            foreach($result in $searchResult)
            {
                $references = @{}
                foreach($reference in $result.cve.references.reference_data)
                {
                    if(!$references.ContainsKey($reference.name))
                    {
                        $references.Add($reference.name, $reference.url)
                    }
                }
                $severity = ''
                if($result.impact.baseMetricV3.cvssV3.baseSeverity -ne "CRITICAL" -and $result.impact.baseMetricV3.cvssV3.baseSeverity -ne "HIGH" -and $result.impact.baseMetricV3.cvssV3.baseSeverity -ne "MEDIUM")
                {
                    $severity = 'Not Rated'
                }
                else {
                    $severity = $result.impact.baseMetricV3.cvssV3.baseSeverity
                }
                $cveObject = New-Object -Type PSObject -Property @{
                    'searchTerm' = $searchTerm
                    'cveID' = $result.cve.CVE_data_meta.id
                    'publishedDate' = $result.publishedDate
                    'lastModifiedDate' = $result.lastModifiedDate
                    'baseScore' = $result.impact.baseMetricV3.cvssV3.baseScore
                    'baseSeverity' = $severity
                    'description' = $result.cve.description.description_data.value
                    'references' = $references
                }
                
                $searchResults += $cveObject
            }
        }
    }

    Add-LogComment "INFO" "Get-NISTCVEData.ps1" "End" $logPath
    return $searchResults
}

<# Testing 
$resp = Get-NISTCVEData
$resp
#>
