# Nu-App-Firewall

O **Nu App Firewall** é um firewall desenvolvido para macOS utilizando Swift. O objetivo principal é implementar uma PoC do nosso content-filter, que executará em modo passive-allow. Os logs gerados devem usar a infraestrutura do macos e devem adequar-se aos requisitos levantados de forma iterativa e incremental.
Este projeto segue uma adaptação da arquitetura Diplomat do Nubank, personalizada para uma aplicação nativa.

## Estrutura de Pastas

Abaixo está a estrutura de pastas do projeto e uma breve descrição de cada uma:
```
nu-app-firewall/
│
├── Resources/
│   └── (Arquivos de recursos)
│
├── Src/
│   ├── Main.swift
│   ├── Controller/
│   │   ...
│   │
│   ├── Logic/
│   │   ...
│   │   
│   ├── Model/
│   │   ...
│   │ 
│   └── Utils/
│   │   ...
│
└── README.md
```

## Pré-requisitos

macOS 10.15 ou superior

Xcode 12.0 ou superior

Swift 5.0 ou superior

## Como Executar

Clone o repositório:

```
git clone https://github.com/seu-usuario/nu-app-firewall.git
cd nu-app-firewall
```
Abra o projeto no Xcode:

```
open nu-app-firewall.xcodeproj
```

Compile e execute o projeto no Xcode. Certifique-se de que o esquema esteja configurado para o seu Mac.

## Como Contribuir

- Crie uma branch para a nova funcionalidade ou correção de bug (git checkout -b feature/nova-funcionalidade).
- Commit suas alterações (git commit -m 'Adiciona nova funcionalidade').
- Push para a branch (git push origin feature/nova-funcionalidade).
- Crie um Pull Request.
