# -*- coding: utf-8 -*-
"""Exporta a aba Rodadas de analise/planilhas/Piramide_Unificada_ChatGPT_x_Gemini.xlsx
para <saida>/piramide_rodadas.csv (valores, não fórmulas). Uso:
    python -X utf8 -I export_piramide.py <raiz do repositório> <pasta de saída>
"""
import sys, os, csv, openpyxl
root, out = sys.argv[1], sys.argv[2]
wb = openpyxl.load_workbook(os.path.join(root, 'analise/planilhas/Piramide_Unificada_ChatGPT_x_Gemini.xlsx'), data_only=True)
rows = list(wb['Rodadas'].iter_rows(values_only=True))
os.makedirs(out, exist_ok=True)
with open(os.path.join(out, 'piramide_rodadas.csv'), 'w', newline='', encoding='utf-8') as f:
    csv.writer(f).writerows(rows)
print(len(rows) - 1, 'linhas exportadas')
