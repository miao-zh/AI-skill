param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Commit,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$File,

    [Parameter(Position = 2)]
    [string]$Output
)

$ErrorActionPreference = "Stop"

if (-not $Output) {
    $leaf = [IO.Path]::GetFileNameWithoutExtension($File)
    $ext = [IO.Path]::GetExtension($File)
    $shortCommit = if ($Commit.Length -gt 7) { $Commit.Substring(0, 7) } else { $Commit }
    $Output = "$leaf-$shortCommit-version$ext"
}

$repoRoot = (& git rev-parse --show-toplevel).Trim()
if (-not $repoRoot) {
    throw "This command must be run inside a Git repository."
}

$tempZip = Join-Path ([IO.Path]::GetTempPath()) ("git-old-word-" + [Guid]::NewGuid().ToString("N") + ".zip")
$normalizedFile = $File -replace "\\", "/"

try {
    & git cat-file -e "${Commit}:$File"
    if ($LASTEXITCODE -ne 0) {
        throw "File was not found in commit: $Commit -- $File"
    }

    & git archive --format=zip --output="$tempZip" $Commit -- "$File"
    if ($LASTEXITCODE -ne 0) {
        throw "git archive failed."
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($tempZip)
    try {
        $entry = $archive.Entries | Where-Object {
            ($_.FullName -replace "\\", "/") -eq $normalizedFile
        } | Select-Object -First 1

        if (-not $entry) {
            throw "File was not found inside archive: $File"
        }

        $outputPath = if ([IO.Path]::IsPathRooted($Output)) {
            $Output
        } else {
            Join-Path (Get-Location) $Output
        }

        $outputDir = Split-Path -Parent $outputPath
        if ($outputDir) {
            New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
        }

        $inputStream = $entry.Open()
        try {
            $outputStream = [IO.File]::Open($outputPath, [IO.FileMode]::Create, [IO.FileAccess]::Write)
            try {
                $inputStream.CopyTo($outputStream)
            } finally {
                $outputStream.Dispose()
            }
        } finally {
            $inputStream.Dispose()
        }
    } finally {
        $archive.Dispose()
    }

    if ([IO.Path]::GetExtension($Output) -ieq ".docx") {
        $docx = [IO.Compression.ZipFile]::OpenRead($outputPath)
        try {
            $names = $docx.Entries | ForEach-Object { $_.FullName }
            if (-not ($names -contains "[Content_Types].xml") -or -not ($names -contains "word/document.xml")) {
                throw "Exported file does not look like a valid docx."
            }
        } finally {
            $docx.Dispose()
        }
    }

    Write-Host "Exported old Word version:"
    Write-Host $outputPath
} finally {
    if (Test-Path -LiteralPath $tempZip) {
        Remove-Item -LiteralPath $tempZip -Force
    }
}
