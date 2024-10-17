# Remoção do Sandbox da Aplicação

## Contexto
O NuAppFirewall requer o carregamento de regras de um arquivo JSON, armazenado localmente na máquina, para realizar a filtragem de tráfego de rede. Inicialmente, a aplicação estava configurada com o Sandbox habilitado para maior segurança e isolamento. No entanto, devido às restrições do Sandbox, houve dificuldades em acessar acessar o arquivo de regras. Para viabilizar o load das regras em nível de prova de conceito, foi necessário remover o Sandbox da aplicação.

## Decisão
A decisão foi remover o recurso de Sandbox da aplicação para permitir o acesso ao arquivo JSON, que contém as regras necessárias para a filtragem do fluxo de rede. Com essa mudança, a aplicação agora pode ler diretamente os arquivos armazenados fora dos diretórios restritos do Sandbox, o que permite a simplificação do processo de acesso das regras. 

Essa decisão foi tomada com base na necessidade imediata de acesso ao arquivo de regras, para viabilizar o load das regras pelo Rules Manager. No futuro, precisamos rever essa decisão para reintroduzir o isolamento sem impactar o acesso aos arquivos de regras. Isso será considerado para melhorar a segurança.

## Alternativas consideradas
* **Utilizar App Groups para compartilhar o arquivo de regras entre a aplicação e a extensão:** Essa alternativa não resolveu o problema de acesso ao arquivo de regras, por isso foi descartada. Mesmo com a configuração correta do App Group, o acesso ao arquivo foi negado pelo kernel.

* **Migração do arquivo de regras para o container de Sandbox da aplicação:** Essa opção foi descartada porque a migração não estava funcionando corretamente e o kernel continuava negando o acesso ao arquivo.

## Consequências

### Positivas

* Maior velocidade no desenvolvimento
* Maior Flexibilidade e facilidade de acesso ao arquivo de regras

### Negativas

* Redução no nível de Segurança da aplicação
