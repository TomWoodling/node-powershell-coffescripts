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
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [string]$Channel
    )

    #Get details for snippet
    $path="C:\ps\$($Group.Replace(' ','_')).csv"
    

    # Create a hashtable for the results
    $result = @{}

    try {
        # Use ErrorAction Stop to make sure we can catch any errors
        Get-ADNestedGroups -GroupName $Group -ErrorAction stop | select name | Export-Csv -Path $path -Force -NoTypeInformation
        
        # Create a string for sending back to slack. * and ` are used to make the output look nice in Slack. Details: http://bit.ly/MHSlackFormat
        $result.output = ":kuribo: Request for $Group processed..."
        #Write-Output "Processing request now..."
        
        # Set a successful result
        $result.success = $true
        }
    catch {
        # If this script fails we can try to match the name instead to see if we get any suggestions
        $cloo = Get-ADGroup -Filter * -Properties name,samaccountname | where name -Match $group | select -ExpandProperty name
        if($cloo.Count -ge 1) {
            $clee = [system.string]::join("; ", $cloo)
            $clib = ", you could try $clee"
            }
        else {$clib = ':mariofail:'}
        $result.output = "Group $Group does not exist$clib"
        
        # Set a failed result
        $result.success = $false
        }
    # Return the result and convert it to json, then attach a snippet with the results
    Send-SlackBotFile -Channels $channel -path $path > $null
    Remove-Item -Path $path -Force
    return $result | ConvertTo-Json
