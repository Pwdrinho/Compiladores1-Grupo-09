Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$scannerFile = Join-Path $projectRoot "src/scanner.l"
$testsRoot = Join-Path $projectRoot "tests/scanner"
$inputsDir = Join-Path $testsRoot "inputs"
$expectedDir = Join-Path $testsRoot "expected"
$buildDir = Join-Path $PSScriptRoot ".build"
$actualDir = Join-Path $buildDir "actual"
$generatedC = Join-Path $buildDir "lex.yy.c"
$scannerExe = Join-Path $buildDir "scanner_tests.exe"

function Assert-Command([string] $Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing command '$Name'. Install it and try again."
    }
}

function Prepare-Dir([string] $Path) {
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Recurse -Force
    }
    New-Item -Path $Path -ItemType Directory | Out-Null
}

function Build-Scanner {
    & flex "-o$generatedC" $scannerFile
    if ($LASTEXITCODE -ne 0) {
        throw "flex failed while generating '$generatedC'."
    }

    & gcc $generatedC "-o" $scannerExe
    if ($LASTEXITCODE -ne 0) {
        & gcc $generatedC "-o" $scannerExe "-lfl"
        if ($LASTEXITCODE -ne 0) {
            throw "gcc failed while building scanner test binary."
        }
    }
}

function Run-TestCase([string] $InputPath) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
    $expectedPath = Join-Path $expectedDir ($name + ".out")
    $actualPath = Join-Path $actualDir ($name + ".out")

    if (-not (Test-Path $expectedPath)) {
        throw "Expected output file not found: $expectedPath"
    }

    & $scannerExe < $InputPath | Set-Content -Path $actualPath -Encoding ascii

    $expectedRaw = Get-Content -Path $expectedPath -Raw
    $actualRaw = Get-Content -Path $actualPath -Raw

    if ($expectedRaw -eq $actualRaw) {
        Write-Host "PASS $name" -ForegroundColor Green
        return $true
    }

    Write-Host "FAIL $name" -ForegroundColor Red
    Write-Host "  expected: $expectedPath"
    Write-Host "  actual  : $actualPath"
    $expectedLines = Get-Content -Path $expectedPath
    $actualLines = Get-Content -Path $actualPath
    Compare-Object -ReferenceObject $expectedLines -DifferenceObject $actualLines |
        Format-Table -AutoSize |
        Out-String |
        Write-Host
    return $false
}

Assert-Command "flex"
Assert-Command "gcc"

if (-not (Test-Path $scannerFile)) {
    throw "Scanner file not found: $scannerFile"
}
if (-not (Test-Path $inputsDir)) {
    throw "Inputs directory not found: $inputsDir"
}
if (-not (Test-Path $expectedDir)) {
    throw "Expected directory not found: $expectedDir"
}

Prepare-Dir -Path $buildDir
New-Item -Path $actualDir -ItemType Directory | Out-Null
Build-Scanner

$inputs = Get-ChildItem -Path $inputsDir -Filter "*.in" | Sort-Object Name
if ($inputs.Count -eq 0) {
    throw "No test input files found in $inputsDir"
}

$failed = 0
foreach ($input in $inputs) {
    if (-not (Run-TestCase -InputPath $input.FullName)) {
        $failed++
    }
}

$total = $inputs.Count
$passed = $total - $failed
Write-Host ""
Write-Host "Result: $passed/$total tests passed."

if ($failed -gt 0) {
    exit 1
}

exit 0
