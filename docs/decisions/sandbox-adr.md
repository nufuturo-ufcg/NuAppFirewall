# Utilização de Sandbox

## Contexto
O NuAppFirewall é uma aplicação de segurança projetada para filtrar o fluxo de rede, atuando como um firewall. Devido ao caráter sensível de sua função, é importante que a aplicação opere com um alto nível de segurança. Por isso, decidimos isolar a aplicação em um ambiente Sandbox.

## Decisão
Foi decidido utilizar o Sandbox para que o NuAppFirewall execute seu código em um ambiente isolado e controlado. Esse isolamento protege o sistema operacional contra potenciais falhas ou vulnerabilidades do código, uma vez que, mesmo com práticas de codificação segura, aplicações ainda podem apresentar riscos à segurança dos usuários. O uso do Sandbox visa oferecer uma camada extra de proteção para os usuários.

O NuAppFirewall necessita carregar regras a partir de um arquivo JSON armazenado localmente para realizar a filtragem do fluxo de rede. Para manter o isolamento da aplicação e, ao mesmo tempo, permitir o acesso ao arquivo de regras pelo *Network Extension*, o arquivo foi alocado em um diretório **Group Containers**. Esse espaço de armazenamento compartilhado permite que o app principal e suas extensões acessem dados armazenados localmente de forma segura e controlada, mesmo com o Sandbox habilitado. O path escolhido para o arquivo de regras foi:

> /private/var/root/Library/Group Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application Support/arquivo-de-regras

## Alternativas consideradas
* **Não utilizar o Sandbox:** Essa opção foi descartada, pois a ausência do Sandbox pode comprometer a segurança da aplicação e expor o usuário à vulnerabilidades.

## Consequências

### Positivas

* Aumento da segurança e do isolamento da aplicação
* Conformidade com práticas de desenvolvimento seguro

### Negativas

* Aumento da complexidade no processo de desenvolvimento, devido ao isolamento do Sandbox: Por exemplo, para que o NuAppFirewall possa ler o arquivo JSON de regras, é necessário movê-lo para um diretório do tipo *Group Containers*, pois o isolamento do Sandbox impede a leitura de arquivos em locais comuns do sistema. Isso gera uma complexidade adicional, que não estaria presente em um ambiente sem esse isolamento.
