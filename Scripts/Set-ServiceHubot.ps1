<#
.Synopsis
    Service command processor for hubot.
.DESCRIPTION
    Service command processor for hubot.
.EXAMPLE
    Set-SerivceHubot -Name dhcp -Room slackstorm -Status start
#>

   [CmdletBinding()]
    Param
    (
        # Name of the Service
        [Parameter(Mandatory=$true)]
        $Serv,
		[Parameter(Mandatory=$true)]
		[ValidateSet("Stop","Start","Restart")]
		$Status
    )

    # Create a hashtable for the results
    $result = @{}

    # Use try/catch block            
    try
    {
        # Use ErrorAction Stop to make sure we can catch any errors
        if ($Status -eq 'Start') {Start-Service -Name $Serv}
        elseif ($Status -eq 'Stop') {Stop-Service -Name $Serv}
        elseif ($Status -eq 'Restart') {Restart-Service -Name $Serv}
        else {
            $result.output = "Service $($Serv) does not exist on this server."
            exit
            }
        Start-Sleep -Seconds 2
        $service = Get-Service -Name $Serv -ErrorAction Stop
        
        # Create a string for sending back to slack. * and ` are used to make the output look nice in Slack. Details: http://bit.ly/MHSlackFormat
        $result.output = "Service $($service.Name) (*$($service.DisplayName)*) is now ``$($service.Status.ToString())``."
        
        # Set a successful result
        $result.success = $true
    }
    catch
    {
        # If this script fails we can assume the service did not exist
        $result.output = "Service $($Serv) does not exist on this server."
        
        # Set a failed result
        $result.success = $false
    }
    
    # Return the result and conver it to json

    return $result | ConvertTo-Json
   