# Templates

## `target/feature-code-review/achados.md` (trabalho, não vai para o MR)

```markdown
<!-- feature-code-review: alvo=<main|development|…> base=origin/<alvo> base_sha=<sha da base> head=<sha do HEAD analisado> rodada=<N> branch=<branch> -->
# Achados · <branch>

Spec: <caminho | "colada pelo dev" | "não avaliada (sem spec)">
verify-slice: <OK | FALHAS>

## Padrões
| ID | Sev. | Onde | Achado | Regra | Status | Rodada |
|---|---|---|---|---|---|---|
| P-01 | Crítico | `Arquivo.java:40` | <achado> | <fonte: arquivo § regra> | aberto · corrigido · intencional: <motivo> · falso positivo: <motivo> | 1 |

## Spec
| ID | Sev. | Onde | Achado | Spec | Status | Rodada |
|---|---|---|---|---|---|---|
| S-01 | Importante | `Tela.tsx:12` | <achado> | CA-03: "<trecho citado>" | aberto | 1 |

## Pré-existentes
- `Arquivo.java:88`: <achado> (card sugerido)

## Nits
- P-07 `Arquivo.java:15`: <achado>

## Resumo
Padrões: <n> achados, pior: <achado>. Spec: <n> achados, pior: <achado>.
<!-- Pior achado de cada eixo, sem escolher um vencedor entre os eixos (regra do Matt). -->

## Histórico de Críticos
<!-- Todo Crítico de qualquer rodada fica listado aqui, mesmo corrigido. É o que decide o revisor humano. -->
- P-01 (rodada 1) · corrigido em <sha>
```

## `target/feature-code-review/relatorio.md` (vai na descrição do MR)

Só o que o revisor precisa. Sem prosa.

### Com revisor

```markdown
## /feature-code-review · <branch> · <sha curto> → <branch-alvo> (base <sha curto>)
**Revisor humano: SIM:** <motivos separados por " · ", ex.: teve Crítico · toca databaseVersion/>

| Sev. | Eixo | Onde | Achado | Status |
|---|---|---|---|---|
| Crítico | Padrões | `Version451.java:40` | migração apagava alvarás vencidos | corrigido · RV-012 |
| Importante | Spec | `AlvaraService.java:88` | CA-04 sem timeout na chamada ao SEI | intencional: retry no job |

**Caminhos sensíveis:** `src/main/java/.../databaseVersion/versions/Version451.java`
**REVIEW.md:** + RV-012 (aprovar no diff)
**Testes:** verify-slice OK · **Spec:** GDF-123, eixo avaliado
Nits: 3 · Pré-existentes: 1
```

A tabela traz **só** os Críticos (de qualquer rodada) e os Importantes que ficaram como intencional ou falso positivo. Importante corrigido não aparece.

### Sem revisor

```markdown
## /feature-code-review · <branch> · <sha curto> → <branch-alvo> (base <sha curto>)
**Revisor humano: NÃO:** sem Crítico, sem justificativa pendente, sem caminho sensível
**Testes:** verify-slice OK · **Spec:** GDF-123, eixo avaliado · Nits: 2
```
