# ADR: Formato e Avaliação das Regras do NuAppFirewall

## Contexto

O NuAppFirewall é um filtro de conteúdo desenvolvido para macOS, projetado para bloquear ou permitir conexões de rede com base em regras predefinidas. As regras determinam ações específicas (`allow` ou `block`) para endpoints e portas específicas. Além disso, o NuAppFirewall pode aplicar bloqueios completos em aplicações específicas, restringindo todas as conexões de rede originadas por essas aplicações.

Durante o desenvolvimento do sistema, foi necessário definir um formato padrão para as regras e especificar como o processo de avaliação deve ser conduzido. Esse processo de avaliação determina qual regra será aplicada a cada conexão, especialmente em casos de múltiplas regras conflitantes.

### Formato da Regra

Cada regra possui os seguintes atributos:

- **ruleID**: Identificador único da regra.
- **action**: Ação a ser aplicada (`allow` ou `block`).
- **appLocation**: Caminho da aplicação no sistema, indicando para qual aplicação a regra é válida.
- **endpoint**: URL, host ou endereço IP ao qual a regra se aplica.
- **port**: Porta associada ao endpoint para a qual a regra será avaliada.
- **destination**: Destino da conexão, sendo endpoint:port.

> **Aviso**: Atualmente, o `appLocation` (caminho completo da aplicação) é utilizado como parte da chave de busca para as regras. No entanto, isso traz uma vulnerabilidade, pois caminhos de aplicação podem variar ou mudar. No futuro, esse método será revisado para adotar identificadores mais consistentes e menos dependentes do caminho completo, assegurando maior robustez na aplicação das regras.

### Abordagens Consideradas para Avaliação

Foram consideradas duas abordagens principais para a avaliação das regras:

1. **Atribuição de prioridade entre regras**: permitir que cada regra tenha um valor de prioridade que determine sua precedência em casos de conflito.

2. **Prioridade fixa para regras `block`**: dar precedência para a ação `block` sobre `allow` em qualquer situação de conflito.

A decisão final considerou a necessidade de simplificar a lógica de avaliação sem comprometer a segurança.

## Decisão

A decisão foi **adotar a preferência pelas regras `block`** em situações de conflito. Dessa forma, em caso de múltiplas regras aplicáveis a uma conexão, a ação de bloqueio será priorizada. Essa escolha simplifica o código e elimina a necessidade de um atributo de prioridade nas regras. Além disso, as regras são mapeadas por IP, URL, host e aplicação total. Esse modelo de avaliação é inspirado em padrões de segurança, como o da AWS, onde bloqueios têm precedência sobre permissões em casos de conflito.

## Consequências

- **Simplicidade**: A ausência de um sistema de prioridades numéricas reduz a complexidade do código, facilitando o processo de avaliação das regras.
  
- **Previsibilidade**: A abordagem proporciona uma política de segurança mais rígida, garantindo que conexões com regras conflitantes sejam bloqueadas por padrão, reduzindo riscos de segurança.

- **Menor Flexibilidade**: A falta de prioridades numéricas nas regras limita configurações avançadas de controle. Porém, a simplicidade e previsibilidade do sistema foram consideradas mais vantajosas para o objetivo de segurança do NuAppFirewall.
