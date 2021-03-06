﻿<#
.Synopsis
    Gets AD Groups for username.
.DESCRIPTION
    Gets AD Groups for username.
.EXAMPLE
    Get-ADGroupsForUserBot.ps1 -username t.woodling
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
    $path="C:\ps\Results_for_$($User.Replace('.','_')).csv"
    

    # Create a hashtable for the results
    $result = @{}

    try {
        # Use ErrorAction Stop to make sure we can catch any errors
        $groups = Get-UserGroupMembershipRecursive -UserName "$User"
        $groups.memberof | select name | Export-Csv -Path $path -Force -NoTypeInformation
        # Create a string for sending back to slack. * and ` are used to make the output look nice in Slack. Details: http://bit.ly/MHSlackFormat
        $result.output = ":kuribo: Request for $user processed..."
        #Write-Output "Processing request now..."
        if ($groups) {
        Send-SlackBotFile -Channels $channel -path $path > $null
        Remove-Item -Path $path -Force
        }
        # Set a successful result
        $result.success = $true
        }
    catch {

        $clib = ':mariofail:'
        $result.output = "I cannot get details for $User $clib"
        
        # Set a failed result
        $result.success = $false
        }
    # Return the result and convert it to json, then attach a snippet with the results


    return $result | ConvertTo-Json
