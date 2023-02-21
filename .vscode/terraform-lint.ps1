param([System.Boolean]$lintRootModule, [System.String[]]$excluded)
$ErrorActionPreference = 'Stop'

Clear-Host
Write-Host ''
Write-Host "Invoking `"tflint`""

$modules = Get-ChildItem -Recurse -Directory | Where-Object { $_.BaseName -notin $excluded }

try {
  tflint --init
}
catch {
  if ($_.FullyQualifiedErrorId -eq 'CommandNotFoundException') {
    $lintSourceUrl = 'https://github.com/terraform-linters/tflint/releases/latest'
    try {
      $latestVersion = Invoke-WebRequest $lintSourceUrl -ErrorAction Stop
      [version]$version = ($latestVersion.BaseResponse.RequestMessage.RequestUri.AbsoluteUri |
        Select-String -Pattern '(?:(\d+)\.)?(?:(\d+)\.)?(?:(\d+)\.\d+)').Matches.Value
      $lintLatestUrl = "https://github.com/terraform-linters/tflint/releases/download/v$version/tflint_windows_386.zip"
    }
    catch {
      $lintLatestUrl = $lintSourceUrl
    }
    
    Write-Error "TFLint seems not to be installed properly, download it from $lintLatestUrl and add it to your path!"
  }
  else {
    throw $_.Exception
  }
}

$TFLint = @()
foreach ($module in $modules) {
  $relativeModulePath = ('.') + $module.FullName -replace ([regex]::Escape($pwd)), $null
  $containsTFFiles = (Get-ChildItem $relativeModulePath -File '*.tf*' | Measure-Object | Select-Object -ExpandProperty Count) -gt 0
  if (-not$containsTFFiles) {
    Write-Host "skipping `"$relativeModulePath`" (no tf files)" -ForegroundColor DarkGray
    continue
  }
  Write-Host "linting `"$relativeModulePath`"" -ForegroundColor Yellow
  $lintCommand = @(
    '/format:json'
  )
  if ($relativeModulePath -eq '.') {
    $lintCommand += @('/module')
  }
  $lintCommand += @("$relativeModulePath")
  $curTFLint = @{}
  $curTFLint = tflint $lintCommand | ConvertFrom-Json
  $TFLint += $curTFLint
}

if ($lintRootModule) {
  $TFLint += tflint '/format:json' '.' | ConvertFrom-Json
}

$tfLintSelect = $TFLint.Issues |
Select-Object -Property @(
  @{Name = 'File'; Expression = { $_.range.filename } },
  @{Name = 'Directory'; Expression = { Get-Item -Path $_.range.filename | Select-Object -ExpandProperty Directory } },
  @{Name = 'Line'; Expression = { $_.range.start.line } },
  @{Name = 'Column'; Expression = { $_.range.start.column } },
  @{Name = 'Severity'; Expression = { $_.rule.Severity } },
  @{Name = 'Name'; Expression = { $_.rule.name } },
  @{Name = 'Message'; Expression = { $_.message } },
  @{Name = 'Link'; Expression = { $_.rule.link } }
)
$tfLintSelect | Format-List

Write-Host "$([System.Environment]::NewLine)found $($tfLintSelect.Count) issue(s)"
Set-Location $oldWD
$global:tfLintOutput = $tfLintSelect
Write-Host "Hint: for a pwsh object representation of the tfplan, you can checkout the variable `"`$tfLintOutput`"" -ForegroundColor Cyan
