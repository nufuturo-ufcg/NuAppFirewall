# ADR: Formato e Avaliação das Regras do NuAppFirewall

## Contexto

O NuAppFirewall é um filtro de conteúdo desenvolvido para macOS, projetado para bloquear ou permitir conexões de rede com base em regras predefinidas. As regras determinam ações específicas (`allow` ou `block`) para endpoints e portas específicas. Além disso, o NuAppFirewall pode aplicar bloqueios completos em aplicações específicas, restringindo todas as conexões de rede originadas por essas aplicações.

Durante o desenvolvimento do sistema, foi necessário definir um formato padrão para as regras e especificar como o processo de avaliação deve ser conduzido. Esse processo de avaliação determina qual regra será aplicada a cada conexão, especialmente em casos de múltiplas regras conflitantes.

### Formato da Regra

Cada regra possui os seguintes atributos:

- **ruleID**: Identificador único da regra.
- **action**: Ação a ser aplicada (`allow` ou `block`).
- **application**: Bundle ID, caminho completo ou subcaminho da aplicação que fez requisição de conexão.
- **endpoint**: URL, host ou endereço IP ao qual a regra se aplica.
- **port**: Porta associada ao endpoint para a qual a regra será avaliada.
- **destination**: Destino da conexão, sendo composto pelo par "endpoint:port".

### Abordagens Consideradas para Avaliação

Foram consideradas três abordagens principais para a avaliação das regras:

1. **Atribuição de prioridade entre regras**: permitir que cada regra tenha um valor de prioridade que determine sua precedência em casos de conflito.

2. **Prioridade fixa para regras `block`**: dar precedência para a ação `block` sobre `allow` em qualquer situação de conflito.

3. **Prioridade de acordo com a informação de identificação da aplicação**: dar preferência para as regras em que as aplicações são identificadas pelo bundle id, em seguida pelo path e, por fim, subpath.

A decisão final considerou a necessidade de simplificar a lógica de avaliação sem comprometer a segurança.

## Decisão

A abordagem adotada prioriza regras com base no nível de especificidade da identificação da aplicação e na garantia de que ações de bloqueio (block) prevaleçam em situações de conflito. A avaliação segue estas diretrizes:

1. Regras com identificação mais específica, seguindo a prioridade: **bundle ID > path > subpath**.
2. Em casos de conflito na ação definida, o bloqueio `block` sempre prevalece sobre a permissão `allow`.
   
Para garantir desempenho, é utilizada uma estrutura do tipo Set para verificar em O(1) se uma aplicação possui regras associadas. Esse Set funciona como uma espécie de "flag", indicando previamente se há ou não regras vinculadas à aplicação, evitando buscas desnecessárias nas estruturas principais. Caso existam regras, todas as combinações possíveis de parâmetros (URL, host, IP, porta e genéricos, como any) são recuperadas de uma única vez. Essas regras estão armazenadas em um dicionário de dicionários com acesso em O(1) para cada combinação. Essa estratégia é fundamental para evitar a necessidade de múltiplas buscas isoladas (por exemplo, buscar primeiro por block e depois por allow), que aumentariam a probabilidade de fallback, um processo mais custoso por envolver a busca por subpath.

Se nenhuma regra estiver associada à aplicação, identificada pela ausência da aplicação no Set, o sistema realiza um fallback que busca regras vinculadas ao subpath. Esse processo percorre as aplicações presentes nas regras e verifica se algum dos subpaths configurados (por exemplo, /application) corresponde ao path completo capturado pela extensão. Essa verificação é mais custosa, pois exige a comparação entre cada subpath das regras e o path completo fornecido pela requisição. Por isso, o fallback é minimizado pela estratégia de recuperação antecipada das regras.

Entre as regras recuperadas, nenhuma decisão é tomada imediatamente. Todas as combinações relevantes para o fluxo são reunidas em uma lista. A seleção da regra mais adequada ocorre posteriormente por meio da função selectRule, que prioriza regras mais genéricas, como any:any, antes das mais específicas (por exemplo, com IP e porta definidos). Em casos de conflito entre permissões (allow) e bloqueios (block), a ação de bloqueio sempre tem prioridade, reforçando a segurança do sistema.

## Consequências

- **Simplicidade**: A ausência de um sistema de prioridades numéricas reduz a complexidade do código, substituindo-o por uma lógica de avaliação que prioriza a identificação da aplicação, a especificidade das regras e `block` em casos de conflito. Essa abordagem facilita a manutenção e a compreensão do sistema.
  
- **Previsibilidade**: A abordagem adota uma política de segurança clara, na qual bloqueios têm prioridade sobre permissões em cenários de conflito. Além disso, a hierarquia de avaliação, que segue do mais geral para o mais específico, contribui para um comportamento previsível e consistente.

- **Menor Flexibilidade**: A falta de prioridades numéricas nas regras limita configurações avançadas de controle. Porém, a simplicidade e previsibilidade do sistema foram consideradas mais vantajosas para o objetivo de segurança do NuAppFirewall.
