"""Aplica o reparo 1 da FASE3-P2-COT. A resposta pede duas trocas explicitas:
(1) "altere os imports para incluir tela-inicial.dart" com o bloco de imports
completo -> a secao de imports do arquivo (do inicio ate a linha do helper) e
trocada pelo bloco literal; (2) "altere somente a assercao" ->
`expect(find.byType(app.TelaInicialScreen), findsOneWidget);` vira
`expect(find.byType(TelaInicialScreen), findsOneWidget);`.
Por fim confere que a funcao fazerLogin resultante e igual, linha a linha e a
menos da indentacao de 2 espacos e de linhas em branco (o bloco da resposta
tem uma linha em branco a mais entre as duas chamadas enterText), ao bloco "Funcao fazerLogin corrigida" da
resposta (que nao e colado, por estar sem a indentacao do arquivo)."""
import io, sys
resp, alvo = sys.argv[1:]
R = io.open(resp, encoding="utf-8").read().split("\n")
def bloco_apos(marca):
    i = next(k for k, l in enumerate(R) if marca in l)
    a = next(k for k in range(i, len(R)) if R[k].strip().startswith("```")) + 1
    b = next(k for k in range(a, len(R)) if R[k].strip().startswith("```"))
    return R[a:b]
imps = bloco_apos("Correção dos imports e da asserção")
assert imps[-1] == "import '../firebase_test_helper.dart';", imps[-1]
F = io.open(alvo, encoding="utf-8").read().split("\n")
e = next(k for k, l in enumerate(F) if l == "import '../firebase_test_helper.dart';")
assert all(l.startswith("import ") or l == "" for l in F[:e + 1])
F = imps + F[e + 1:]
velho = "expect(find.byType(app.TelaInicialScreen), findsOneWidget);"
novo = "expect(find.byType(TelaInicialScreen), findsOneWidget);"
n = sum(l.strip() == velho for l in F); assert n == 1, n
F = [l.replace(velho, novo) for l in F]
fz = bloco_apos("Função fazerLogin corrigida")
s = next(k for k, l in enumerate(F) if l.strip().startswith("Future<void> fazerLogin("))
fim = next(k for k in range(s, len(F)) if F[k] == "  }")
corpo = [l[2:] for l in F[s:fim + 1] if l.strip()]
assert corpo == [l.rstrip() for l in fz if l.strip()], "fazerLogin difere do bloco da resposta"
io.open(alvo, "w", encoding="utf-8", newline="\n").write("\n".join(F))
print("imports: linhas 1 a", e + 1, "->", len(imps), "linhas; assercao trocada; fazerLogin confere com a resposta")
