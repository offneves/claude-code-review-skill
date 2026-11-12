# Base de code smells (eixo Padrões)

Conjunto fixo de smells do Fowler (*Refactoring*, cap. 3), igual ao da skill `code-review` de Matt Pocock (cópia original em `referencia/matt-pocock-code-review/SKILL.md` no pacote). Vale mesmo quando o repo não documenta nada.

**Esta lista vai colada por inteiro no prompt do `revisor-padroes`.**

Regras:
- **O repo vence.** Um padrão documentado do repo sempre prevalece; onde ele permite algo que a base apontaria, o smell é suprimido.
- **Sempre julgamento.** Cada smell é uma heurística rotulada ("possível Feature Envy"), nunca uma violação dura. Pule o que o tooling já garante.
- **Severidade padrão: Nit.** Só suba para Importante se o impacto for real e explicável.
- **Só o que o diff introduziu ou piorou.** Smell antigo em código intocado não entra.

Cada smell diz **o que é** → **como corrigir**, mais um exemplo deste repo. Compare com o diff:

| Smell | O que é → como corrigir | Exemplo neste repo |
|---|---|---|
| **Mysterious Name** | função, variável ou tipo cujo nome não revela o que faz ou guarda → renomear; se não sair um nome honesto, o design está confuso | `processa()`, `dados2`, `flag` |
| **Duplicated Code** | a mesma forma de lógica aparece em mais de um trecho ou arquivo da mudança → extrair a forma comum e chamá-la dos dois lugares | a mesma validação de alvará em dois services |
| **Feature Envy** | método que mexe mais nos dados de outro objeto do que nos próprios → mover o método para junto dos dados que ele inveja | service montando regra que pertence à entidade |
| **Data Clumps** | os mesmos campos ou parâmetros viajam sempre juntos (um tipo querendo nascer) → agrupar num tipo e passar esse tipo | `municipio, inscricao, cnpj` repetidos em várias assinaturas |
| **Primitive Obsession** | primitivo ou string no lugar de um conceito de domínio que merece tipo próprio → dar ao conceito um tipo pequeno | status de alvará como `String` solta em vez de enum |
| **Repeated Switches** | o mesmo `switch`/cascata de `if` sobre o mesmo tipo se repete na mudança → trocar por polimorfismo, ou por um mapa compartilhado pelos dois pontos | `switch` por cliente espalhado em vez de estratégia |
| **Shotgun Surgery** | uma mudança lógica obriga edições espalhadas por muitos arquivos do diff → juntar num módulo o que muda junto | adicionar um campo exige tocar 8 classes |
| **Divergent Change** | um arquivo ou módulo é editado por vários motivos sem relação → separar para que cada módulo mude por um motivo só | service que trata PDF, e-mail e regra de negócio |
| **Speculative Generality** | abstração, parâmetro ou gancho para necessidades que a spec não tem → apagar; desfazer até aparecer uma necessidade real | interface com uma única implementação e parâmetro não usado |
| **Message Chains** | navegação longa `a.b().c().d()` da qual o chamador não deveria depender → esconder o caminho atrás de um método no primeiro objeto | navegação longa entre entidades |
| **Middle Man** | classe ou função que basicamente só delega → cortar e chamar o alvo real direto | service que só repassa ao repository |
| **Refused Bequest** | subclasse ou implementação que ignora ou sobrescreve quase tudo o que herda → abandonar a herança e usar composição | override que lança `UnsupportedOperationException` |
