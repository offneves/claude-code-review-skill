#!/usr/bin/env bash
# Lista os arquivos do diff <base>...HEAD que casam com references/caminhos-sensiveis.txt.
# Uso: caminhos-sensiveis.sh [base]   (padrão: origin/main)
# Saída: "categoria<TAB>arquivo", uma linha por arquivo. Sem saída = nenhum caminho sensível.
# Sai com 0 em ambos os casos; código 2 indica erro de uso ou de git.

set -uo pipefail

BASE="${1:-origin/main}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS="$DIR/../references/caminhos-sensiveis.txt"

git rev-parse --verify --quiet "$BASE" >/dev/null || { echo "Base inválida: $BASE" >&2; exit 2; }
[ -f "$PATTERNS" ] || { echo "Arquivo de padrões não encontrado: $PATTERNS" >&2; exit 2; }

mapfile -t FILES < <(git diff --name-only "$BASE"...HEAD)

while IFS=$'\t' read -r categoria regex; do
  case "$categoria" in ''|\#*) continue ;; esac
  [ -n "${regex:-}" ] || continue
  for f in "${FILES[@]}"; do
    if printf '%s\n' "$f" | grep -Eq -- "$regex"; then
      printf '%s\t%s\n' "$categoria" "$f"
    fi
  done
done < "$PATTERNS" | sort -u
