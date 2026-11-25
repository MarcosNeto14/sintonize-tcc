# -*- coding: utf-8 -*-
import json, csv, sys, os, re
from collections import Counter
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill
from openpyxl.utils import get_column_letter

S, OUTX = sys.argv[1], sys.argv[2]
data = json.load(open(S + '/extract.json', encoding='utf-8'))
rows = list(csv.reader(open(S + '/piramide_rodadas.csv', encoding='utf-8')))
hdr = rows[0]
pir = {(dict(zip(hdr, r))['Modelo'].lower(), dict(zip(hdr, r))['ID']): dict(zip(hdr, r)) for r in rows[1:]}

# detection for Fase 2 from analise/textos/relatorio_bugs.md (table "Detecção por bug"), transcribed verbatim
REL = {
 ('ChatGPT','U-CRASH'): ['Caracterizou','Capturou','Caracterizou'],
 ('Gemini','U-CRASH'):  ['Caracterizou','Viu s/ asserção','Caracterizou'],
 ('ChatGPT','U-SILENT'): ['Caracterizou']*3,  ('Gemini','U-SILENT'): ['Caracterizou']*3,
 ('ChatGPT','W-CRASH'): ['Não viu']*3,        ('Gemini','W-CRASH'):  ['Não viu']*3,
 ('ChatGPT','W-SILENT'): ['Caracterizou']*3,  ('Gemini','W-SILENT'): ['Canonizou']*3,
 ('ChatGPT','I-CRASH'): ['Viu s/ asserção','Não viu','Canonizou'],
 ('Gemini','I-CRASH'):  ['Não viu','Não viu','Canonizou'],
 ('ChatGPT','I-SILENT'): ['Caracterizou','Caracterizou','Canonizou'],
 ('Gemini','I-SILENT'):  ['Viu s/ asserção','Viu s/ asserção','Canonizou'],
}
REL_REEXEC = {('ChatGPT','FASE2-ICRASH-ZS_REEXEC'): 'Capturou', ('ChatGPT','FASE2-ICRASH-COT_REEXEC'): 'Capturou'}
BUGID = {'UCRASH':'U-CRASH','USILENT':'U-SILENT','WCRASH':'W-CRASH','WSILENT':'W-SILENT','ICRASH':'I-CRASH','ISILENT':'I-SILENT'}
NORM = {'Caracterizou':'Caracterizou c/ alerta','Viu s/ asserção':'Viu sem asserção'}
REL_PATH = 'analise/textos/relatorio_bugs.md'

def bug_of(rid):
    m = re.match(r'FASE2-(UCRASH|USILENT|WCRASH|WSILENT|ICRASH|ISILENT)-(ZS|FS|COT)(_REEXEC)?$', rid)
    if m: return BUGID[m.group(1)]
    m = re.match(r'FASE3-(L4|C3|P2)-', rid)
    return m.group(1) if m else ''

def detection(r):
    rid = r['id']
    if r['fase'] == 'Fase 2':
        m = re.match(r'FASE2-(UCRASH|USILENT|WCRASH|WSILENT|ICRASH|ISILENT)-(ZS|FS|COT)$', rid)
        if m and r['status'] == 'desenho':
            return REL[(r['modelo'], BUGID[m.group(1)])][{'ZS':0,'FS':1,'COT':2}[m.group(2)]], f'relatório ({REL_PATH}, tabela "Detecção por bug")'
        if (r['modelo'], rid) in REL_REEXEC and r['status'].startswith('reexecução'):
            return REL_REEXEC[(r['modelo'], rid)], f'relatório ({REL_PATH}, nota sobre REEXEC)'
        return '', ''
    if r['codigo_f3']:
        return r['codigo_f3'].replace('**', '').strip(), 'doc da rodada (campo "Código", codificação manual-first)'
    return '', ''

def lead_code(s):
    s = s.replace('**', '').strip()
    for c in ['Capturou', 'Caracterizou c/ alerta', 'Caracterizou', 'Viu s/ asserção', 'Viu sem asserção', 'Canonizou', 'Chegou sem afirmar', 'Não viu', 'Sem dado']:
        if s.startswith(c): return c
    return s

div = []      # (tipo, modelo, id, campo, valor no doc, valor na Pirâmide, doc)
for r in data['rounds']:
    r['deteccao'], r['origem_det'] = detection(r)
    r['bug'] = bug_of(r['id'])
    p = pir.get((r['modelo'].lower(), r['id']))
    r['na_piramide'] = 'sim' if (p and not r['status'].startswith('assistida')) else 'não'
    if p and not r['status'].startswith('assistida'):
        def D(tipo, campo, mine, theirs):
            div.append((tipo, r['modelo'], r['id'], campo, mine, theirs, r['doc']))
        pc = p['Compilou 1ª (1/0)']; mc = {'Sim': '1', 'Não': '0'}.get(r['compilou'], '')
        if mc != pc:
            D('convenção' if mc == '' else 'divergência', 'compilou na 1ª', r['compilou'] or '(sem campo)', pc)
        pg, pp, pf = p['Gerados'], p['Passando (final)'], p['Falhando (final)']
        ef = r['exec_final']
        if ef is None:
            if r['passf'] is None:
                D('convenção', 'testes executados/passando/falhando (final)', '(sem campo no doc)', f'{pg} / {pp} / {pf}')
            else:
                if str(r['passf']) != pp: D('divergência', 'passando (final)', r['passf'], pp)
                D('convenção', 'falhando (final)', '— (arquivo final não compila/não carrega)', pf)
        else:
            if str(ef) != pg:
                if str(r['gerados']) == pg:
                    D('convenção', 'executados (final) = passando + falhando', f'{ef} (campo "Testes gerados" do doc = {r["gerados"]}, igual à Pirâmide; o arquivo final tem outro número de testes)', pg)
                else:
                    D('divergência', 'executados (final) = passando + falhando', f'{ef} (campo "Testes gerados" do doc = {r["gerados"]})', pg)
            if str(r['passf']) != pp: D('divergência', 'passando (final)', r['passf'], pp)
            if str(r['failf']) != pf: D('divergência', 'falhando (final)', r['failf'], pf)
        if str(r['iteracoes']) != p['Iterações']:
            D('divergência', 'iterações de reparo', r['iteracoes'], p['Iterações'])
        md = NORM.get(lead_code(r['deteccao']), lead_code(r['deteccao'])) if r['deteccao'] else ''
        td = p['Detecção (uniforme)']
        if (md or td) and md != td:
            if r['status'].startswith('reexecução') and not td:
                tipo = 'convenção'; td = '(a Pirâmide não codifica detecção nas REEXEC)'
            elif (md == 'Chegou sem afirmar' and td == 'Não viu') or (md.startswith('Sem dado') and td.startswith('Sem dado')) or ('sem dado por limitação do serviço' in r['deteccao'].lower() and td.startswith('Sem dado')):
                tipo = 'mapeamento documentado'
            else:
                tipo = 'divergência'
            D(tipo, 'codificação de detecção', r['deteccao'], td)

# ---------------- gaps ----------------
lac = []
def gap(txt): lac.append(txt)
R = data['rounds']
def ids(sel): return ', '.join(sorted(sel))
n = [r for r in R if r['status'] == 'desenho' and r['fase'] == 'Fase 2' and r['modelo'] == 'ChatGPT' and not r['sessao']]
gap(f'Condição de sessão: {len(n)} rodadas ChatGPT da Fase 2 (as 49 originais de fase2/rodadas/) não têm o campo "Sessão" no doc; a condição (deslogada) está só em fase2/rodadas/README.md e no CLAUDE.md. Coluna deixada em branco. Idem para as 15 assistidas e os 2 extras.')
n = [r for r in R if r['status'] == 'desenho' and r['fase'] == 'Fase 3' and not r['versao_modelo']]
gap(f'Versão do modelo: as {len(n)} rodadas da Fase 3 não têm o campo "Versão do modelo"; têm só os dois campos ✦ (modelo declarado / verificação externa), transcritos nas colunas próprias. Coluna "versão do modelo" em branco nessas linhas.')
n = [r for r in R if r['status'] == 'desenho' and r['fase'] == 'Fase 2' and r['modelo'] == 'ChatGPT' and not r['declarado']]
gap(f'Modelo declarado / verificação externa: as {len(n)} rodadas ChatGPT originais da Fase 2 não têm os campos ✦ (introduzidos só na réplica Gemini e na reexecução). O campo "Versão do modelo" delas registra "Não verificável" ou "GPT-5.6 Luna (autodeclarado)".')
gap('Hash do prompt: nenhum doc da Fase 2 (ChatGPT, Gemini ou reexecução) registra o SHA-256 do prompt; os da reexecução dizem "hash conferido no campo" sem o valor. A coluna "hash do prompt" é a recalculada sobre o conteúdo commitado (LF). Só os 36 docs da Fase 3 registram o hash, e os 36 batem com o recalculado.')
n = [r for r in R if r['iteracoes_src'] == 'derivado' and r['status'] != 'abortada']
gap(f'Iterações de reparo: {len(n)} docs não têm o campo "Iterações de reparo"; o valor foi derivado das seções/linhas "Iteração N" do doc (coluna "origem: iterações" = derivado). Conferido contra a Pirâmide: ver divergências.')
n = [r for r in R if r['status'] == 'desenho' and r['gerados'] is None]
n2 = [r for r in n if r['fase'] == 'Fase 2']
gap(f'Testes gerados: {len(n2)} docs ChatGPT da Fase 2 (widget/integração) não têm o campo "Testes gerados" nem "Compilou?"; registram só "Resultado final X/Y" e "Iterações de reparo". Executados (final) = Y; passando = X; compilou na 1ª derivado do cabeçalho da iteração 1 (coluna "origem: compilou"). IDs: ' + ids(r['id'] for r in n2) + '. Mais 2 da Fase 3 sem geração de código (FASE3-C3-COT e FASE3-P2-ZS, ChatGPT, "sem dado por limitação do serviço"): sem campos de resultado.')
n = [r for r in R if r['status'] == 'desenho' and not r['compilou']]
gap(f'Compilou na 1ª geração: em branco em {len(n)} rodadas do desenho (sem campo e sem derivação segura): ' + ids(r['id'] + ' [' + r['modelo'] + ']' for r in n))
gap('Codificação de detecção: nos 36 docs de bug da Fase 2 (ChatGPT e Gemini) o doc traz só "Bug plantado capturado por asserção?" (Sim/Não), não a codificação uniforme; a coluna foi preenchida do relatório (analise/textos/relatorio_bugs.md) e a origem está marcada. Nas rodadas limpas a coluna não se aplica (em branco). Nas 15 assistidas e nas 2 extras, em branco (o relatório cobre só as 60 do desenho).')
gap('Codificação de detecção das 8 reexecuções (_REEXEC): o relatório só afirma "ChatGPT capturou o I-CRASH em ZS_REEXEC e COT_REEXEC; Gemini não"; preenchido "Capturou" nessas 2 e em branco nas outras 6.')
gap('Prompts: o "68/68" do README da réplica Gemini conta fase2/prompts_prontos/_fora-de-escopo/README.md, que não é prompt; a aba Prompts tem 67 linhas da Fase 2 (18 bug + FASE2--REEXEC + 42 limpos + 6 fora de escopo) + 9 da Fase 3 = 76.')
gap('Abortadas: as 6 tentativas abortadas (5 da Fase 3, 1 da réplica Gemini) estão listadas com os campos que seus docs têm; não entram em nenhuma contagem.')
n = [r for r in R if r['status'] == 'reexecução I-CRASH' and r['modelo'] == 'Gemini' and r['id'] == 'FASE2-ICRASH-ZS_REEXEC']
gap('FASE2-ICRASH-ZS_REEXEC (Gemini): não houve código gerado (2 recusas); gerados 0, sem compilação, sem execução; Pirâmide registra "não executada".')
gap('Status "reexecução W-SILENT" foi usado para FASE2-WSILENT-FS_REEXEC (ChatGPT e Gemini), que não é I-CRASH; o vocabulário pedido ("reexecução I-CRASH") não cobre esse caso.')

# ---------------- workbook ----------------
wb = Workbook()
bold = Font(bold=True); wrap = Alignment(wrap_text=True, vertical='top')
fill = PatternFill('solid', fgColor='DDDDDD')

def sheet(ws, header, rows, widths=None):
    ws.append(header)
    for c in ws[1]: c.font = bold; c.fill = fill
    for r in rows: ws.append(r)
    ws.freeze_panes = 'A2'
    for i, h in enumerate(header, 1):
        ws.column_dimensions[get_column_letter(i)].width = (widths or {}).get(h, max(12, min(60, len(h) + 4)))

# Leia-me
ws = wb.active; ws.title = 'Leia-me'
lines = [
 ['Índice do pacote de replicação — TCC Sintonize (Fases 2 e 3)'],
 ['Gerado em 2026-11-25 a partir dos arquivos do repositório, branch fase3-e2e, depois da correção e do recálculo de Piramide_Unificada_ChatGPT_x_Gemini.xlsx (Rodadas!I155, 5 → 4). Nenhum artefato executado foi alterado.'],
 [''],
 ['Aba "Prompts" (76 linhas)'],
 ['uso: desenho (18 prompts de bug + 42 alvos limpos da Fase 2 + 9 da Fase 3) / reexecução (FASE2--REEXEC.md, 4 prompts corrigidos num só arquivo) / fora de escopo (6 em fase2/prompts_prontos/_fora-de-escopo/).'],
 ['hash SHA-256: calculado sobre o conteúdo COMMITADO do arquivo (git show HEAD:<caminho>), que tem fim de linha LF. Motivo: o repositório usa core.autocrlf=true, então o working tree no Windows tem CRLF e o sha256sum direto do checkout muda conforme a máquina; o blob commitado é o mesmo para qualquer clone. Os 9 hashes da Fase 3 registrados em fase3-e2e/prompts_prontos/_sha256.txt e nos 36 docs de rodada foram calculados sobre arquivos LF e coincidem com esta coluna.'],
 ['caracteres (arquivo inteiro): len() do conteúdo commitado decodificado em UTF-8, incluindo o cabeçalho do operador e a seção "Prompt de reparo".'],
 ['caracteres (corpo colado): só o texto entre o "---" que segue o título "## Prompt (selecionar tudo abaixo desta linha...)" e o "---" seguinte, sem espaços/quebras nas pontas — é o que foi colado no modelo. Reproduz os números citados nos docs (ex.: 7.646 em FASE2-WCRASH-COT; 33.976 em FASE3-E2E-ZS-01). Em FASE2--REEXEC.md é a soma dos 4 corpos; os 4 valores estão na coluna "observação".'],
 ['Os arquivos de fase2-gemini/prompts_prontos/ e fase2-chatgpt-reexec/prompts_prontos/ são cópias byte a byte dos de fase2/prompts_prontos/ (diff -r sem diferenças; blobs idênticos) e não ganharam linhas próprias.'],
 [''],
 ['Aba "Rodadas" (187 linhas)'],
 ['status: desenho (156 = 60 ChatGPT Fase 2 [49 originais em fase2/rodadas/ + 11 reexecutadas em fase2-chatgpt-reexec/rodadas/] + 60 Gemini Fase 2 + 36 Fase 3) / reexecução I-CRASH (6: ICRASH-{ZS,FS,COT}_REEXEC × 2 modelos) / reexecução W-SILENT (2: WSILENT-FS_REEXEC × 2 modelos) / assistida (referência) (15 rodadas ChatGPT com reparo enriquecido em fase2/_execucao-assistida/, fora das contagens) / abortada (6) / extra (2 docs de achado em fase2/rodadas/unit/).'],
 ['Autoridade para "o que é do desenho": aba Rodadas de analise/planilhas/Piramide_Unificada_ChatGPT_x_Gemini.xlsx (164 linhas = 156 + 8 REEXEC). Coluna "na Pirâmide" = sim para essas 164.'],
 ['Preenchimento: só a partir dos arquivos do repositório. Campo inexistente no doc = célula em branco. As colunas "origem: ..." dizem se o valor veio de um campo do doc ("campo") ou foi derivado de outra parte do doc ("derivado ...").'],
 ['testes gerados (doc): valor literal do campo "Testes gerados" (número de testes na geração inicial). executados (final) = passando + falhando no estado final, que é a definição de "Gerados" da Pirâmide (arquivo final). Quando o arquivo final não compila, o doc registra "—" em falhando e a coluna fica em branco; a Pirâmide conta N falhando.'],
 ['codificação de detecção: Fase 3 = campo "Código" do doc (codificação manual-first). Fase 2 = tabela "Detecção por bug" de analise/textos/relatorio_bugs.md (os docs da Fase 2 não têm a codificação uniforme). A Pirâmide grafa "Caracterizou c/ alerta" e "Viu sem asserção" para o que o relatório grafa "Caracterizou" e "Viu s/ asserção"; mantida a grafia da fonte.'],
 ['modelo declarado (✦) / verificação externa (✦): texto literal dos campos ✦ do doc, quando existem (réplica Gemini, reexecução ChatGPT e Fase 3).'],
 [''],
 ['Lacunas'],
] + [[f'- {g}'] for g in lac] + [[''], ['Divergências doc × Pirâmide (conferidas linha a linha; nenhum doc foi corrigido)']]
for d in sorted(div, key=lambda x: (x[0] != 'divergência', x[1], x[2])):
    lines.append([f'- [{d[0]}] {d[1]} {d[2]} — {d[3]}: doc = {d[4]} | Pirâmide = {d[5]} ({d[6]})'])
lines += [[''], ['Conferência das divergências reais contra a saída arquivada do flutter test (sem alterar nenhum doc):'],
 ['- FASE2-UNIT-COT-06_validateEmailLogin (ChatGPT): fase2/resultados/unit/cot/..._iter1_final.txt termina em "+18 -1" (19 testes) e test/fase2/unit/validate_email_login_cot_test.dart tem 19 test(); o doc registra 18 gerados e 17/1. A Pirâmide (19; 18/1) está de acordo com a saída.'],
 ['- FASE2-UNIT-ZS-10_validateDate (ChatGPT): fase2/resultados/unit/zero-shot/..._iter0_final.txt termina em "+33: All tests passed!" e o arquivo de teste tem 33 test(); o doc registra 34/34. A Pirâmide (33/33) está de acordo com a saída.'],
 ['- FASE3-E2E-ZS-02_cadastroFlow (Gemini): a Pirâmide registrava 5 gerados (4 passando, 0 falhando), o que não fechava com a saída (iteração 0 com 4 testWidgets() em ..._transcricao/iter0_resposta.md; ..._iter2_final.txt termina em "+4: All tests passed!"; o doc registra 4 e 4/0). Corrigido para 4 na célula Rodadas!I155 da Pirâmide (ver analise/textos/ERRATA.md); por isso não aparece mais na lista acima.'],
 ['- Tipos: "divergência" = valores diferentes para o mesmo fato; "convenção" = o doc não tem o campo ou usa outra regra de contagem (ex.: arquivo final que não compila → falhando "—" no doc, N na Pirâmide; "Testes gerados" = geração inicial no doc); "mapeamento documentado" = vocabulário diferente com equivalência registrada na Pirâmide ou no próprio doc.']]
for l in lines: ws.append(l)
ws.column_dimensions['A'].width = 180
for row in ws.iter_rows():
    for c in row: c.alignment = wrap

# Prompts
ws = wb.create_sheet('Prompts')
sheet(ws, ['id', 'fase', 'nível', 'alvo', 'estratégia', 'uso', 'caminho do arquivo', 'hash SHA-256 (conteúdo commitado, LF)', 'caracteres (arquivo inteiro)', 'caracteres (corpo colado)', 'observação'],
      [[p['id'], p['fase'], p['nivel'], p['alvo'], p['estrategia'], p['uso'], p['caminho'], p['sha256'], p['chars_arquivo'], p['chars_corpo'], p['obs']] for p in data['prompts']],
      {'id': 36, 'alvo': 60, 'caminho do arquivo': 70, 'hash SHA-256 (conteúdo commitado, LF)': 68, 'observação': 60})

# Rodadas
ws = wb.create_sheet('Rodadas')
H = ['id da rodada', 'fase', 'modelo', 'status', 'bug', 'versão do modelo', 'modelo declarado (✦)', 'verificação externa (✦)', 'modelo servido (fonte externa)', 'data', 'condição de sessão',
     'id do prompt', 'hash do prompt (SHA-256, LF)', 'hash registrado no doc', 'versão do prompt (doc)',
     'iterações de reparo', 'origem: iterações', 'compilou na 1ª geração', 'origem: compilou', 'compilou (texto do doc)',
     'testes gerados (doc)', 'passando (1ª execução)', 'falhando (1ª execução)', 'passando (final)', 'falhando (final)', 'executados (final)', 'passando/executados (final)', 'origem: resultado',
     'codificação de detecção', 'origem da codificação', 'bug capturado por asserção? (doc)', 'autoclassificação do modelo (doc)', 'classificação humana (doc)',
     'na Pirâmide', 'caminho do documento da rodada']
def pe(r):
    if r['passf'] is None: return ''
    return f"{r['passf']}/{r['exec_final']}" if r['exec_final'] is not None else f"{r['passf']}/—"
rows_r = [[r['id'], r['fase'], r['modelo'], r['status'], r['bug'], r['versao_modelo'], r['declarado'], r['verif_externa'], r['fonte_externa'], r['data'], r['sessao'],
           r['prompt_id'], r['prompt_hash'], r['hash_doc'], r['versao_prompt'],
           r['iteracoes'] if r['status'] != 'abortada' or r['iteracoes_src'] == 'campo' else '', r['iteracoes_src'], r['compilou'], r['compilou_src'], r['compilou_raw'],
           r['gerados'] if r['gerados'] is not None else '', r['pass1'] if r['pass1'] is not None else '', r['fail1'] if r['fail1'] is not None else '',
           r['passf'] if r['passf'] is not None else '', r['failf'] if r['failf'] is not None else '', r['exec_final'] if r['exec_final'] is not None else '', pe(r), r['res_src'],
           r['deteccao'], r['origem_det'], r['capt_assercao'], r['autoclass'], r['humana'], r['na_piramide'], r['doc']] for r in R]
sheet(ws, H, rows_r, {'id da rodada': 34, 'versão do modelo': 40, 'modelo declarado (✦)': 50, 'verificação externa (✦)': 50, 'modelo servido (fonte externa)': 40, 'condição de sessão': 40,
                      'id do prompt': 34, 'hash do prompt (SHA-256, LF)': 68, 'hash registrado no doc': 68, 'versão do prompt (doc)': 40, 'compilou (texto do doc)': 40,
                      'codificação de detecção': 30, 'origem da codificação': 40, 'autoclassificação do modelo (doc)': 50, 'classificação humana (doc)': 50, 'caminho do documento da rodada': 80})
for row in ws.iter_rows(min_row=2):
    for c in row: c.alignment = Alignment(vertical='top')
os.makedirs(os.path.dirname(OUTX), exist_ok=True)
wb.save(OUTX)

print('Prompts:', len(data['prompts']), dict(Counter(p['uso'] for p in data['prompts'])))
print('Rodadas:', len(R), dict(Counter(r['status'] for r in R)))
print('na Pirâmide:', sum(1 for r in R if r['na_piramide'] == 'sim'))
print('--- DIVERGÊNCIAS', Counter(d[0] for d in div))
for d in sorted(div, key=lambda x: (x[0] != 'divergência', x[1], x[2])): print(' | '.join(str(x) for x in d[:6]))
print('--- LACUNAS'); [print('-', g) for g in lac]
