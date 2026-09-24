"""Aplica, sem alterar nenhum token, os patches da resposta ao reparo 2 (iter2_resposta.md)
sobre o arquivo de teste. Rodar da raiz do repositório.

Patches aplicados, na ordem em que a resposta os apresenta:
1. "Helpers corrigidos": insere tocarWidgetVisivel e preencherCampo e substitui preencherCadastro.
2. "Cadastro": todo `tap` em Cadastrar + pumpAndSettle -> tocarWidgetVisivel ("nos três testes").
3. "Confirmar gêneros": idem para Confirmar.
4. "Switches": todo `tap` em SwitchListTile 'Rock'/'Jazz'/'Pop' -> tocarWidgetVisivel.
5. "TelaInicialScreen": acrescenta o import e, no fim do teste ponta a ponta, o expect de TelaInicialScreen.
"""
import re

F = 'test/fase2-chatgpt-reexec/integration/icrash_zs_test.dart'
R = 'fase2-chatgpt-reexec/rodadas/integration/FASE2-ICRASH-ZS_transcricao/iter2_resposta.md'
src = open(F, encoding='utf-8').read()
L = open(R, encoding='utf-8').read().split('\n')


def block(open_fence_line, close_fence_line):
    return '\n'.join(L[open_fence_line:close_fence_line - 1])


def ws_pattern(snippet):
    toks = re.split(r'\s+', snippet.strip())
    return r'\s*'.join(re.escape(t) for t in toks)


def replace_all(s, old, new, expected_min=1):
    pat = re.compile(ws_pattern(old))
    n = len(pat.findall(s))
    assert n >= expected_min, (old[:60], n)
    return pat.sub(lambda m: new, s), n


helpers = block(23, 115)
# 1. helpers: substitui preencherCadastro existente pelo bloco (que contém os 3 helpers)
i = src.index('Future<void> preencherCadastro(WidgetTester tester) async {')
depth, j = 0, src.index('{', i)
while True:
    if src[j] == '{':
        depth += 1
    elif src[j] == '}':
        depth -= 1
        if depth == 0:
            break
    j += 1
src = src[:i] + helpers + src[j + 1:]

# 2. Cadastrar
src, n_cad = replace_all(src, block(123, 132), block(136, 144))
# 3. Confirmar
src, n_conf = replace_all(src, block(152, 161), block(165, 173))
# 4. Switches
n_sw = 0
for nome in ('Rock', 'Jazz', 'Pop'):
    old = "await tester.tap( find.widgetWithText( SwitchListTile, '%s', ), );" % nome
    new = "await tocarWidgetVisivel(\n  tester,\n  find.widgetWithText(\n    SwitchListTile,\n    '%s',\n  ),\n);" % nome
    pat = re.compile(ws_pattern(old))
    k = len(pat.findall(src))
    src = pat.sub(lambda m: new, src)
    n_sw += k
# 5. TelaInicialScreen
imp = block(289, 291)
src = src.replace("import 'package:sintonize/generos-cadastro.dart';\n",
                  "import 'package:sintonize/generos-cadastro.dart';\n" + imp + '\n', 1)
old_end = block(278, 283)  # expect(find.byType(GenerosCadastroScreen), findsNothing);
pat = re.compile(ws_pattern(old_end))
m = pat.search(src)
assert m
src = src[:m.end()] + '\n' + block(295, 300) + src[m.end():]
open(F, 'w', encoding='utf-8', newline='\n').write(src)
print('cadastrar', n_cad, 'confirmar', n_conf, 'switches', n_sw)
