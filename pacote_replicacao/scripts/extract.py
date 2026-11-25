# -*- coding: utf-8 -*-
import os, re, sys, json, hashlib, subprocess, glob
ROOT = sys.argv[1]; OUT = sys.argv[2]
os.chdir(ROOT)

def blob(p):
    return subprocess.run(['git', 'show', 'HEAD:' + p], capture_output=True, check=True).stdout.decode('utf-8')

# ---------------- prompts ----------------
def bodies(t):
    lines = t.split('\n'); out = []; i = 0
    while i < len(lines):
        if lines[i].startswith('## Prompt (selecionar'):
            j = i + 1
            while lines[j].strip() != '---': j += 1
            k = j + 1
            while lines[k].strip() != '---': k += 1
            out.append('\n'.join(lines[j + 1:k]).strip()); i = k
        i += 1
    return out

NIVEL = {'UNIT': 'Unitário', 'WIDGET': 'Widget', 'INT': 'Integração', 'UCRASH': 'Unitário', 'USILENT': 'Unitário',
         'WCRASH': 'Widget', 'WSILENT': 'Widget', 'ICRASH': 'Integração', 'ISILENT': 'Integração', 'E2E': 'E2E'}
ESTR = {'ZS': 'Zero-shot', 'FS': 'Few-shot', 'COT': 'Chain-of-Thought'}
prompts = []
files = sorted(glob.glob('fase2/prompts_prontos/**/*.md', recursive=True)) + sorted(glob.glob('fase3-e2e/prompts_prontos/*/*.md'))
for p in files:
    p = p.replace('\\', '/')
    if p.endswith('README.md'): continue
    t = blob(p); stem = os.path.basename(p)[:-3]
    h = hashlib.sha256(t.encode('utf-8')).hexdigest()
    bs = bodies(t)
    m = re.search(r'^\*\*Alvo:\*\*\s*(.+?)\s*$', t, re.M)
    alvo = m.group(1).strip() if m else ''
    fase = 'Fase 3' if p.startswith('fase3') else 'Fase 2'
    if stem == 'FASE2--REEXEC':
        nivel = 'Widget / Integração'; estr = 'FS / ZS / FS / COT'; uso = 'reexecução'
        alvo = 'FASE2-WSILENT-FS, FASE2-ICRASH-ZS, FASE2-ICRASH-FS, FASE2-ICRASH-COT (4 prompts corrigidos)'
        obs = 'arquivo com 4 prompts; corpos: ' + ', '.join(str(len(b)) for b in bs) + ' caracteres (WSILENT-FS, ICRASH-ZS, ICRASH-FS, ICRASH-COT); a coluna "caracteres do corpo" traz a soma'
    else:
        parts = stem.split('-')
        nivel = NIVEL[parts[1]]; estr = ESTR[parts[2]]
        uso = 'fora de escopo' if '_fora-de-escopo' in p else 'desenho'
        obs = '' if len(bs) == 1 else f'{len(bs)} corpos encontrados'
    prompts.append(dict(id=stem, fase=fase, nivel=nivel, alvo=alvo, estrategia=estr, uso=uso, caminho=p, sha256=h,
                        chars_arquivo=len(t), chars_corpo=sum(len(b) for b in bs), obs=obs))

# ---------------- rounds ----------------
FIELD = re.compile(r'^\| \*\*(.+?)\*\* \| (.*?) \|\s*$')
def parse_fields(t):
    d = {}; order = []
    for line in t.split('\n'):
        m = FIELD.match(line)
        if m:
            k, v = m.group(1).strip(), m.group(2).strip()
            order.append((k, v))
            d.setdefault(k, v)
    return d, order

def clean(s): return (s or '').replace('**', '').strip()

def first_int(s):
    m = re.search(r'(\d+)', clean(s))
    return int(m.group(1)) if m else None

def pass_fail(v):
    """Return (pass, fail) from a free-text cell, or (None, None)."""
    v = clean(v)
    if not v or v.startswith('—') or v.startswith('-') or v.lower().startswith('n/a'): return None, None
    m = re.search(r'(\d+)\s+pass(?:aram|ou)\s*/\s*(\d+)\s+falh', v)
    if m: return int(m.group(1)), int(m.group(2))
    m = re.search(r'(\d+)\s+pass(?:aram|ou)\s*/\s*(\d+)\s+total', v)
    if m: return int(m.group(1)), int(m.group(2)) - int(m.group(1))
    m = re.match(r'(\d+)\s*/\s*(\d+)', v)
    if m: return int(m.group(1)), int(m.group(2)) - int(m.group(1))
    m = re.match(r'(\d+)', v)
    if m: return int(m.group(1)), None
    return None, None

def norm_compilou(s):
    x = clean(s).lower()
    if not x: return ''
    if 'não na geração' in x or 'nao na geração' in x or x.startswith('não em nenhuma'): return 'Não'
    if x.startswith('sim'): return 'Sim'
    if x.startswith('não') or x.startswith('nao'): return 'Não'
    return ''

def prompt_for(rid):
    base = rid.split(' ')[0]
    if base.endswith('_REEXEC'):
        return 'FASE2--REEXEC'
    m = re.match(r'FASE3-(L4|C3|P2)-(ZS|FS|COT)$', base)
    if m:
        n = {'L4': '01_loginFlow', 'C3': '02_cadastroFlow', 'P2': '03_playlistFlow'}[m.group(1)]
        return f'FASE3-E2E-{m.group(2)}-{n}'
    return base

pmap = {p['id']: p for p in prompts}

rounds = []
def add(path, fase, modelo, status):
    t = open(path, encoding='utf-8').read()
    d, order = parse_fields(t)
    rid_raw = d.get('ID da Rodada', '')
    rid = os.path.basename(path)[:-3]
    declared = d.get('✦ Modelo declarado pelo LLM') or d.get('✦ Modelo declarado pelo ChatGPT') or d.get('✦ Modelo declarado pelo Gemini') or ''

    # ---- iterations
    it_field = d.get('Iterações de reparo')
    it = first_int(it_field) if it_field else None
    it_src = 'campo' if it is not None else ''
    if it is None:
        n = 0
        # (a) '### Iteração N' headings whose section has a real 'Motivo da falha'
        for m in re.finditer(r'^### Iteração (\d)(.*)$', t, flags=re.M):
            num = int(m.group(1)); rest = m.group(2).lower()
            sec = t[m.end():].split('\n## ')[0]
            mm = re.search(r'\*\*Motivo da falha:\*\*\s*(.*)', sec)
            if mm:
                v = mm.group(1).strip().lower()
                if v and not v.startswith('[') and 'não necessária' not in v and 'não houve' not in v and v not in ('—', '-', 'n/a'):
                    n = max(n, num)
            elif '(repair' in rest:
                n = max(n, num)
        # (b) table rows '| N | ...' inside the repair loop section
        mm = re.search(r'^## Iterative Repair Loop(.*?)(?=^## )', t, flags=re.M | re.S)
        if mm:
            for r in re.finditer(r'^\| (\d) \|', mm.group(1), flags=re.M):
                n = max(n, int(r.group(1)))
        # (c) '| **Iteração N ...** |' rows
        for k, v in order:
            r = re.match(r'Iteração (\d)', k)
            if r and int(r.group(1)) > 0: n = max(n, int(r.group(1)))
        it = n; it_src = 'derivado'

    # ---- compiled on first generation
    comp_raw = d.get('Compilou?') or d.get('Compilou na 1ª execução?') or d.get('Compilou? (1ª tentativa)') or ''
    comp = norm_compilou(comp_raw); comp_src = 'campo' if comp else ''
    if not comp and not comp_raw:
        g0 = first_int(d.get('Testes gerados') or '')
        if it == 0 and (d.get('Resultado final') or (g0 is not None and g0 > 0)):
            comp = 'Sim'; comp_src = 'derivado (0 iterações: a suíte executou)'
        else:
            m = re.search(r'^### Iteração 1\b(.*)$', t, flags=re.M)
            h = m.group(1).lower() if m else ''
            if m and ('não compila' in h or 'compilação' in h or 'compilar' in h):
                comp = 'Não'; comp_src = 'derivado (cabeçalho da iteração 1: erro de compilação)'
            elif m and 'falha' in h:
                comp = 'Sim'; comp_src = 'derivado (cabeçalho da iteração 1: falhas de teste)'

    # ---- generated / pass / fail
    gerados = first_int(d.get('Testes gerados') or d.get('Testes gerados (versão inicial)') or '')
    pass_fields = [(k, v) for k, v in order if k.startswith('Testes passaram')]
    fail_fields = [(k, v) for k, v in order if k.startswith('Testes falharam')]
    p1 = f1 = pf = ff = None
    res_src = ''
    if pass_fields:
        p1, x = pass_fail(pass_fields[0][1])
        if f1 is None: f1 = x
        if fail_fields:
            y, _ = pass_fail(fail_fields[0][1])
            if y is not None: f1 = y
        pf, x = pass_fail(pass_fields[-1][1])
        if fail_fields:
            y, _ = pass_fail(fail_fields[-1][1])
            ff = y if y is not None else x
        else:
            ff = x
        def split_if(v):
            a, _, b = clean(v).partition('/')
            ma = re.match(r'\s*(\d+)', a); mb = re.match(r'\s*(\d+)', b)
            return (int(ma.group(1)) if ma else None), (int(mb.group(1)) if mb else None)
        for k, v in pass_fields:
            if 'iteração 0 / final' in k: p1, pf = split_if(v)
        for k, v in fail_fields:
            if 'iteração 0 / final' in k: f1, ff = split_if(v)
        if pf is None and ff is None:  # final '—' → equal to first run
            pf, ff = p1, f1
        res_src = 'campos "Testes passaram/falharam"'
    if pf is None and d.get('Resultado final'):
        pf, ff = pass_fail(d['Resultado final']); res_src = 'campo "Resultado final"'
    if pf is None:
        its = [(k, v) for k, v in order if re.match(r'Iteração \d', k)]
        if its:
            pf, ff = pass_fail(its[-1][1]); res_src = f'linha "{its[-1][0]}"'
    exec_final = (pf + ff) if (pf is not None and ff is not None) else None

    pid = prompt_for(rid)
    pr = pmap.get(pid)
    hash_doc = ''
    ap = d.get('Arquivo do prompt', '')
    m = re.search(r'([0-9a-f]{64})', ap)
    if m: hash_doc = m.group(1)
    rounds.append(dict(
        id=rid, id_doc=rid_raw, fase=fase, modelo=modelo, status=status,
        versao_modelo=d.get('Versão do modelo', ''), declarado=declared,
        verif_externa=d.get('✦ Verificação externa da versão', ''), fonte_externa=d.get('Modelo servido (fonte externa, URL + data)', ''),
        data=d.get('Data de acesso', ''), sessao=d.get('Sessão', ''), conversa=d.get('Conversa nova?', ''),
        prompt_id=pid, prompt_path=pr['caminho'] if pr else '', prompt_hash=pr['sha256'] if pr else '', hash_doc=hash_doc,
        versao_prompt=d.get('Versão do prompt', ''),
        iteracoes=it, iteracoes_src=it_src, compilou=comp, compilou_src=comp_src, compilou_raw=comp_raw,
        gerados=gerados, pass1=p1, fail1=f1, passf=pf, failf=ff, exec_final=exec_final, res_src=res_src,
        capt_assercao=d.get('Bug plantado capturado por asserção?', ''), codigo_f3=d.get('Código', ''),
        autoclass=d.get('★ Autoclassificação do modelo', ''), humana=d.get('★ Classificação humana (auditoria)', ''),
        doc=path.replace('\\', '/')))

EXTRAS = {'FASE2-VALIDATESENHA-ZS-ACHADO-EXTRA-BUG-ATIVO', 'FASE2-VALIDATESENHA-ZS-FORA-DE-ESCOPO'}
def stat_reexec(stem):
    if stem.startswith('FASE2-ICRASH') and stem.endswith('_REEXEC'): return 'reexecução I-CRASH'
    if stem.endswith('_REEXEC'): return 'reexecução W-SILENT'
    return 'desenho'
for p in sorted(glob.glob('fase2/rodadas/*/*.md')):
    s = os.path.basename(p)[:-3]
    if s == 'README': continue
    add(p, 'Fase 2', 'ChatGPT', 'extra' if s in EXTRAS else 'desenho')
for p in sorted(glob.glob('fase2-chatgpt-reexec/rodadas/*/*.md')):
    add(p, 'Fase 2', 'ChatGPT', stat_reexec(os.path.basename(p)[:-3]))
for p in sorted(glob.glob('fase2/_execucao-assistida/rodadas/*/*.md')):
    add(p, 'Fase 2', 'ChatGPT', 'assistida (referência)')
for p in sorted(glob.glob('fase2-gemini/rodadas/*/*.md')):
    add(p, 'Fase 2', 'Gemini', stat_reexec(os.path.basename(p)[:-3]))
for p in sorted(glob.glob('fase3-e2e/rodadas/chatgpt/*.md')): add(p, 'Fase 3', 'ChatGPT', 'desenho')
for p in sorted(glob.glob('fase3-e2e/rodadas/gemini/*.md')): add(p, 'Fase 3', 'Gemini', 'desenho')
for p in sorted(glob.glob('fase3-e2e/rodadas/chatgpt/_abortadas/*.md')): add(p, 'Fase 3', 'ChatGPT', 'abortada')
for p in sorted(glob.glob('fase3-e2e/rodadas/gemini/_abortadas/*.md')): add(p, 'Fase 3', 'Gemini', 'abortada')
for p in sorted(glob.glob('fase2-gemini/rodadas/unit/_abortadas/*/*/*.md')): add(p, 'Fase 2', 'Gemini', 'abortada')

json.dump(dict(prompts=prompts, rounds=rounds), open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
from collections import Counter
print('prompts', len(prompts), Counter(p['uso'] for p in prompts))
print('rounds', len(rounds), Counter(r['status'] for r in rounds))
print('iteracoes derivadas:', sum(1 for r in rounds if r['iteracoes_src'] == 'derivado'))
