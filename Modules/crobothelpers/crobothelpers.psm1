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