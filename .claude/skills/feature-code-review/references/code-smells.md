# Base de code smells (eixo Padrões)

São os 12 smells do Fowler (*Refactoring*, cap. 3) que a skill `code-review` de Matt Pocock usa como base. Valem estas regras:

- **Smell é sempre julgamento.** Marque com `(julgamento)` e cite o trecho.
- **O padrão documentado do repo vence a base.** Se `.claude/rules` ou `clean-code-principles` dizem outra coisa, siga o repo.
- **A severidade padrão é Nit.** Só suba para Importante se houver impacto real e explicável, por exemplo uma mudança que exigiria editar muitos arquivos.
- **Aponte só o que o diff introduziu ou piorou.** Smell antigo em código intocado não entra.

| Smell | Sinal no diff | Exemplo neste repo |
|---|---|---|
| **Mysterious Name** | o nome não diz o que a coisa faz | `processa()`, `dados2`, `flag` |
| **Duplicated Code** | lógica copiada em vez de reaproveitada | a mesma validação de alvará em dois services |
| **Feature Envy** | o método usa mais dados de outra classe do que da própria | um service montando regra que pertence à entidade |
| **Data Clumps** | os mesmos parâmetros sempre viajam juntos | `municipio, inscricao, cnpj` repetidos em várias assinaturas |
| **Primitive Obsession** | primitivo onde caberia um tipo | status de alvará como `String` solta em vez de enum |
| **Repeated Switches** | o mesmo `switch`/`if` por tipo em vários lugares | `switch` por cliente espalhado em vez de estratégia |
| **Shotgun Surgery** | uma mudança simples exige editar muitos arquivos | adicionar um campo exige tocar 8 classes |
| **Divergent Change** | uma classe muda por motivos não relacionados | um service que trata PDF, e-mail e regra de negócio |
| **Speculative Generality** | abstração "para o futuro" sem uso atual | interface com uma única implementação e parâmetro não usado |
| **Message Chains** | `a.getB().getC().getD()` | navegação longa entre entidades |
| **Middle Man** | a classe só delega | service que só repassa ao repository |
| **Refused Bequest** | a subclasse ignora ou anula o que herda | override que lança `UnsupportedOperationException` |
