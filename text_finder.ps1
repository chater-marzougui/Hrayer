# Flutter text extraction script - strict filtering for user-facing strings
# Run in project root

$fileResults = @()
$allStrings = @()

# Patterns to exclude (technical/non-user-facing content)
$excludePatterns = @(
    "^[\s\.\+\-\*\/\=\(\)\[\]\{\}\|\\\^\$\?\!@#%&~`]+$",  # Only special characters/whitespace
    "^\d+$",                                                # Pure numbers
    "^[\d\s\-\(\)\.]+$",                                   # Phone number patterns
    "^[a-zA-Z0-9\.\-_]+@[a-zA-Z0-9\.\-_]+\.[a-zA-Z]+$",  # Email patterns
    "^https?://",                                          # URLs
    "^assets/",                                            # Asset paths
    "^lib/",                                               # Library paths
    "\.dart$",                                             # Dart file references
    "\.png$|\.jpg$|\.jpeg$|\.gif$|\.svg$|\.ico$",        # Image file extensions
    "^[A-Za-z0-9+/]+=*$",                                 # Base64-like strings
    "^AIza[A-Za-z0-9_-]{35}$",                            # Google API keys
    "^\d{10,}$",                                          # Long numeric IDs
    "^\d+:\d+:",                                          # Firebase config patterns
    "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", # UUIDs
    "^[a-z]{2}$",                                         # Language codes
    "^[\^\\$\(\)\[\]\{\}\|\+\*\?\.]+",                   # Regex patterns
    "^\$\{.*\}$",                                         # String interpolation only
    "^[a-zA-Z_][a-zA-Z0-9_]*\.[a-zA-Z_][a-zA-Z0-9_]*",   # Property access patterns
    "Controller|Stream|Future|Widget|State|Build",        # Flutter/Dart keywords
    "firebase|google|android|ios|web",                    # Platform identifiers
    "^[a-z_]+_[a-z_]+\.dart$",                           # Dart file names
    "^com\.",                                             # Package names
    "Authorization|Bearer|Token|Key|Secret|Config|Client-ID"        # Auth/config terms
)

Get-ChildItem -Path "./lib" -Recurse -Include *.dart -Exclude app*.dart, chat_ai.dart |
    ForEach-Object {
        $filePath = $_.FullName
        $relativePath = $_.FullName -replace [regex]::Escape((Get-Location).Path + "\"), ""

        $fileStrings = @()

        # Extract strings with double quotes
        Select-String -Path $filePath -Pattern '"([^"]*)"' -AllMatches |
        Where-Object { 
            -not $_.Line.Trim().StartsWith("import ") -and 
            -not $_.Line.Trim().StartsWith("part ") -and
            -not $_.Line.Trim().StartsWith("//") -and
            -not $_.Line.Contains("RegExp(") -and
            -not $_.Line.Contains("pattern:") -and
            -not $_.Line.Contains("validator:") -and
            -not $_.Line.Contains("assert(")
        } |
        ForEach-Object {
            $lineNumber = $_.LineNumber

            foreach ($match in $_.Matches) {
                $textValue = $match.Groups[1].Value.Trim()
                
                # Skip if empty, too short, or matches exclude patterns
                if ($textValue.Length -ge 3 -and $textValue -notmatch "^\s*$") {
                    $shouldExclude = $false
                    
                    foreach ($pattern in $excludePatterns) {
                        if ($textValue -match $pattern) {
                            $shouldExclude = $true
                            break
                        }
                    }
                    
                    # Additional checks for likely user-facing content
                    $hasLetters = $textValue -match "[a-zA-Z]"
                    $hasSpaces = $textValue -match "\s"
                    $isLikelyUserText = $hasLetters -and ($hasSpaces -or $textValue.Length -gt 8)
                    
                    # Allow shorter strings if they look like labels/buttons
                    $isLikelyLabel = $textValue -match "^[A-Z][a-z]+" -and $textValue.Length -le 20
                    
                    if (-not $shouldExclude -and ($isLikelyUserText -or $isLikelyLabel)) {
                        $fileStrings += [PSCustomObject]@{
                            text = $textValue
                            line = $lineNumber
                        }
                        $allStrings += $textValue
                    }
                }
            }
        }

        # Extract strings with single quotes (more restrictive)
        Select-String -Path $filePath -Pattern "'([^']*)'" -AllMatches |
        Where-Object { 
            -not $_.Line.Trim().StartsWith("import ") -and
            -not $_.Line.Trim().StartsWith("//") -and
            -not $_.Line.Contains("Key(")
        } |
        ForEach-Object {
            $lineNumber = $_.LineNumber

            foreach ($match in $_.Matches) {
                $textValue = $match.Groups[1].Value.Trim()
                
                # More restrictive for single quotes - likely to be keys/IDs
                if ($textValue.Length -ge 4 -and $textValue -match "[a-zA-Z].*\s") {
                    $shouldExclude = $false
                    
                    foreach ($pattern in $excludePatterns) {
                        if ($textValue -match $pattern) {
                            $shouldExclude = $true
                            break
                        }
                    }
                    
                    if (-not $shouldExclude) {
                        $fileStrings += [PSCustomObject]@{
                            text = $textValue
                            line = $lineNumber
                        }
                        $allStrings += $textValue
                    }
                }
            }
        }

        # Only add files that have strings
        if ($fileStrings.Count -gt 0) {
            $fileResults += [PSCustomObject]@{
                file = $relativePath
                strings = $fileStrings | Sort-Object line
            }
        }
    }

# Sort file results by file name
$fileResults = $fileResults | Sort-Object file

# Create unique strings list for translation (additional filtering)
$uniqueStrings = $allStrings | 
    Sort-Object -Unique |
    Where-Object { 
        $_.Length -ge 3 -and 
        $_ -match "[a-zA-Z]" -and
        $_ -notmatch "^[\d\s\-\(\)\.]+$" -and  # Remove remaining number-like strings
        $_ -notmatch "^\$" -and                 # Remove strings starting with $
        $_ -notmatch "^[a-z_]+$"               # Remove simple identifiers
    }

# Output main file with file-grouped strings
$fileResults | ConvertTo-Json -Depth 3 | Out-File "flutter_strings_by_file.json" -Encoding UTF8

# Output translation file with just unique strings
$uniqueStrings | ConvertTo-Json -Depth 1 | Out-File "translation_strings.json" -Encoding UTF8

Write-Host "Extracted strings from $($fileResults.Count) files to flutter_strings_by_file.json"
Write-Host "Created translation file with $($uniqueStrings.Count) unique strings: translation_strings.json"
Write-Host "Total string occurrences found: $($allStrings.Count)"