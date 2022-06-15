. "$PSScriptRoot\..\CommonFunctions\Add-LogComment.ps1"

function New-CVEHTMLOutput
{
    param (
        [Parameter(Mandatory=$true)]
        [array] $cveDetails,

        [Parameter(Mandatory=$true)]
        [array] $searchTerms,

        [Parameter(Mandatory=$true)]
        [string] $cveOutputFilePath,

        [Parameter(Mandatory=$false)]
        [string] $logPath
    )

    $htmlOutput = ''
    $htmlOutput += '<!DOCTYPE html>'
    $htmlOutput += '<html>'
    $htmlOutput += '<head>'
    $htmlOutput += '</head>'
    $htmlOutput += '<body>'
    $htmlOutput += '<h1>Summary</h1>'
    $htmlOutput += '<table style="border:1px solid black;border-collapse:collapse;">'
    $htmlOutput += '<tr>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px">Search Term</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px; background-color: red">Critical</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px; background-color: orange">High</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px; background-color: yellow">Medium</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px">Not Rated</th>'
    $htmlOutput += '</tr>'
    foreach($searchTerm in $searchTerms)
    {
        [array]$critical = $cveDetails | Where-Object {$_.searchTerm -eq $searchTerm -and $_.baseSeverity -eq 'CRITICAL'}
        [array]$high = $cveDetails | Where-Object {$_.searchTerm -eq $searchTerm -and $_.baseSeverity -eq 'HIGH'}
        [array]$medium = $cveDetails | Where-Object {$_.searchTerm -eq $searchTerm -and $_.baseSeverity -eq 'MEDIUM'}
        [array]$notRated = $cveDetails | Where-Object {$_.searchTerm -eq $searchTerm -and $_.baseSeverity -eq 'NOT RATED'}
        
        $htmlOutput += '<tr style="font-weight: bolder;">'
        $htmlOutput += '<td style="border:1px solid black;">' + $searchTerm + '</td>'
        $htmlOutput += '<td style="border:1px solid black; text-align: center">' + $critical.Count + '</td>'
        $htmlOutput += '<td style="border:1px solid black; text-align: center">' + $high.Count + '</td>'
        $htmlOutput += '<td style="border:1px solid black; text-align: center">' + $medium.Count + '</td>'
        $htmlOutput += '<td style="border:1px solid black; text-align: center">' + $notRated.Count + '</td>'

        $htmlOutput += '</tr">'
    }
    $htmlOutput += '</table>'

    $htmlOutput += '</br>'
    $htmlOutput += '<h1>Details</h1>'
    $htmlOutput += '<h2>' + $cveOutputFilePath + '</h2>'
    $htmlOutput += '<table style="border:1px solid black;border-collapse:collapse;">'
    $htmlOutput += '<tr>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px">CVE ID</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px">Severity</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px">Base Score</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 150px">Search Term</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 400px">Description</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 400px">References</th>'
    $htmlOutput += '<th style="border:1px solid black; width: 200px">Dates</th>'
    $htmlOutput += '</tr>'

    $cveDetails = $cveDetails | Sort-Object baseSeverity

    foreach($cve in $cveDetails)
    {
        switch ($cve.baseSeverity) {
            "CRITICAL" { $htmlOutput += '<tr style="background-color: red; font-weight: bolder;">' }
            "HIGH" { $htmlOutput += '<tr style="background-color: orange;">' }
            "MEDIUM" { $htmlOutput += '<tr style="background-color: yellow;">' }
            Default { $htmlOutput += '<tr>' }
        }
        $htmlOutput += '<td style="border:1px solid black;">' + $cve.cveID + '</td>'
        $htmlOutput += '<td style="border:1px solid black;">' + $cve.baseSeverity + '</td>'
        $htmlOutput += '<td style="border:1px solid black;">' + $cve.baseScore + '</td>'
        $htmlOutput += '<td style="border:1px solid black;">' + $cve.searchTerm + '</td>'
        $htmlOutput += '<td style="border:1px solid black;">' + $cve.description + '</td>'
        $htmlOutput += '<td style="border:1px solid black;">'
        $references = $cve.references
        foreach($referenceName in $references.Keys)
        {
            $htmlOutput += '<a href="' + $references[$referenceName] + '" target="_blank">' + $referenceName + '</a><br/>'
        }
        $htmlOutput += '</td>'
        $htmlOutput += '<td style="border:1px solid black;">Published: <b>' + [string]$cve.publishedDate.Split("T")[0] + '</b><br/>Last Modified: <b>' + [string]$cve.lastModifiedDate.Split("T")[0] + '</b></td>'
        $htmlOutput += '</tr>'
    }

    $htmlOutput += '</table>'
    $htmlOutput += '</body>'
    $htmlOutput += '</html>'

    return $htmlOutput

}
