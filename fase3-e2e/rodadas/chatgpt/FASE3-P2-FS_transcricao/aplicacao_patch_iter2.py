"""Aplica o reparo 2 da FASE3-P2-FS: "No `p2_fs_test.dart`, use estes imports:" —
troca a secao de imports do arquivo (do inicio ate a linha do helper) pelo
bloco da resposta, literal."""
import io, sys
resp, alvo = sys.argv[1:]
R = io.open(resp, encoding="utf-8").read().split("\n")
i = next(k for k, l in enumerate(R) if "use estes imports" in l)
a = next(k for k in range(i, len(R)) if R[k].strip().startswith("```")) + 1
b = next(k for k in range(a, len(R)) if R[k].strip().startswith("```"))
bloco = R[a:b]
assert bloco[-1] == "import '../firebase_test_helper.dart';", bloco[-1]
F = io.open(alvo, encoding="utf-8").read().split("\n")
e = next(k for k, l in enumerate(F) if l == "import '../firebase_test_helper.dart';")
assert all(l.startswith("import ") or l == "" for l in F[:e + 1])
out = bloco + F[e + 1:]
io.open(alvo, "w", encoding="utf-8", newline="\n").write("\n".join(out))
print("imports: linhas 1 a", e + 1, "substituidas por", len(bloco), "linhas da resposta")
