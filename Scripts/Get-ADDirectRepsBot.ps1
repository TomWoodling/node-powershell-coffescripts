<#
.Synopsis
    Gets service status for Hubot Script.
.DESCRIPTION
    Gets service status for Hubot Script.
.EXAMPLE
    Get-ServiceHubot -Name dhcp
#>

    [CmdletBinding()]
    Param
    (
        # Name of the Service
        [Parameter(Mandatory=$true)]
        [string]$User,
        [Parameter(Mandatory=$true)]
        [string]$Channel
    )

    #Get details for snippet
    $path="C:\ps\ADDR_Results_for_$($User.Replace('.','_')).csv"
    

    # Create a hashtable for the results
    $result = @{}

    try {
        # Use ErrorAction Stop to make sure we can catch any errors
        Get-ADDirectReports -Identity $user -Recurse | Export-Csv -Path $path -Force -NoTypeInformation
        
        # Create a string for sending back to slack. * and ` are used to make the output look nice in Slack. Details: http://bit.ly/MHSlackFormat
        $result.output = ":bowtie: Request for $User processed..."

        #Write-Output "Processing request now..."
        
        # Set a successful result
        $result.success = $true
        }
    catch {
        # If this script fails we can try to match the name instead to see if we get any suggestions
        $result.output = "$User does not exist :mariofail:"
        
        # Set a failed result
        $result.success = $false
        }
    # Return the result and convert it to json, then attach a snippet with the results
    Send-SlackBotFile -Channels $channel -path $path > $null    
    Remove-Item -Path $path -Force
    return $result | ConvertTo-Json
