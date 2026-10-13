#!/bin/bash
cd "/c/Users/marcos.neto/desktop/Repositórios/sintonize-tcc"
OUT="$TMP/cov/fase2"; touch "$OUT/log.txt"
start=$(date +%s)
for f in $(find test/fase2 test/fase2-gemini -name "*_test.dart" | grep -v -E "ucrash|usilent|wcrash|validate_senha_zs|format_name" | sort); do
  id=$(echo "$f" | sed 's#test/##; s#/#__#g; s#_test.dart##')
  grep -q "^$f " "$OUT/log.txt" && continue
  rm -f coverage/lcov.info
  t0=$(date +%s)
  timeout -k 10 240 flutter test --coverage "$f" > "$OUT/$id.out" 2>&1
  rc=$?
  [ -f coverage/lcov.info ] && cp coverage/lcov.info "$OUT/$id.lcov"
  echo "$f rc=$rc lcov=$([ -f coverage/lcov.info ] && echo sim || echo nao) $(( $(date +%s) - t0 ))s $(grep -oE '^[0-9:]+ \+[0-9]+( -[0-9]+)?: (All tests passed|Some tests failed)' "$OUT/$id.out" | tail -1)" >> "$OUT/log.txt"
done
echo "TOTAL $(( $(date +%s) - start ))s" >> "$OUT/log.txt"
