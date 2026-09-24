"""Aplica, sem alterar nenhum token, os trechos da resposta ao reparo 2 (iter2_resposta.md).
Rodar da raiz do repositório.

Aplicados (âncora presente no arquivo):
1. "Na função `preencherCadastroValido`, primeiro faça o campo ficar visível antes do `tap`":
   a declaração `final dropdown = ...` e o `tap(dropdown)` (linhas 109-110) substituídos pelo
   primeiro bloco da resposta. O `await tester.pump();` seguinte é mantido.
2. "os dois primeiros testes de gênero também precisam garantir visibilidade antes do `tap`.
   Algo como: [bloco]": o `await tester.tap(find.text('Confirmar'));` desses dois testes
   (grupo 'GenerosCadastroScreen - validação e estados intermediários') substituído pelo bloco.

Não aplicados: a alternativa com `scrollUntilVisible` (condicional, "Se `ensureVisible` não
resolver"); o toque em Confirmar do teste ponta a ponta e do teste de autenticação, que a
resposta não inclui ("os dois primeiros testes de gênero").
"""
F = 'test/fase2-chatgpt-reexec/integration/icrash_cot_reexec_test.dart'
R = 'fase2-chatgpt-reexec/rodadas/integration/FASE2-ICRASH-COT_REEXEC_transcricao/iter2_resposta.md'
s = open(F, encoding='utf-8').read()
L = open(R, encoding='utf-8').read().split('\n')
fences = [i for i, l in enumerate(L) if l.startswith('```')]


def blk(k):  # k-ésimo bloco de código da resposta (0-based)
    return L[fences[2 * k] + 1:fences[2 * k + 1]]


def indent(lines, pad):
    return '\n'.join(pad + l if l.strip() else '' for l in lines)


b_drop = blk(0)
b_conf = blk(5)
assert b_drop[0].startswith('final dropdown') and b_conf[0].startswith('final confirmar')

# 1. dropdown
old1 = ("    final dropdown = find.byType(DropdownButtonFormField<String>);\n"
        "    await tester.tap(dropdown);\n")
assert s.count(old1) == 1
s = s.replace(old1, indent(b_drop, '    ') + '\n')

# 2. Confirmar nos dois testes do grupo de validação de gêneros
g0 = s.index("group('GenerosCadastroScreen - validação e estados intermediários'")
g1 = s.index("group('GenerosCadastroScreen - autenticação'")
old2 = "        await tester.tap(find.text('Confirmar'));\n"
seg = s[g0:g1]
assert seg.count(old2) == 2
seg = seg.replace(old2, indent(b_conf, '        ') + '\n')
s = s[:g0] + seg + s[g1:]

open(F, 'w', encoding='utf-8', newline='\n').write(s)
print('ok')
