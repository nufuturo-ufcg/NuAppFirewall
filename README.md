# Nu-App-Firewall

O **Nu App Firewall** é um firewall desenvolvido para macOS utilizando Swift. O objetivo principal é implementar uma PoC do nosso content-filter, que executará em modo passive-allow. Os logs gerados devem usar a infraestrutura do macos e devem adequar-se aos requisitos levantados de forma iterativa e incremental.  
Este projeto segue uma adaptação da arquitetura Diplomat do Nubank, personalizada para uma aplicação nativa.

## Estrutura de Pastas

Abaixo está a estrutura de pastas do projeto e uma breve descrição de cada uma:
```
nu-app-firewall
    ├── README.md
    └── NuAppFirewall
        ├── NuAppFirewall
        │   ├── Resources
        │   │   ├── ...
        │   └── Src
        │       ├── Controller
        │       │   └── ...
        │       ├── Logic
        │       │   └── ...
        │       ├── Model
        │       │   └── ...
        │       └── Utils
        │           └── ...
        ├── NuAppFirewall.xcodeproj
        │   ├── ...
        └── NuAppFirewallTests
        │       ├── Logic
        │       │   └── ...
        │       ├── Model
        │       │   └── ...
        │       └── Utils
        │           └── ...
```

## Pré-requisitos

- macOS 14.5 ou superior
- Xcode 12.0 ou superior
- Swift 5.0 ou superior

## Como Executar

Clone o repositório:

```bash
git clone https://github.com/seu-usuario/nu-app-firewall.git
```

Entre no diretório do projeto:

```bash
cd nu-app-firewall 
```

Compile e execute o projeto no terminal:

```
make run
```

Dê a permissão que será solicitada.

## Outros Comandos do Makefile

Para visualizar outros comandos disponíveis no Makefile use o seguinte comando na raiz do projeto:

```
make help
```
    
## Como Rodar os Testes de sistema

Para rodar os testes de sistema, siga as instruções abaixo:

### Via Linha de Comando

Você pode rodar os testes diretamente via linha de comando. Aqui estão os passos:

1. Abra o terminal e navegue até o diretório do projeto:
    ```bash
    cd /caminho/para/seu/projeto
    ```

2. Execute o comando para rodar os testes:
    ```
    make systemTest
    ```

Os resultados dos testes serão exibidos no terminal.

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
