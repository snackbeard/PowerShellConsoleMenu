function Create-ConsoleMenu {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$object,
        [Parameter(Mandatory = $true)]
        [string]$title,
        [Parameter(Mandatory = $true)]
        [int32]$menuLength
    )

    <# 
    ------ object structure ------
    
    $obj = @{
        "1" = @{
            "key" = "key1"
            "value" = "value1"
            "restricted" = $true / $false
            "hasChanged" = $false        <-- default
            "type" = "string" / "int" / "bool"
            "canBeEmpty" = $true / $false
        }
        "2" = @{
            "key" = "key2"
            "value" = "value2"
            "restricted" = $true / $false
            "hasChanged" = $false        <-- default
            "type" = "string" / "int" / "bool"
            "canBeEmpty" = $true / $false
        }
    }       

    ---------------------------------
    #>

    $run = $true
    $maxSize = $menuLength

    #region sort object
    $objectCopy = foreach ($item in $object.GetEnumerator() | Sort Key) {
        $item
    }
    #endregion

    #region titleLength
    $titleSize = $maxSize - $title.Length
    if ($titleSize % 2 -eq 1) {
        $titleSize += 1
    }

    $titleHalf = ""

    for ($i = 0; $i -lt $titleSize / 2; $i++) {
        $titleHalf = $titleHalf + "="
    }
    #endregion

    while ($run) {
        cls
        Write-Host "$titleHalf $title $titleHalf"
        for($i = 1; $i -le $objectCopy.Length; $i++) {
            $text = $object."$i".key
            $value = $object."$i".value
            $restricted = $object."$i".restricted
            $hasChanged = $object."$i".hasChanged

            #region row length
            $keySize = $i.ToString().Length + $text.toString().Length + 3
            try {
                $valueSize = $value.toString().Length
            } catch {
                $valueSize = $value.Length
            }
            $cSize = $keySize + $valueSize
            $spaceCount = ($titleSize + $title.Length + 2) - $cSize

            $space = ""
            for($iSpace = 0; $iSpace -lt $spaceCount; $iSpace++) {
                $space = $space + " "
            }

            $stringToShow = "$i. $text`:" + $space + $value
            #endregion

            Write-Host $stringToShow

        }
        
        Write-Host "`n`nPress C to continue" -ForegroundColor Yellow
        $choice = (Read-Host "`nSelect a number to change the value").ToLower()

        if ($choice -eq 'c') {
            
            return $object

        } elseif ($choice -as [int] -ne $null -and $choice -as [int] -ne 0 -and $choice -as [int] -le $objectCopy.Length) {
            
            if ($object."$choice".restricted -eq $true) {

                Write-Host "You can´t edit this attribute!" -ForegroundColor Red
                Start-Sleep -Seconds 3

            } else {

                $key = $object."$choice".key

                switch ($object."$choice".type) {
                    'string' {
                        $inString = Read-Host "Please enter a new value for $key [string]"
                        if (!$object."$choice".canBeEmpty) {
                            while ($inString -eq $null -or $inString.Length -eq 0) {
                                Write-Host "Can´t be empty" -ForegroundColor Red
                                $inString = Read-Host "Please enter a new value for $key [string]"
                            }
                            $object."$choice".value = $inString
                            $object."$choice".hasChanged = $true
                        } else {
                            $object."$choice".value = $inString
                            $object."$choice".hasChanged = $true
                        }
                    }

                    'int' {
                        $inInt = Read-Host "Please enter a new value for $key [int]"
                        if (!$object."$choice".canBeEmpty) {
                            $runInt = $true
                            while ($runInt) {
                                try {
                                    $inInt = [System.Convert]::ToInt32($inInt)
                                    $runInt = $false
                                    # Write-Host "setting value to inInt"
                                    $object."$choice".value = $inInt
                                    $object."$choice".hasChanged = $true
                                } catch [System.FormatException] {
                                    Write-Host "Value has to be a number! [int]" -ForegroundColor Red
                                    $inInt = Read-Host "Please enter a new value for $key [int]"
                                }
                            }
                        } else {
                            if ($inInt -eq $null -or $inInt.Length -eq 0) {
                                $object."$choice".value = $null
                                $object."$choice".hasChanged = $true
                                # Write-Host "setting value to null"
                            } else {
                                $runInt = $true
                                while ($runInt) {
                                    try {
                                        $inInt = [System.Convert]::ToInt32($inInt)
                                        $runInt = $false
                                        $object."$choice".value = $inInt
                                        $object."$choice".hasChanged = $true
                                        # Write-Host "setting to inInt"
                                    } catch [System.FormatException] {
                                        Write-Host "Value has to be a number! [int]" -ForegroundColor Red
                                        $inInt = Read-Host "Please enter a new value for $key [int]"
                                    }
                                }
                            }
                        }
                    }

                    'bool' {
                        $inBool = Read-Host "Please enter a new value for $key (true/false)"
                        if (!$object."$choice".canBeEmpty) {
                            $runBool = $true
                            while ($runBool) {
                                try {
                                    $inBool = [System.Convert]::ToBoolean($inBool)
                                    $runBool = $false
                                    # Write-Host "setting value to inBool"
                                    $object."$choice".value = $inBool
                                    $object."$choice".hasChanged = $true
                                } catch [System.FormatException] {
                                    Write-Host "Value has to be true or false and can´t be empty! [bool]" -ForegroundColor Red
                                    $inBool = Read-Host "Please enter a new value for $key (true/false) [bool]"
                                }
                            }
                        } else {
                            if ($inBool -eq $null -or $inBool.Length -eq 0) {
                                $object."$choice".value = $null
                                $object."$choice".hasChanged = $true
                                # Write-Host "setting value to null"
                            } else {
                                $runBool = $true
                                while ($runBool) {
                                    try {
                                        $inBool = [System.Convert]::ToBoolean($inBool)
                                        $runBool = $false
                                        $object."$choice".value = $inBool
                                        $object."$choice".hasChanged = $true
                                        # Write-Host "setting to inBool"
                                    } catch [System.FormatException] {
                                        Write-Host "Value has to be true or false! [bool]" -ForegroundColor Red
                                        $inBool = Read-Host "Please enter a new value for $key (true/false) [bool]"
                                    }
                                }
                            }
                        }
                    }
                }

            }

        } elseif ($choice -eq 'overrideAccess') {
            
            $num = Read-Host "Please enter the number of the attribute you want to override"
            $object."$num".restricted = $false

        } elseif ($choice -eq 'overrideValue') {

            $num = Read-Host "Please enter the number of the attribute you want to override"
            $key = $object."$num".key
            $object."$num".value = Read-Host "Please enter a new value for $key" 

        } else { }


    }


}


$obj = @{
    "1" = @{
        "key" = "firstname"
        "value" = "my first name"
        "restricted" = $true
        "hasChanged" = $false
        "type" = "string"
        "canBeEmpty" = $false
    }
    "2" = @{
        "key" = "lastname"
        "value" = "my last name"
        "restricted" = $false
        "hasChanged" = $false
        "type" = "string"
        "canBeEmpty" = $false
    }
    "3" = @{
        "key" = "street"
        "value" = "my street"
        "restricted" = $false
        "hasChanged" = $false
        "type" = "string"
        "canBeEmpty" = $false
    }
}

$obj = Create-ConsoleMenu -object $obj -title "custom title" -menuLength 100