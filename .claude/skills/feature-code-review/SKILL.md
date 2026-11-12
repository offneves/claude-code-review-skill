---
name: feature-code-review
description: Revisão de código local, feita antes de abrir o MR. Roda dois eixos independentes (Padrões e Spec), cada um num agente com contexto limpo, no modelo da skill code-review de Matt Pocock. Gera o relatório curto para a descrição do MR, decide se o MR precisa de revisor humano e alimenta o REVIEW.md. Use quando o usuário pedir /feature-code-review, /feature-code-review --delta ou "revisar antes do MR".
argument-hint: "[--delta] [--base <ref>] [--spec <caminho>] [--config <alvara.txt>] [--tests <Classe,...>]"
---

# /feature-code-review

Revisão local antes do MR. A IA faz a leitura ampla aqui. O revisor humano só entra no MR quando há risco, e mesmo assim olha só a tabela do relatório.

O fluxo completo está em `fluxo-code-review-final.png`, no pacote desta skill.

## Arquivos

| Arquivo | Papel |
|---|---|
| `target/feature-code-review/achados.md` | trabalho da sessão: todos os achados, com status e rodada. Temporário (`target/` está no `.gitignore`). |
| `target/feature-code-review/relatorio.md` | relatório curto que o dev cola na descrição do MR. Temporário. |
| `REVIEW.md` (raiz do repo) | memória de revisão, versionada. Lida em toda rodada. |
| `references/classificacao.md` | régua de severidade, comum aos dois agentes |
| `references/relatorio.md` | templates do `achados.md` e do `relatorio.md` |
| `references/code-smells.md` | base de smells do Fowler para o eixo Padrões |
| `references/caminhos-sensiveis.txt` | caminhos que exigem revisor humano |
| `scripts/caminhos-sensiveis.sh` | lista os arquivos do diff que casam com esses caminhos |
| `.claude/agents/revisor-padroes.md` | eixo Padrões |
| `.claude/agents/revisor-spec.md` | eixo Spec |

## Modos

- **`/feature-code-review`** faz a revisão completa do diff `origin/main...HEAD` e começa a rodada 1.
- **`/feature-code-review --delta`** é a nova passada depois das correções (Fase 1) ou depois do rebase com a `main` (Fase 3). Ela confere se os achados foram fechados e se o que mudou introduziu problema novo, sem repetir achados. Exige o `target/feature-code-review/achados.md` da rodada anterior; se ele não existir, avise e rode o modo completo.

## Passo 1: Verificação

Rode o script e leia só o bloco "Resumo":

```bash
mkdir -p target/feature-code-review
scripts/verify-slice.sh --base origin/main [--config <alvara.txt>] [--tests <Classe,...>] > target/feature-code-review/verify.log 2>&1
```

Repasse `--config` e `--tests` se o usuário os deu. Se terminar em `FALHAS`, **pare**. Mostre o resumo, peça a correção e não chame os agentes. Checkstyle, cobertura e `data-testid` são do script, e os agentes não repetem essas checagens.

`UnknownHostException` com o host do banco é problema de ambiente, não do código (`.claude/rules/ambiente-testes.md`). Nesse caso, peça um `--config` que aponte para o banco local.

## Passo 2: Ponto fixo

1. Tente `git fetch origin main`. Se falhar, siga com o `origin/main` local e avise que ele pode estar desatualizado.
2. A base padrão é `origin/main`; `--base <ref>` a substitui. Confirme com `git rev-parse --verify <base>`.
3. O diff é `git diff <base>...HEAD`, com três pontos, contra o merge-base. Os commits são `git log <base>..HEAD --oneline`.
4. Se houver arquivo alterado e não commitado (`git status --porcelain`), avise: a revisão cobre só o que está commitado. Pergunte se o dev quer commitar antes.
5. Diff vazio encerra a revisão.

**No `--delta`:** leia `head` e `rodada` no cabeçalho do `achados.md`.
- Se o `head` anterior for ancestral do `HEAD` (`git merge-base --is-ancestor <head> HEAD`), o diff da rodada é `git diff <head> HEAD`.
- Se não for, houve rebase. Use o diff completo `<base>...HEAD` e diga aos agentes que é a passada final depois do rebase.

## Passo 3: Spec

Procure nesta ordem:
1. O caminho passado em `--spec`.
2. A chave da branch: `feat/GDF-123` leva a `doc/specs/GDF-123/spec.md`.
3. A chave `GDF-\d+` nas mensagens de commit, que leva ao mesmo caminho.
4. Se nada for achado, **pergunte**: "Qual é a spec ou o card desta mudança? Pode colar o texto do card." O texto colado vira a spec da rodada. Grave-o em `target/feature-code-review/spec-colada.md`.
5. Se o dev disser que não há spec, o eixo Spec é **pulado**, e o relatório registra "Spec: não avaliada (sem spec)".

## Passo 4: Padrões

Monte a lista de arquivos de padrão. O agente lê esses arquivos por conta própria; você só passa os caminhos:
- `CLAUDE.md` e `.claude/rules/constitution.md`;
- as rules das áreas tocadas: `.claude/rules/backend/*` se o diff tem `.java`, `.claude/rules/frontend/*` se tem `src/main/webapp/**`;
- `.claude/rules/seguranca-owasp.md`, sempre;
- `.claude/skills/padronizacao-codigo/SKILL.md` e `references/`;
- `REVIEW.md`, que tem prioridade sobre os demais porque veio de erros reais;
- `references/code-smells.md`.

## Passo 5: Agentes

Chame **os dois agentes na mesma mensagem**, para rodarem em paralelo, cada um com contexto limpo. Não passe a eles a conversa com o dev, só o necessário:

- **`revisor-padroes`** recebe:
  - o comando do diff e a lista de commits;
  - a lista de arquivos de padrão do passo 4;
  - o caminho de `references/classificacao.md`;
  - no `--delta`, os achados abertos e os já tratados da rodada anterior, copiados do `achados.md`.
- **`revisor-spec`** recebe:
  - o comando do diff e a lista de commits;
  - o caminho da spec;
  - o `REVIEW.md` e o caminho de `references/classificacao.md`;
  - no `--delta`, os achados da rodada anterior.

Se o eixo Spec foi pulado no passo 3, chame só o `revisor-padroes`.

## Passo 6: Consolidar

1. **Não misture nem reordene os eixos.** As seções Padrões e Spec ficam separadas no `achados.md`, como cada agente as devolveu, só limpas.
2. Remova o achado que:
   - casa com uma entrada de "Não apontar" do `REVIEW.md` dentro do escopo dela;
   - repete um achado já tratado em rodada anterior;
   - é coberto pelo `verify-slice.sh`.
3. Aplique a **severidade mínima**: se o achado reincide numa entrada de "Regras ativas", a severidade não pode ficar abaixo da registrada nela.
4. Dê a cada achado um ID estável: `P-01`, `P-02`... para Padrões e `S-01`... para Spec. IDs nunca são reaproveitados entre rodadas.
5. Grave o `target/feature-code-review/achados.md` com o template de `references/relatorio.md`.

## Passo 7: Tratamento com o dev

Mostre no chat **só os Críticos e Importantes**, um por linha, e a contagem de Nits e Pré-existentes. Para cada Crítico e Importante, o dev escolhe:
- **corrigido:** o dev corrige, ou pede que você corrija. Só marque como corrigido depois que houver diff que resolva o achado;
- **intencional:** exige motivo;
- **falso positivo:** exige motivo.

Nits e Pré-existentes não exigem resposta. Atualize o status no `achados.md`.

## Passo 8: Rodadas

- Se sobrar **Crítico aberto**, peça a correção e diga para rodar `/feature-code-review --delta`. Cada rodada incrementa `rodada` no `achados.md`.
- **Na 3ª rodada com Crítico ainda aberto**, pare de iterar e sugira rever a abordagem: "Três rodadas e o Crítico continua. Vale rever a abordagem antes de seguir corrigindo ponto a ponto."
- Crítico **intencional** não conta como aberto, mas obriga revisor humano (passo 10).

## Passo 9: REVIEW.md

Quando não houver mais Crítico aberto, proponha as entradas novas, **uma por vez**, e grave só as que o dev confirmar:

| Achado | Seção do `REVIEW.md` |
|---|---|
| Crítico **corrigido** | **Regras ativas**, como `RV-NNN` |
| **Falso positivo** confirmado | **Não apontar**, como `FP-NNN` |
| Importante, Nit, Pré-existente, Crítico intencional | não entram |

Regras para escrever as entradas:
- **Escreva a classe do bug, não a linha.** "Query de alvará sem filtro de município" serve como regra; "linha 42 do `FooService`" não serve.
- Use o próximo número livre e nunca renumere.
- **"Não apontar" tem escopo estreito.** Cada entrada cita o local ou padrão exato a que se aplica, nunca vale como liberação geral. Um falso positivo de **segurança** só entra se o dev disser explicitamente que o revisor do MR vai confirmá-lo.
- Antes de criar uma entrada, procure se já existe uma de mesma classe. Se existir, só acrescente a origem nela.
- As entradas novas aparecem no relatório como "aprovar no diff", porque **quem aprova é o revisor do MR**.
- Você **não faz commit** (o `settings.json` bloqueia). Peça ao dev para commitar o `REVIEW.md` na própria branch.

Um Crítico pode vir do revisor humano no MR ou de um bug em produção, e não da skill. Nesse caso o dev pode rodar `/feature-code-review --delta` depois da correção e pedir a entrada, ou editar o `REVIEW.md` à mão com o mesmo formato.

## Passo 10: Revisor humano e relatório

Rode `bash .claude/skills/feature-code-review/scripts/caminhos-sensiveis.sh <base>`.

**Revisor humano = SIM** se qualquer um destes for verdadeiro:
- houve **Crítico** em alguma rodada, **mesmo corrigido**;
- algum **Importante** ficou como intencional ou falso positivo;
- algum Crítico ficou como **intencional**;
- o script listou algum **caminho sensível**.

Caso contrário, **NÃO**: o próprio autor aprova e faz o merge.

Grave o `target/feature-code-review/relatorio.md` com o template curto de `references/relatorio.md`. Mostre o caminho e diga: "Cole na descrição do MR." Se der SIM, acrescente: "e adicione um revisor".

## Regras gerais

- Nunca faça commit nem push, nunca abra o MR e nunca poste comentário no GitLab.
- Não corrija código por conta própria. Só corrija se o dev pedir.
- O relatório do MR é curto e contém só o que o revisor precisa. O detalhe fica no `achados.md`.
- Não invente achado para preencher seção. "Nenhum achado" é um resultado válido.
