# Nu-App-Firewall
[![Licença GPL-2.0](https://img.shields.io/badge/Licença-GPLv2-blue.svg)](LICENSE)

The Nu App Firewall is a firewall developed for macOS using Swift. The main goal is to implement a PoC of our content-filter, which will operate in passive-allow mode. The generated logs should use macOS's infrastructure and must comply with the requirements raised iteratively and incrementally.
This project follows an adaptation of Nubank's Diplomat architecture, customized for a native application.

**Paper Abstract**: Managing network access is essential to ensure the security of both users and corporate ecosystems. On macOS, this control is implemented through Content Filters in firewall applications. However, the state of the practice consists mainly of proprietary consumer tools, while open-source alternatives lack the modularity needed for enterprise adoption. This paper introduces NuAppFirewall, an open-source application firewall developed and deployed in production at Nubank. It includes more than 250,000 automatically generated rules for macOS applications, derived from Nubank's validated accesses, minimizing VPN usage and providing a security foundation that other organizations can leverage for their own implementations.

# Estrutura do readme.md

```
nu-app-firewall
    ├── LICENSE
    ├── Makefile
    ├── NuAppFirewall
    │   ├── Extension
    │   │   ├── Extension.entitlements
    │   │   ├── ExtensionDebug.entitlements
    │   │   ├── FilterDataProvider.swift
    │   │   ├── Info.plist
    │   │   └── main.swift
    │   ├── NuAppFirewall
    │   │   ├── Assets.xcassets
    │   │   ├── NuAppFirewall.entitlements
    │   │   ├── NuAppFirewallDebug.entitlements
    │   │   ├── Preview Content
    │   │   ├── Resources
    │   │   └── Src
    │   ├── NuAppFirewall.app
    │   │   └── Contents
    │   ├── NuAppFirewall.xcodeproj
    │   │   ├── project.pbxproj
    │   │   ├── project.xcworkspace
    │   │   ├── xcshareddata
    │   │   └── xcuserdata
    │   └── NuAppFirewallTests
    │       ├── Consts
    │       ├── Controller
    │       ├── Logic
    │       ├── Model
    │       ├── SystemTests
    │       ├── TestHelpers
    │       ├── TestPlans
    │       └── Utils
    ├── PerformanceData
    │   ├── NuAppFirewall_Benchmark_PC01.csv
    │   ├── NuAppFirewall_Benchmark_PC02.csv
    │   ├── NuAppFirewall_Benchmark_PC03.csv
    │   ├── NuAppFirewall_Benchmark_PC04.csv
    │   └── NuAppFirewall_Benchmark_PC05.csv
    ├── README.md
    ├── default.profraw
    ├── docs
    │   ├── RFC
    │   │   └── RFC AppFirewall.md
    │   ├── decisions
    │   │   ├── block-rules-adr.md
    │   │   ├── rules-adr.md
    │   │   ├── sandbox-adr.md
    │   │   ├── targets-adr.md
    │   │   └── template-adr.md
    │   └── images
    │       ├── appfirewall_componentes.png
    │       ├── appfirewall_contexto.png
    │       ├── appfirewall_implantacao.png
    │       └── directory_tree.png
    └── file.txt
```

# Selos considerados

Os selos considerados são: **Disponíveis** e **Funcionais**.

# Informações básicas
Estes são os requisitos mínimos para execução da ferramenta:

- macOS 12.4 ou superior
- Xcode 12.0 ou superior
- Swift 5.0 ou superior

# Dependências

Não há dependências para execução da ferramenta.

# Preocupações com segurança

Não há preocupações com segurança.

# Instalação

### Executar por meio do DMG

1. Baixe a imagem de disco _NuAppFirewall2.0.1.dmg_ que está disponível no repositório.
2. Abra a imagem de disco.
3. Arraste o aplicativo _NuAppFirewall.app_ para a pasta _Aplicativos_.

![Captura de Tela 2025-02-13 às 15 28 04](https://github.com/user-attachments/assets/09d3640f-4122-4912-a140-2db79fa762a0)

4. Crie o path onde as regras serão armazenadas:
```bash
sudo mkdir -p "/private/var/root/Library/Group Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application Support/"
```

5. Baixe o [arquivo](./Rules/rules.json) de regras presente no repositório 

6. Mova o arquivo de regras para o path no qual a extensão lerá as regras
```bash
sudo mv path/to/rules /private/var/root/Library/Group\ Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application\ Support/
```

7. Clique no ícone do aplicativo que aparecerá no Finder;
8. Conceda as permissões que serão solicitadas.

O firewall será ativado. Para verificar os logs, use:
```bash
log stream --predicate "subsystem='com.nufuturo.nuappfirewall.extension'" --info
```

### Executar por meio da CLI (será necessário ter as assinaturas configuradas)

1. Clone o repositório:
```bash
git clone https://github.com/nufuturo-ufcg/NuAppFirewall.git
```

2. Entre no diretório do projeto:
```bash
cd NuAppFirewall
```

3. Crie o path onde as regras serão armazenadas:
```bash
sudo mkdir -p "/private/var/root/Library/Group Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application Support/"
```

4. Mova o arquivo de regras para o path no qual a extensão lerá as regras
```bash
sudo mv ./Rules/rules.json /private/var/root/Library/Group\ Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application\ Support/
```

5. Compile e execute o projeto no terminal:
```
make run
```

Dê a permissão que será solicitada.

# Desistalação

1. Abra o Monitor de Atividade;
2. Busque por 'com.nufuturo.nuappfirewall.extension';
3. Clique 2x no processo que aparecerá;
4. Clique em 'Quit' seguido de 'Force Quit';
5. DIgite a senha do seu computador.

A extensão será desativada. Para confirmar execute o seguinte comando: 
```bash
systemextensionsctl list
```

# Teste mínimo

Se o processo de instalação foi realizado corretamente, é possível usar o seguinte comando para verificar no syslog a interceptação de fluxos e aplicação de regras.

```bash
log stream --predicate "subsystem='com.nufuturo.nuappfirewall.extension'" --info
```

# Experimentos

## Consumo de CPU e memória

1. Execute a aplicação;
2. Acesse o monitor de atividade no macOS;
3. Faça uma busca por 'com.nufuturo.nuappfirewall.extension';
4. As informações de CPU e memória serão encontradas em suas respectivas abas e colunas.

Acesse o monitor de atividade e faça uma pesquisa por 'com.nufuturo.nuappfirewall.extension'

## Como executar os testes de unidade

Para executar os testes de unidade, siga as instruções abaixo:

1. Clone o repositório
```bash
git clone https://github.com/nufuturo-ufcg/NuAppFirewall.git
```

2. Navegue até o diretório do projeto
```bash
cd NuAppFirewall
```
    
3. Execute o comando para rodar os testes:
```bash
make test
```

## Como executar os testes de sistema

1. Assegure-se que o firewall está desativado.
   1.1 Execute o seguinte comando para verificar se a extensão está desativada:
   ```bash
   systemextensionsctl list
   ```
   
   1.2 Se não estiver desativada, siga os passos do tópico de Desistalação para desativá-la.
   
2. Clone o repositório
```bash
git clone https://github.com/nufuturo-ufcg/NuAppFirewall.git
```

3. Navegue até o diretório do projeto
```bash
cd NuAppFirewall
```

4. Execute o comando para realizar os testes de sistema:
```bash
make systemTest
```

O arquivo de regras de teste serão implantados no diretório que a extensão fará a leitura. Após isso, a aplicação será ativada e os testes de sistema farão um exercício da aplicação correta das regras e validação por meio do syslog.

# LICENSE
Este projeto está licenciado sob a [GPL-2.0 License](LICENSE), veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## Outros Comandos do Makefile

Para visualizar outros comandos disponíveis no Makefile use o seguinte comando na raiz do projeto:

```
make help
```

## Como Contribuir

- Crie uma branch para a nova funcionalidade ou correção de bug:
    ```bash
    git checkout -b feature/nova-funcionalidade
    ```

- Commit suas alterações:
    ```bash
    git commit -m 'Adiciona nova funcionalidade'
    ```

- Push para a branch:
    ```bash
    git push origin feature/nova-funcionalidade
    ```

- Crie um Pull Request.
