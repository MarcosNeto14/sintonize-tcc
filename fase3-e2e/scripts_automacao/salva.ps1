# uso: salva.ps1 <dir_transcricao> <N> <rotulo> <rodada> <conversa> <teste_no_worktree>
# Grava iterN_resposta.md do clipboard (com cabecalho); se houver bloco dart, grava teste_iterN.dart e aplica no worktree.
param([string]$dir, [int]$n, [string]$rotulo, [string]$rodada, [string]$conversa, [string]$alvo)
$u = New-Object Text.UTF8Encoding $false
$c = Get-Clipboard -Raw
if ($c -match '^SENTINELA' -or $c -match '^O teste falhou com o seguinte erro' -or $c -match '^Gere um teste end-to-end') { "CLIPBOARD INVALIDO - nada gravado"; exit 1 }
$h = "<!-- Resposta do Gemini 3.8 Flash $rotulo, rodada $rodada, 2026-10-06, sem edi" + [char]0xE7 + [char]0xE3 + "o.`n     Markdown do bot" + [char]0xE3 + "o `"Copiar`" da resposta. Envio e c" + [char]0xF3 + "pia automatizados (Claude in Chrome).`n     Conversa: $conversa -->`n`n"
[IO.File]::WriteAllText("$dir\iter${n}_resposta.md", $h + $c, $u)
# blocos por linha: abre em linha '```dart', fecha na proxima linha que seja so '```'
$L = $c.Replace("`r", "").Split("`n"); $blocos = @(); $ini = -1
for ($i = 0; $i -lt $L.Length; $i++) {
  if ($ini -lt 0 -and $L[$i] -match '^```dart\s*$') { $ini = $i + 1 }
  elseif ($ini -ge 0 -and $L[$i] -match '^```\s*$') { $blocos += , (($L[$ini..($i - 1)] -join "`n") + "`n"); $ini = -1 }
}
"len=$($c.Length) blocos=$($blocos.Count) tamanhos=$(($blocos | % { $_.Length }) -join ',')"
if ($blocos.Count -gt 0) {
  $code = $blocos | Sort-Object { $_.Length } -Descending | Select-Object -First 1
  [IO.File]::WriteAllText("$dir\teste_iter$n.dart", $code, $u)
  [IO.File]::WriteAllText($alvo, $code, $u)
  "aplicado: $($code.Length) caracteres"
}
