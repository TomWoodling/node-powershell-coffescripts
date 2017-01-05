<#
.Synopsis
    Describes a picture
.DESCRIPTION
    Makes connection to Microsoft Cognitive Services Computer Vision API to get a description
    of any picture
.EXAMPLE
    .\Get-DescriptionOfPicBot.ps1 -image dhcp
#>

    [CmdletBinding()]
    Param
    (
        # Name of the Service
        [Parameter(Mandatory=$true)]
        [string]$pic
    )

    # Create a hashtable for the results
    $result = @{}
    
    # Use try/catch block            
    try
    {
        # Use ErrorAction Stop to make sure we can catch any errors
        $viewp = Get-DescriptionOfPic -image $pic -ErrorAction Stop
        
        # Create a string for sending back to slack. * and ` are used to make the output look nice in Slack. Details: http://bit.ly/MHSlackFormat
        $result.output = "I think it is ``$viewp``"
        
        # Set a successful result
        $result.success = $true
    }
    catch
    {
        # If this script fails we can assume the service did not exist
        $result.output = "No match for ``$Term``"
        
        # Set a failed result
        $result.success = $false
    }
    
    # Return the result and conver it to json
    return $result | ConvertTo-Json
    
