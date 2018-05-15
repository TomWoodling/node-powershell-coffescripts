function Ignore-SelfSignedCerts {
   add-type -TypeDefinition  @"
       using System.Net;
       using System.Security.Cryptography.X509Certificates;
       public class TrustAllCertsPolicy : ICertificatePolicy {
           public bool CheckValidationResult(
               ServicePoint srvPoint, X509Certificate certificate,
               WebRequest request, int certificateProblem) {
               return true;
           }
       }
"@
   [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}


function Get-PicOCR {
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)]    
    [string]$image    
    )

$headers = @{
    'Content-Type'='application/json'
    'Ocp-Apim-Subscription-Key'=$env:COMVIS_KEY
    }

$json_data = @{
    'url'="$image"
    } | ConvertTo-Json # Test connection

$postParams =  @{json_data=$json_data} # Test connection

$url = "https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=unk&detectOrientation =true"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ris = Invoke-RestMethod -Uri $url -Headers $headers -Body $json_data -Method Post 

$script:OCRres = $ris.regions.lines.words | Select-Object -ExpandProperty text

$script:OCRres

}


function Get-DescriptionOfPic {
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)]    
    [string]$image    
    )

$headers = @{
    'Content-Type'='application/json'
    'Ocp-Apim-Subscription-Key'=$env:COMVIS_KEY
    }

$json_data = @{
    'url'="$image"
    } | ConvertTo-Json # Test connection

$postParams =  @{json_data=$json_data} # Test connection

$url = "https://westus.api.cognitive.microsoft.com/vision/v1.0/analyze?visualFeatures=Description&language=en"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ris = Invoke-RestMethod -Uri $url -Headers $headers -Body $json_data -Method Post 

$script:opine = $ris.description.captions.text

return $script:opine

}


function Send-SlackBotFile {
    [CmdletBinding()]
    Param
    (
        # Name of the Service
        [Parameter()]
        [string]$Channels="#bot-conversation",
        $path
    )

    Send-SlackFile -Token $env:HUBOT_SLACK_TOKEN -Channel $Channels -Path $path
    }
    
function Get-TranslateToken {

$headers = @{
    'Ocp-Apim-Subscription-Key'=$env:TRANSLATOR_KEY
    }

$url = "https://api.cognitive.microsoft.com/sts/v1.0/issueToken"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ris = Invoke-RestMethod -Uri $url -Headers $headers -Method Post 

$script:opine = $ris

return $script:opine

}


function Get-LanguageOfPhrase {
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)]    
    [string]$phrase    
    )

$miik = Get-TranslateToken

$muuk = "Bearer" + " " + $miik

$headers = @{
    'authorization'= $muuk
    }

$url = "https://api.microsofttranslator.com/v2/http.svc/Detect?text=$phrase"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ris = Invoke-RestMethod -Uri $url -Headers $headers -Method Get 

$script:opine = $ris.string.'#text'

return $script:opine

}


function Get-Translation {
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)]    
    [string]$phrase,
    $tolang='en'     
    )

$orglang = Get-LanguageOfPhrase -phrase $phrase

$miik = Get-TranslateToken

$muuk = "Bearer" + " " + $miik

$headers = @{
    'authorization'=$muuk
    'from'=$orglang
    }

$url = "https://api.microsofttranslator.com/v2/http.svc/Translate?text=$phrase&to=$tolang"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ris = Invoke-RestMethod -Uri $url -Headers $headers -Method Get 

$script:opine = $ris.string.'#text'

return $script:opine

}


function Import-NewHubotConfiguration
{
    [CmdletBinding()]
    Param
    (
        # Path to the PoshHubot Configuration File
        [Parameter(Mandatory=$true)]
        [ValidateScript({
        if(Test-Path -Path $_ -ErrorAction SilentlyContinue)
        {
            return $true
        }
        else
        {
            throw "$($_) is not a valid path."
        }
        })]
        [string]
        $ConfigPath
    )

    try
    {
        $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
    }
    catch
    {
        throw "There was a problem importing the configuration file. Confirm your JSON formatting."
    }


    return $Config
}


function Install-NewHubot {

    # Took out the forced old version of nodejs from Matt's script (it doesn't work anymore)
        
        [CmdletBinding()]
        Param
        (
            # Path to the PoshHubot Configuration File
            [Parameter(Mandatory=$true,
                       ValueFromPipeline=$true
            )]
            [ValidateScript({
            if(Test-Path -Path $_ -ErrorAction SilentlyContinue)
            {
                return $true
            }
            else
            {
                throw "$($_) is not a valid path."
            }
            })]
            [string]
            $ConfigPath
        )
    
        $Config = Import-NewHubotConfiguration -ConfigPath $ConfigPath
    
        #Install-Chocolatey
    
        Write-Verbose -Message "Installing NodeJS"
        Start-Process -FilePath 'choco.exe' -ArgumentList 'install nodejs.install -y' -Wait -NoNewWindow
    
        Write-Verbose -Message "Installing Git"
        Start-Process -FilePath 'choco.exe' -ArgumentList 'install git.install -y' -Wait -NoNewWindow
    
        Write-Verbose -Message "Reloading Path Enviroment Variables"
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
        Write-Verbose -Message "Installing CoffeeScript"
        Start-Process -FilePath npm -ArgumentList "install -g coffee-script" -Wait -NoNewWindow
    
        Write-Verbose -Message "Installing Hubot Generator"
        Start-Process -FilePath npm -ArgumentList "install -g yo generator-hubot" -Wait -NoNewWindow
    
        Write-Verbose -Message "Installing Forever"
        Start-Process -FilePath npm -ArgumentList "install -g forever" -Wait -NoNewWindow
    
        # Create bot directory
        if (-not(Test-Path -Path $Config.BotPath))
        {
            New-Item -Path $Config.BotPath -ItemType Directory
        }
    
        Write-Verbose -Message "Generating Bot"
        Start-Process -FilePath yo -ArgumentList "hubot --owner=""$($Config.BotOwner)"" --name=""$($Config.BotName)"" --description=""$($Config.BotDescription)"" --adapter=""$($Config.BotAdapter)"" --no-insight" -NoNewWindow -Wait -WorkingDirectory $Config.BotPath
    
    }    