# uso: extrai.ps1 <prompt_pronto.md>
# Extrai o texto entre o 2o e o 3o separador '---' (o prompt), sem CR, e carrega no clipboard.
param([string]$f)
$l = [IO.File]::ReadAllLines($f, [Text.Encoding]::UTF8)
$sep = @(); for ($i = 0; $i -lt $l.Length; $i++) { if ($l[$i] -eq '---') { $sep += $i } }
$t = ($l[($sep[1] + 1)..($sep[2] - 1)] -join "`n").Trim("`n", " ")
Set-Clipboard -Value $t
Start-Sleep 1
"len=$($t.Length) clip=$((Get-Clipboard -Raw).Length) seps=$($sep[0..2] -join ',')"
$t.Substring(0, 60)
$t.Substring($t.Length - 60)
