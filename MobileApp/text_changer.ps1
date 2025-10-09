# Reverse engineer localization - replace hardcoded strings with loc.key
# Run in project root

param(
    [string]$ArbFile = "lib\l10n\app_en.arb"
)

if (-not (Test-Path $ArbFile)) {
    Write-Error "ARB file not found: $ArbFile"
    exit 1
}

# Read and parse ARB file
Write-Host "Reading ARB file: $ArbFile"
$arbContent = Get-Content $ArbFile -Raw -Encoding UTF8
$arbData = $arbContent | ConvertFrom-Json

# Create a hashtable for value-to-key mapping
$valueToKeyMap = @{}
$allValues = @()
$totalKeys = 0

foreach ($property in $arbData.PSObject.Properties) {
    $key = $property.Name
    $value = $property.Value
    
    # Skip @@locale and entries with { or } (placeholders)
    if ($key -eq "@@locale" -or $value -match "[{}]") {
        continue
    }
    
    $valueToKeyMap[$value] = $key
    $allValues += $value
    $totalKeys++
}

Write-Host "Found $totalKeys localizable keys in ARB file"

# Find matches
$matchedStrings = @{}
$unmatchedStrings = @()

foreach ($string in $allValues) {
    if ($valueToKeyMap.ContainsKey($string)) {
        $matchedStrings[$string] = $valueToKeyMap[$string]
    } else {
        $unmatchedStrings += $string
    }
}

Write-Host "Matched $($matchedStrings.Count) strings with ARB keys"
Write-Host "Unmatched strings: $($unmatchedStrings.Count)"

if ($matchedStrings.Count -eq 0) {
    Write-Warning "No matches found. Please check that your ARB file values match your extracted strings."
    exit 0
}

# Display matches for confirmation
Write-Host "`nMatched strings (first 10):"
$matchedStrings.GetEnumerator() | Select-Object -First 10 | ForEach-Object {
    Write-Host "  ""$($_.Key)"" -> loc.$($_.Value)"
}

if ($unmatchedStrings.Count -gt 0) {
    Write-Host "`nUnmatched strings (first 10):"
    $unmatchedStrings | Select-Object -First 10 | ForEach-Object {
        Write-Host "  ""$_"""
    }
}

# Ask for confirmation
$confirmation = Read-Host "`nProceed with replacement? (y/N)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "Operation cancelled."
    exit 0
}

# Process Dart files
$filesModified = 0
$replacementsMade = 0

Write-Host "`nProcessing Dart files..."

Get-ChildItem -Path "./lib" -Recurse -Include *.dart -Exclude app*.dart |
    ForEach-Object {
        $filePath = $_.FullName
        $relativePath = $_.FullName -replace [regex]::Escape((Get-Location).Path + "\"), ""
        
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $originalContent = $content
        $fileReplacements = 0
        
        # Replace each matched string
        foreach ($stringValue in $matchedStrings.Keys) {
            $key = $matchedStrings[$stringValue]
            
            # Escape special regex characters in the string value
            $escapedString = [regex]::Escape($stringValue)
            
            # Replace both single and double quoted versions
            # Double quotes: "string" -> loc.key
            $pattern1 = '"' + $escapedString + '"'
            $replacement1 = "loc.$key"
            
            # Single quotes: 'string' -> loc.key  
            $pattern2 = "'" + $escapedString + "'"
            $replacement2 = "loc.$key"
            
            $beforeCount1 = ($content | Select-String $pattern1 -AllMatches).Matches.Count
            $beforeCount2 = ($content | Select-String $pattern2 -AllMatches).Matches.Count
            
            $content = $content -replace $pattern1, $replacement1
            $content = $content -replace $pattern2, $replacement2
            
            $afterCount1 = ($content | Select-String $pattern1 -AllMatches).Matches.Count
            $afterCount2 = ($content | Select-String $pattern2 -AllMatches).Matches.Count
            
            $replacements = ($beforeCount1 - $afterCount1) + ($beforeCount2 - $afterCount2)
            $fileReplacements += $replacements
        }
        
        # Write back if changes were made
        if ($content -ne $originalContent) {
            $content | Set-Content $filePath -Encoding UTF8 -NoNewline
            $filesModified++
            $replacementsMade += $fileReplacements
            Write-Host "  Modified: $relativePath ($fileReplacements replacements)"
        }
    }

Write-Host "`nCompleted!"
Write-Host "Files modified: $filesModified"
Write-Host "Total replacements made: $replacementsMade"

# Generate import statement reminder
Write-Host "`nDon't forget to add this import to files using loc:"
Write-Host "import 'package:flutter_gen/gen_l10n/app_localizations.dart';"
Write-Host "`nAnd ensure context has access to localizations:"
Write-Host "final loc = AppLocalizations.of(context)!;"

# Save unmatched strings for manual review
if ($unmatchedStrings.Count -gt 0) {
    $unmatchedStrings | ConvertTo-Json | Out-File "unmatched_strings.json" -Encoding UTF8
    Write-Host "`nUnmatched strings saved to: unmatched_strings.json"
}