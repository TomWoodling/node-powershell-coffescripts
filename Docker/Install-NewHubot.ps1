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

    $Config = Import-HubotConfiguration -ConfigPath $ConfigPath

    Install-Chocolatey

    Write-Verbose -Message "Installing NodeJS"
    Start-Process -FilePath 'choco.exe' -ArgumentList 'install nodejs.install -y' -Wait -NoNewWindow

    Write-Verbose -Message "Installing Git"
    Start-Process -FilePath 'choco.exe' -ArgumentList 'install git.install -y' -Wait -NoNewWindow

    Write-Verbose -Message "Reloading Path Enviroment Variables"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Verbose -Message "Installing CoffeeScript"
    Start-Process -FilePath npm -ArgumentList "install -g coffee-script" -Wait -NoNewWindow

    Write-Verbose -Message "Installing Hubot Generator"
    Start-Process -FilePath npm -ArgumentList "install -g yo generator-hubot@1.0.0" -Wait -NoNewWindow

    Write-Verbose -Message "Installing Forever"
    Start-Process -FilePath npm -ArgumentList "install -g forever" -Wait -NoNewWindow

    # Create bot directory
    if (-not(Test-Path -Path $Config.BotPath))
    {
        New-Item -Path $Config.BotPath -ItemType Directory
    }

    Write-Verbose -Message "Generating Bot"
    Start-Process -FilePath yo -ArgumentList "hubot --owner=""$($Config.BotOwner)"" --name=""$($Config.BotName)"" --description=""$($Config.BotDescription)"" --adapter=""$($Config.BotAdapter)"" --no-insight" -NoNewWindow -Wait -WorkingDirectory $Config.BotPath