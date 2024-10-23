# Definição da Estrutura de uma Regra

## Contexto
O NuAppFirewall como um content filter, naturalmente, necessita de uma forma padronizada para determinar o que bloquear e o que permitir, para isso há uma estrutura de dados criada no projeto denominada Rule, sendo uma abstração atômica que define critérios para essas ações supracitadas acima. 

Assim, essas regras combinadas permitem uma decisão em tempo real sobre o tráfego de rede na máquina local, possibilitando segurança e flexibilidade para definição de políticas específicas sobre o fluxo de informação com a Internet de um computador usuario dessa extensão.

## Decisão
A decisão foi de definir uma regra com a seguinte estrutura: 

* ID da regra 
* O path da aplicação referida
* A ação que a regra está tratando (block ou allow)
* O endpoint tratado na regra, podendo ser uma URL ou um IP
* O domínio do endpoint respectivo definido na regra

Também foi definido o ID da regra seguindo uma estrutura específica que por si só contém boa parte das informações acerca da regra, tendo sua estrutura sintática da seguinte forma:
**aplicação-ação-domínio**

Sendo cada uma dessas informações também estando na estrutura de dado da regra como um atributo, assim, só com o ID da regra é possível obter todas as informações acerca da regra e como ela deve ser implementada na lógica do filtro de conteúdo.

## Alternativas consideradas
* Apenas uma lista de endpoints em uma regra, em que cada aplicação teria apenas uma regra de allow por exemplo.

* Uma regra teria uma lista de endpoints e uma lista de domains associados a esses endpoints.

## Consequências

### Positivas

* A regra se torna mais concisa e coesa.
* É facilitada a ação de remover ou adicionar uma política específica a uma aplicação.
* A obtenção e aplicação de uma regra é facilitada, com o sistema de uma lista haveria um parsing dessa para verificar se dado tráfego de informação recebido deveria ser aceito, com a decisão tomada isso se torna O(1) a partir do ID da regra.

### Negativas

* O número de regras aumenta já que o sistema antigos havia uma regra por dado conjunto aplicação e ação.
* Há um aumento de informação repetitiva dentre as regras em que, por exemplo, normalmente há uma multiplicade de regras allow de uma mesma aplicação.

