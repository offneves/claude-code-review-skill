# Classificação dos achados

Régua única para os dois eixos. A pergunta-guia é: **"se isto for para produção assim, o que acontece?"**

| Severidade | Critério | Efeito no fluxo |
|---|---|---|
| **Crítico** | Quebra a aplicação, corrompe ou vaza dados, ou abre falha de segurança. | Bloqueia: corrigir antes do MR. Leva o MR a revisor humano mesmo depois de corrigido. Quando corrigido, vira entrada em "Regras ativas". |
| **Importante** | Não quebra agora, mas o risco é provável ou fere uma regra do projeto. | Corrigir ou justificar. Uma justificativa leva o MR a revisor humano. |
| **Nit** | Legibilidade, nome, smell leve. | Opcional. Não trava nada e não vai para o MR. |
| **Pré-existente** | Problema no código tocado que o diff **não** introduziu. | Não é cobrado do autor. Só é contado, e pode virar card. |

## Exemplos por eixo

**Padrões**
- **Crítico:**
  - falha OWASP (injeção, controle de acesso ausente, segredo no código, dado pessoal em log);
  - migração em `databaseVersion` que perde ou corrompe dados existentes;
  - query sem filtro de município ou cliente;
  - bug de lógica num caminho real (null, transação, concorrência, condição invertida);
  - reincidência de uma entrada com severidade mínima Crítico no `REVIEW.md`.
- **Importante:**
  - violação de rule em `.claude/rules` ou da constituição;
  - tratamento de erro ausente;
  - comportamento por cliente (`alvara.txt`) não tratado;
  - smell com impacto real, como Shotgun Surgery ou Divergent Change num ponto central.
- **Nit:** nome pouco claro, smell leve, comentário desatualizado.

**Spec**
- **Crítico:** um `CA-xx` ou uma `RN-xx` não implementado, ou implementado de forma que contradiz a spec; contrato (rota, DTO, código de erro, permissão) diferente da seção 6.
- **Importante:** `CA` implementado em parte; comportamento fora do escopo da spec (scope creep) com efeito visível; caso de erro da spec sem tratamento.
- **Nit:** mensagem ao usuário diferente do texto da spec sem mudar o sentido; escopo extra inofensivo.

## Regras

- **Na dúvida entre duas severidades, escolha a menor e diga por quê.** Exagerar a severidade gera ruído e faz o time parar de ler.
- **Separe violação de julgamento**, como na skill do Matt. Violação de regra escrita é fato. Smell é sempre julgamento: marque com `(julgamento)`.
- **O padrão documentado do repo vence a base do Fowler.** Se uma rule permite algo que a base chama de smell, não aponte.
- **Não aponte o que o tooling já pega.** Checkstyle, cobertura de testes e `data-testid` são do `verify-slice.sh`.
- **Pré-existente só se aplica ao que o diff não introduziu.** Se o diff piorou um problema antigo, o achado é do diff.
