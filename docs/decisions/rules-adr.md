# Definição da Estrutura de uma Regra

## Contexto
O NuAppFirewall como um content filter, naturalmente, necessita de uma forma padronizada para determinar o que bloquear e o que permitir. Este documento descreve nossas decisões em relação à estrutura de uma regra dentro do contexto da nossa aplicação.

Importante destacar que essa decisão está em constante revisão porque nossa ideia é partir de uma regra simples e ir aumentando a complexidade aos poucos. Essa decisão foi tomada para acelerar o processo de implantação de um MVP. 

## Decisão
Uma regra (entidade `Rule` no código) tem a seguinte estrutura: 

* ID da regra 
* O path da aplicação referida
* A ação que a regra está tratando (block ou allow)
* O endpoint tratado na regra, podendo ser uma URL ou um IP
* O domínio do endpoint respectivo definido na regra

Também foi definido o ID da regra seguindo uma estrutura específica que por si só contém boa parte das informações acerca da regra, tendo sua estrutura sintática da seguinte forma:

**aplicação-ação-domínio**

Sendo cada uma dessas informações também presente na estrutura de dado da regra como um atributo, assim, só com o ID da regra é possível obter todas as informações acerca da regra e como ela deve ser implementada na lógica do filtro de conteúdo.

## Alternativas consideradas
* Apenas uma lista de endpoints em uma regra, em que cada aplicação teria apenas uma regra de allow com vários endpoints por exemplo.

* Uma regra teria uma lista de endpoints e uma lista de domains associados a esses endpoints.

## Consequências

### Positivas

* A regra se torna mais concisa e coesa.
* É facilitada a ação de remover ou adicionar uma política específica a uma aplicação.
* A obtenção e aplicação de uma regra é facilitada, com o sistema antigo de uma lista de endpoints haveria um parsing dessa para verificar se dado tráfego de informação recebido deveria ser aceito, com a decisão definida acerca das regras atualmente isso se torna O(1) a partir do ID da regra.

### Negativas

* Há um aumento de informação repetitiva dentre as regras em que, por exemplo, normalmente há uma multiplicidade de regras allow de uma mesma aplicação.

