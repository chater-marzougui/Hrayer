# Flutter text extraction script - enhanced to catch widget parameter strings
# Run in project root

$fileResults = @()
$allStrings = @()

# Patterns to exclude (technical/non-user-facing content)
$excludePatternsBase = @(
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
$excludePatterns = @(
    "^\d+$",
    "^\$\{.*\}$",
    "^[a-zA-Z_][a-zA-Z0-9_]*\.[a-zA-Z_][a-zA-Z0-9_]*",
    "Controller|Stream|Future|Widget|State|Build",
    "firebase|google|android|ios|web",
    "^[a-z_]+_[a-z_]+\.dart$",
    "^com\.",
    "Authorization|Bearer|Token|Key|Secret|Config|Client-ID"
)



function Test-ShouldExclude($text) {
    if ([string]::IsNullOrWhiteSpace($text) -or $text.Length -lt 2) {
        return $true
    }
    
    foreach ($pattern in $excludePatterns) {
        if ($text -match $pattern) {
            return $true
        }
    }
    
    return $false
}

function Test-IsUserFacingText($text) {
    # Must contain letters
    if (-not ($text -match "[a-zA-Z]")) {
        return $false
    }
    
    # Skip very short strings unless they look like common UI elements
    if ($text.Length -lt 2) {
        return $false
    }
    
    # Skip very long strings (likely to be technical)
    if ($text.Length -gt 100) {
        return $false
    }
    
    # Good indicators of user-facing text
    $hasSpaces = $text -match "\s"
    $startsWithCapital = $text -match "^[A-Z]"
    $containsWords = $text -match "\b[a-zA-Z]{2,}\b"
    $isCommonUIWord = $text -match "^(Login|Logout|Cancel|Save|Delete|Edit|Add|Remove|Continue|Back|Next|Submit|OK|Yes|No|Profile|Dashboard|Settings|Help|About|Home|Search|Filter|Sort|Upload|Download|Share|Print|Export|Import|Refresh|Update|Create|New|Open|Close|Exit|Start|Stop|Play|Pause|Reset|Clear|Copy|Paste|Cut|Select|All|None|More|Less|Show|Hide|View|Preview|Details|Summary|Total|Count|Size|Date|Time|Name|Title|Description|Status|Type|Category|Tag|Label|Group|List|Item|Page|Section|Chapter|Article|Post|Comment|Reply|Message|Chat|Call|Email|Phone|Address|Location|Map|Image|Photo|Video|Audio|File|Document|Report|Chart|Graph|Table|Row|Column|Header|Footer|Menu|Button|Link|Icon|Badge|Alert|Warning|Error|Success|Info|Loading|Empty|Full|Available|Unavailable|Online|Offline|Active|Inactive|Enabled|Disabled|Public|Private|Draft|Published|Pending|Completed|Failed|Processing|Waiting)$"
    
    # Accept strings that:
    # 1. Have spaces (likely sentences/phrases)
    # 2. Start with capital and contain actual words
    # 3. Are common UI words even if short
    # 4. Look like proper labels (capital + reasonable length)
    return ($hasSpaces -and $containsWords) -or 
           ($startsWithCapital -and $containsWords -and $text.Length -ge 3) -or
           $isCommonUIWord -or
           ($startsWithCapital -and $text.Length -ge 4 -and $text.Length -le 20 -and -not ($text -match "[0-9]"))
}

Get-ChildItem -Path "./lib" -Recurse -Include *.dart -Exclude app*.dart, chat_ai.dart, firebase_options.dart |
    ForEach-Object {
        $filePath = $_.FullName
        $relativePath = $_.FullName -replace [regex]::Escape((Get-Location).Path + "\"), ""
        $content = Get-Content -Path $filePath -Raw

        $fileStrings = @()

        # Method 1: Extract ALL quoted strings (both single and double quotes) - Less restrictive
        # Double quotes
        Select-String -Path $filePath -Pattern '"([^"]*)"' -AllMatches |
        Where-Object { 
            -not $_.Line.Trim().StartsWith("import ") -and 
            -not $_.Line.Trim().StartsWith("part ") -and
            -not $_.Line.Trim().StartsWith("//") -and
            -not $_.Line.Contains("RegExp(") -and
            -not $_.Line.Contains("assert(") -and
            -not $_.Line.Contains("@override") -and
            -not $_.Line.Contains("factory ") -and
            $_.Line -notmatch "^\s*(class|enum|mixin|extension)\s"
        } |
        ForEach-Object {
            $lineNumber = $_.LineNumber
            foreach ($match in $_.Matches) {
                $textValue = $match.Groups[1].Value.Trim()
                
                if (-not (Test-ShouldExclude $textValue) -and (Test-IsUserFacingText $textValue)) {
                    $fileStrings += [PSCustomObject]@{
                        text = $textValue
                        line = $lineNumber
                        context = "double_quoted"
                    }
                    $allStrings += $textValue
                }
            }
        }

        # Single quotes - LESS restrictive than before
        Select-String -Path $filePath -Pattern "'([^']*)'" -AllMatches |
        Where-Object { 
            -not $_.Line.Trim().StartsWith("import ") -and
            -not $_.Line.Trim().StartsWith("part ") -and
            -not $_.Line.Trim().StartsWith("//") -and
            -not $_.Line.Contains("Key(") -and
            -not $_.Line.Contains("RegExp(") -and
            -not $_.Line.Contains("assert(") -and
            $_.Line -notmatch "^\s*(class|enum|mixin|extension)\s"
        } |
        ForEach-Object {
            $lineNumber = $_.LineNumber
            foreach ($match in $_.Matches) {
                $textValue = $match.Groups[1].Value.Trim()
                
                # MUCH less restrictive for single quotes now
                if (-not (Test-ShouldExclude $textValue) -and (Test-IsUserFacingText $textValue)) {
                    $fileStrings += [PSCustomObject]@{
                        text = $textValue
                        line = $lineNumber
                        context = "single_quoted"
                    }
                    $allStrings += $textValue
                }
            }
        }

        # Method 2: Simple regex for common function patterns
        # Look for function calls with string parameters
        $functionPatterns = @(
            "_buildInfoRow\s*\(\s*['`"]([^'`"]+)['`"]",  # _buildInfoRow('Title', ...)
            "Text\s*\(\s*['`"]([^'`"]+)['`"]",           # Text('Logout')
            "AlertDialog\s*\([^)]*title\s*:\s*(?:const\s+)?Text\s*\(\s*['`"]([^'`"]+)['`"]" # AlertDialog title
        )
        
        foreach ($pattern in $functionPatterns) {
            Select-String -Path $filePath -Pattern $pattern -AllMatches |
            ForEach-Object {
                $lineNumber = $_.LineNumber
                foreach ($match in $_.Matches) {
                    if ($match.Groups.Count -gt 1) {
                        $textValue = $match.Groups[1].Value.Trim()
                        
                        if (-not (Test-ShouldExclude $textValue) -and (Test-IsUserFacingText $textValue)) {
                            # Check if we already have this string (avoid duplicates)
                            $duplicate = $fileStrings | Where-Object { $_.text -eq $textValue -and [Math]::Abs($_.line - $lineNumber) -le 2 }
                            
                            if (-not $duplicate) {
                                $fileStrings += [PSCustomObject]@{
                                    text = $textValue
                                    line = $lineNumber
                                    context = "function_pattern"
                                }
                                $allStrings += $textValue
                            }
                        }
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

# Create unique strings list for translation with additional filtering
$uniqueStrings = $allStrings | 
    Sort-Object -Unique |
    Where-Object { 
        $_.Length -ge 2 -and 
        $_ -match "[a-zA-Z]" -and # Must contain letters
        $_ -notmatch "^[\d\s\-\(\)\.]+$" 
    }

# Output main file with file-grouped strings (including context info)
$fileResults | ConvertTo-Json -Depth 4 | Out-File "flutter_strings_by_file.json" -Encoding UTF8

# Output translation file with just unique strings
$uniqueStrings | ConvertTo-Json -Depth 1 | Out-File "translation_strings.json" -Encoding UTF8

Write-Host "Extracted strings from $($fileResults.Count) files to flutter_strings_by_file.json"
Write-Host "Created translation file with $($uniqueStrings.Count) unique strings: translation_strings.json"
Write-Host "Total string occurrences found: $($allStrings.Count)"

# Show summary by context type
$contextSummary = @{}
$fileResults | ForEach-Object { 
    $_.strings | ForEach-Object { 
        $context = $_.context
        if ($contextSummary.ContainsKey($context)) {
            $contextSummary[$context]++
        } else {
            $contextSummary[$context] = 1
        }
    }
}

Write-Host "`nString extraction summary by context:"
$contextSummary.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "  $($_.Key): $($_.Value) strings"
}