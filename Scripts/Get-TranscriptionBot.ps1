<#
.Synopsis
    Transcribes a phrase to the specified language
.DESCRIPTION
    Makes connection to Microsoft Cognitive Services Translator API
.EXAMPLE
    .\Get-TranscriptionBot.ps1 -phrase 'Hola soy un gato' -tolang ro
#>

    [CmdletBinding()]
    Param
    (
        # Name of the Service
        [Parameter(Mandatory=$true)]
        [string]$phrase,
        [Parameter(Mandatory=$true)]
        [string]$language
    )

    # Create a hashtable for the results
    $result = @{}

    # Get the correct language code
    $slangs =   "ar",
                "cs",
                "da",
                "de",
                "en",
                "et",
                "fi",
                "fr",
                "nl",
                "el",
                "he",
                "ht",
                "hu",
                "id",
                "it",
                "ja",
                "ko",
                "lt",
                "lv",
                "no",
                "pl",
                "pt",
                "ro",
                "es",
                "ru",
                "sk",
                "sl",
                "sv",
                "th",
                "tr",
                "uk",
                "vi",
                "zh-CHS"

    $slings =   "Arabic",
                "Czech",
                "Danish",
                "German",
                "English",
                "Estonian",
                "Finnish",
                "French",
                "Dutch",
                "Greek",
                "Hebrew",
                "Haitian",
                "Hungarian",
                "Indonesian",
                "Italian",
                "Japanese",
                "Korean",
                "Lithuanian",
                "Latvian",
                "Norwegian",
                "Polish",
                "Portuguese",
                "Romanian",
                "Spanish",
                "Russian",
                "Slovak",
                "Slovene",
                "Swedish",
                "Thai",
                "Turkish",
                "Ukrainian",
                "Vietnamese",
                "Chinese"                                                                                                       

    if ($language -in $slangs) {$tolang = $language}
    elseif ($language -in $slings) {
        $tolang = switch ($language) {
            "Arabic" {"ar"}
            "Czech" {"cs"}
            "Danish" {"da"}
            "German" {"de"}
            "English" {"en"}
            "Estonian" {"et"}
            "Finnish" {"fi"}
            "French" {"fr"}
            "Dutch" {"nl"}
            "Greek" {"el"}
            "Hebrew" {"he"}
            "Haitian" {"ht"}
            "Hungarian" {"hu"}
            "Indonesian" {"id"}
            "Italian" {"it"}
            "Japanese" {"ja"}
            "Korean" {"ko"}
            "Lithuanian" {"lt"}
            "Latvian" {"lv"}
            "Norwegian" {"no"}
            "Polish" {"pl"}
            "Portuguese" {"pt"}
            "Romanian" {"ro"}
            "Spanish" {"es"}
            "Russian" {"ru"}
            "Slovak" {"sk"}
            "Slovene" {"sl"}
            "Swedish" {"sv"}
            "Thai" {"th"}
            "Turkish" {"tr"}
            "Ukrainian" {"uk"}
            "Vietnamese" {"vi"}
            "Chinese" {"zh-CHS"}
            }
        }
    else {$tolang = "en"}
    
    # Use try/catch block            
    try
    {
        # Use ErrorAction Stop to make sure we can catch any errors
        $transcribe = Get-Translation -phrase "$phrase" -tolang "$tolang" -ErrorAction Stop
        
        # Create a string for sending back to slack. * and ` are used to make the output look nice in Slack. Details: http://bit.ly/MHSlackFormat
        $result.output = "``$transcribe``"
        
        # Set a successful result
        $result.success = $true
    }
    catch
    {
        # If this script fails we can assume the service did not exist
        $result.output = "No match for ``$phrase``"
        
        # Set a failed result
        $result.success = $false
    }
    
    # Return the result and conver it to json
    return $result | ConvertTo-Json
    
