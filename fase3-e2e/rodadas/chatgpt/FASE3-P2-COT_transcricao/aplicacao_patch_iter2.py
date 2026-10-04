"""Aplica o reparo 2 da FASE3-P2-COT. A resposta pede tres substituicoes
explicitas de unidades inteiras:
(1) "Substitua a funcao por esta" -> navegarAteCriarPlaylist;
(2) "Corrija esperarMusicasCarregadas" (bloco "esperarMusicasCarregadas
    corrigida") -> esperarMusicasCarregadas;
(3) "Substitua o ultimo teste por" -> o ultimo testWidgets do arquivo.
Cada unidade do arquivo (da linha de abertura ate o fechamento com dois espacos
de indentacao) e trocada pelo bloco literal da resposta, sem reindentar
(precedente: FASE3-L4-COT, reparo 1)."""
import io, sys
resp, alvo = sys.argv[1:]
R = io.open(resp, encoding="utf-8").read().split("\n")
def bloco_apos(marca):
    i = next(k for k, l in enumerate(R) if marca in l)
    a = next(k for k in range(i, len(R)) if R[k].strip().startswith("```")) + 1
    b = next(k for k in range(a, len(R)) if R[k].strip().startswith("```"))
    return R[a:b]
nav = bloco_apos("navegarAteCriarPlaylist corrigida")
esp = bloco_apos("esperarMusicasCarregadas corrigida")
ult = bloco_apos("Teste de estado de carregamento corrigido")
assert nav[0].startswith("Future<void> navegarAteCriarPlaylist(") and nav[-1] == "}"
assert esp[0].startswith("Future<void> esperarMusicasCarregadas(") and esp[-1] == "}"
assert ult[0] == "testWidgets(" and ult[-1] == ");"
F = io.open(alvo, encoding="utf-8").read().split("\n")
def faixa(ini_pred, fecho):
    s = next(k for k, l in enumerate(F) if ini_pred(l))
    e = next(k for k in range(s + 1, len(F)) if F[k] == fecho)
    return s, e
# de baixo para cima, para nao deslocar indices
s3 = max(k for k, l in enumerate(F) if l == "  testWidgets(")
e3 = next(k for k in range(s3 + 1, len(F)) if F[k] == "  );")
F[s3:e3 + 1] = ult
s2, e2 = faixa(lambda l: l.startswith("  Future<void> esperarMusicasCarregadas("), "  }")
F[s2:e2 + 1] = esp
s1, e1 = faixa(lambda l: l.startswith("  Future<void> navegarAteCriarPlaylist("), "  }")
F[s1:e1 + 1] = nav
io.open(alvo, "w", encoding="utf-8", newline="\n").write("\n".join(F))
print("trocas: navegarAteCriarPlaylist", (s1 + 1, e1 + 1), "esperarMusicasCarregadas", (s2 + 1, e2 + 1), "ultimo testWidgets", (s3 + 1, e3 + 1))
