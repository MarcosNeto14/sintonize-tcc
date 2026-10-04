"""Aplica o reparo 2 da FASE3-L4-COT: "Adicione o import: import 'package:sintonize/tela-inicial.dart';
E substitua **somente o teste de sucesso** por:" — insere o import depois do
ultimo import 'package:sintonize/...' e troca o 1o testWidgets pelo bloco, literal."""
import io, sys
resp, alvo = sys.argv[1:]
R = io.open(resp, encoding="utf-8").read().split("\n")
def bloco_apos(marcador):
    i = next(k for k, l in enumerate(R) if marcador in l)
    a = next(k for k in range(i, len(R)) if R[k].strip().startswith("```")) + 1
    b = next(k for k in range(a, len(R)) if R[k].strip().startswith("```"))
    return R[a:b]
imp = bloco_apos("Adicione o import")
assert imp == ["import 'package:sintonize/tela-inicial.dart';"], imp
teste = bloco_apos("substitua **somente o teste de sucesso** por")
assert teste[0].strip() == "testWidgets(" and teste[-1].strip() == ");", (teste[0], teste[-1])
F = io.open(alvo, encoding="utf-8").read().split("\n")
assert imp[0] not in F
u = max(k for k, l in enumerate(F) if l.startswith("import 'package:sintonize/"))
F = F[:u + 1] + imp + F[u + 1:]
s = next(k for k, l in enumerate(F) if l.strip() == "testWidgets(")
assert "login válido" in F[s + 1], F[s + 1]
e = next(k for k in range(s + 1, len(F)) if F[k].strip() == "testWidgets(") - 1
while F[e].strip() == "":
    e -= 1
assert F[e].strip() == ");", F[e]
out = F[:s] + teste + F[e + 1:]
io.open(alvo, "w", encoding="utf-8", newline="\n").write("\n".join(out))
print("import inserido apos a linha", u + 1, "; teste de sucesso: linhas", s + 1, "a", e + 1, "->", len(teste), "linhas")
