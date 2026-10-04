"""Aplica o reparo 3 da FASE3-L4-FS: "Substitua temporariamente apenas o primeiro
teste por este:" — troca o 1o testWidgets do arquivo pelo bloco da resposta, literal."""
import io, sys
resp, alvo = sys.argv[1:]
R = io.open(resp, encoding="utf-8").read().split("\n")
i = next(k for k, l in enumerate(R) if "Substitua temporariamente apenas o primeiro teste" in l)
a = next(k for k in range(i, len(R)) if R[k].strip().startswith("```")) + 1
b = next(k for k in range(a, len(R)) if R[k].strip().startswith("```"))
bloco = R[a:b]
assert bloco[0].strip() == "testWidgets(" and bloco[-1].strip() == ");", (bloco[0], bloco[-1])
F = io.open(alvo, encoding="utf-8").read().split("\n")
s = next(k for k, l in enumerate(F) if l.strip() == "testWidgets(")
assert "login com credenciais válidas navega para a TelaInicialScreen" in F[s + 1]
e = next(k for k in range(s + 1, len(F)) if F[k].strip() == "testWidgets(") - 1
while F[e].strip() == "":
    e -= 1
assert F[e].strip() == ");", F[e]
out = F[:s] + bloco + F[e + 1:]
io.open(alvo, "w", encoding="utf-8", newline="\n").write("\n".join(out))
print("substituidas linhas", s + 1, "a", e + 1, "por", len(bloco), "linhas da resposta (", a + 1, "-", b, ")")
