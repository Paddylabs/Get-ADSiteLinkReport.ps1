function Get-ADSiteLinkReport {
<#
.SYNOPSIS
    Gets a list of AD Site Links from Active Directory.

.DESCRIPTION
    Gets a list of AD Site Links and details from the specified Active Directory Domain.

.PARAMETER
    -Domain The fully qualified domain name of the domain you are querying.
    -CSV    Adding this switch outputs the results to a csv file.

.EXAMPLE
    Get-ADSiteLinkReport -Domain testdomain.local

    Gets AD Site Links and details from the domain testdomain.local and outputs to the screen.

.EXAMPLE
    Get-ADSiteLinkReport -Domain testdomain.local -csv

    Gets AD Site Links and details from the domain testdomain.local and outputs to a CSV file prepended with todays date.

.INPUTS
    None

.OUTPUTS
    Outputs to the screen by default but can be changed to output to a CSV file by using the -csv switch

.NOTES
     Author:        Patrick Horne
     Creation Date: 11/10/16

     Change Log:
        V1:         Initial Development
        V1:         Added -csv switch
#>
[CmdletBinding()]
Param(
    [Parameter(Position=0,Mandatory=$True,HelpMessage="FQDN of the Domain")]
    [String]$Domain,
    [Parameter(Position=1,Mandatory=$False,HelpMessage="Export to CSV File instead of screen")]
    [Switch]$CSV

)

$SiteLinks = @()

Try {

    IF (!(Get-Module -ListAvailable -Name ActiveDirectory)) {Import-Module -Name ActiveDirectory -ErrorAction Stop -ErrorVariable ErrImpADModule}

    }

Catch {

    IF ($ErrImpADModule) { Write-Warning "Error importing ActiveDirectory Powershell module" }

    }

$Date = Get-Date -Format "ddMMyyy"

$ConfigPartition = (Get-ADRootDSE -server $Domain).ConfigurationNamingContext

$ADSiteLinks = Get-ADObject -Filter { ObjectClass -eq "SiteLink" } -properties * -searchBase $ConfigPartition -server $Domain

Foreach ($ADSiteLink in $ADSiteLinks) {

$SiteList = ($ADSiteLink.sitelist).split("=,")[1,11] -join " - "

$SiteLink = New-Object -TypeName psobject -Property @{

                "Name" = $ADSiteLink.name
                "Cost" = $ADSiteLink.cost
                "ReplInterval" = $ADSiteLink.replinterval
                "Created" = $ADSiteLink.WhenCreated
                "Changed" = $ADSiteLink.WhenChanged
                "SiteList" = $SiteList

                }

                $SiteLinks += $SiteLink

                }

IF ($CSV) {

    $SiteLinks | Select Name,Cost,ReplInterval,Created,Changed,SiteList | Export-Csv $Date"_SiteLinkReport.csv" -NoTypeInformation -Append

}

ELSE {

    $SiteLinks | Select Name,Cost,ReplInterval,Created,Changed,SiteList | FT
   
}

}


