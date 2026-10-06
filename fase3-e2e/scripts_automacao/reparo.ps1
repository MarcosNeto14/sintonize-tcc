# uso: reparo.ps1 <saida.txt> <prompt_reparo_destino.txt> <prompt_reparo_modelo.txt>
# Monta o prompt de reparo (template fixo + saida literal), grava e carrega no clipboard.
param([string]$saida, [string]$destino, [string]$modelo)
$u = New-Object Text.UTF8Encoding $false
$f = [string]([char]96) * 3
$m = [IO.File]::ReadAllText($modelo, $u).Replace("`r", "")
$i = $m.IndexOf("Antes de corrigir, classifique")
$cauda = $m.Substring($i)
$out = [IO.File]::ReadAllText($saida, $u).Replace("`r", "").TrimEnd("`n")
$t = "O teste falhou com o seguinte erro:`n`n" + $f + "`n" + $out + "`n" + $f + "`n`n" + $cauda
if ($destino) { [IO.File]::WriteAllText($destino, $t, $u) }
Set-Clipboard -Value $t.TrimEnd("`n")
"len=$($t.Length)"
