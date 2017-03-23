function New-CredObject {
param(
       [Parameter(Mandatory=$true,HelpMessage="Credential name",ValueFromPipeline=$true,Position=1)]
           [string]$credname,
       [Parameter(Mandatory=$true,HelpMessage="User name to pass",ValueFromPipeline=$true,Position=2)]
           [string]$user,
       [Parameter(Mandatory=$true,HelpMessage="Password",ValueFromPipeline=$true,Position=3)]
           [string]$pass
)
$credpath = "c:\crobot\creds\($env:USERNAME)Cred_$credname.xml"
New-Object System.Management.Automation.PSCredential("$user", (ConvertTo-SecureString -AsPlainText -Force "$pass")) | Export-CliXml $credpath -Force
}



Function Get-NewAsciiPass() {
Param(
[int]$length=12
)
$ascii=$NULL;For ($a=48;$a –le 122;$a++) {$ascii+=,[char][byte]$a}
For ($loop=1; $loop –le $length; $loop++) {
           $TempPassword+=($ascii | GET-RANDOM)
           }
return $TempPassword
}



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


function Get-SSApitest {

param
    (
    [Parameter(Mandatory=$true)]
    $serv,
    [Parameter(Mandatory=$true)]
    [ValidateSet('Start','Stop','Restart')]
    $state
    )

$json_data = @{
        'key1' = 'value1'
        'key2' = $serv
        'key3' = $state
    } | ConvertTo-Json # Test connection

$postParams =  @{'St2-Api-Key'=$env:ST2_API_KEY;"Content-Type"='application/json'} # Test connection

$server = "https://$env:ST2ip"
$url = "/api/v1/webhooks/sample"

Ignore-SelfSignedCerts

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ris = Invoke-WebRequest -Uri $server$url -Headers $postParams -Body $json_data -Method Post 

$script:objects = $ris.Content #| ConvertFrom-Json | Select-Object -ExpandProperty objects

#$script:added = $objects."$($output.name)".fields

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

$url = "https://api.projectoxford.ai/vision/v1.0/ocr?language=unk&detectOrientation =true"

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

$url = "https://api.projectoxford.ai/vision/v1.0/analyze?visualFeatures=Description&language=en"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ris = Invoke-RestMethod -Uri $url -Headers $headers -Body $json_data -Method Post 

$script:opine = $ris.description.captions.text

return $script:opine

}


function Get-EncQuery {
[cmdletbinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$query
)

$htmlQ = [uri]::EscapeUriString($query.replace('?',''))
$script:cyclos = New-Object System.Collections.ArrayList
$hmmz = Invoke-RestMethod -uri  "https://api.projectoxford.ai/luis/v2.0/apps/$env:LUIS_APP?subscription-key=$env:LUIS_SUB&q=$htmlQ"
$shhz = $hmmz.entities 
foreach ($shh in $shhz) {
    $cat = $shh.type.split('.')[2]
    $subcat = $shh.type.split('.')[3]
    if ($cat -eq $subcat) {
        $add = "$($shh.entity) is a $cat"
        }
    else {
        $add = "$($shh.entity) is a $cat $subcat"
        }
    $script:cyclos.Add($add) > $null
    }
$script:cyclos
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