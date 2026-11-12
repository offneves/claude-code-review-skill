# REVIEW.md: memória de revisão

Os agentes do `/feature-code-review` leem este arquivo em toda rodada. Ele cresce a partir de erros reais. Regras de manutenção:

- **Regras ativas:** todo Crítico corrigido vira uma regra, sobre a **classe do bug** e não sobre a linha. O agente sempre checa essas regras, e um achado que reincide não fica abaixo da severidade mínima registrada.
- **Não apontar:** falsos positivos confirmados, cada um com **escopo estreito**. Um falso positivo de segurança só entra com a confirmação do revisor.
- **Toda entrada nova vai no diff do MR** que a originou, e o **revisor do MR aprova** a entrada.
- **Uma regra que vira automática sai daqui.** Quando um teste, uma regra de Checkstyle ou uma rule em `.claude/rules` passa a pegar o problema, apague a entrada e cite onde a regra foi parar no MR que a removeu.
- IDs nunca são renumerados nem reaproveitados.

## Regras ativas

<!--
### RV-001 · <classe do bug, em poucas palavras>
- **Severidade mínima:** Crítico
- **Como detectar:** <o padrão no código que indica o problema>
- **Correção esperada:** <o que fazer; cite um exemplo correto no repo, se houver>
- **Origem:** <MR !NNN> · <AAAA-MM>
-->

## Não apontar

<!--
### FP-001 · <o que o agente costuma apontar>
- **Por que não é problema:** <motivo>
- **Vale só para:** <arquivo, classe ou padrão exato>
- **Origem:** <MR !NNN> · <AAAA-MM> · aprovado por <revisor>
-->
