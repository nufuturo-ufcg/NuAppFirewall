# Nu-App-Firewall
[![Licença GPL-2.0](https://img.shields.io/badge/Licença-GPLv2-blue.svg)](LICENSE)

The Nu App Firewall is a firewall developed for macOS using Swift. The main goal is to implement a PoC of our content-filter, which will operate in passive-allow mode. The generated logs should use macOS's infrastructure and must comply with the requirements raised iteratively and incrementally.
This project follows an adaptation of Nubank's Diplomat architecture, customized for a native application.

**Paper Abstract**: Managing network access is essential to ensure the security of both users and corporate ecosystems. On macOS, this control is implemented through Content Filters in firewall applications. However, the state of the practice consists mainly of proprietary consumer tools, while open-source alternatives lack the modularity needed for enterprise adoption. This paper introduces NuAppFirewall, an open-source application firewall developed and deployed in production at Nubank. It includes more than 250,000 automatically generated rules for macOS applications, derived from Nubank's validated accesses, minimizing VPN usage and providing a security foundation that other organizations can leverage for their own implementations.

# README.md Structure
This repository is organized as follows:

```
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
├── NuAppFirewall2.0.1.dmg
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

# Considered Badges

The considered badges are: **Available** and **Functional**.

# Basic Information  
These are the minimum requirements to run the tool:  

- macOS 12.4 or later  
- Xcode 12.0 or later  
- Swift 5.0 or later  

# Dependencies  

There are no dependencies required to run the tool.  

# Security Concerns

There are no security concerns.

# Installation

## Run via DMG

1. Download the disk image [_NuAppFirewall2.0.1.dmg_](./NuAppFirewall2.0.1.dmg) in this repository's root directory;
2. Open the disk image;  
3. Drag the _NuAppFirewall.app_ to the _Applications_ folder

![Captura de Tela 2025-02-13 às 15 28 04](https://github.com/user-attachments/assets/09d3640f-4122-4912-a140-2db79fa762a0)

4. Create the path where the rules will be stored:  
```bash
sudo mkdir -p "/private/var/root/Library/Group Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application Support/"
```

5. Download the [rules file](./Rules/rules.json) available in the repository;

6. Move the rules file to the path where the extension will read the rules:
```bash
sudo mv path/to/rules /private/var/root/Library/Group\ Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application\ Support/
```

7. Click on the application icon that appears in Finder. 
8. Grant the requested permissions. 

The firewall will be activated. To check the logs, use: 
```bash
log stream --predicate "subsystem='com.nufuturo.nuappfirewall.extension'" --info
```

## Run via CLI (signing configuration will be required)

In order to run this application on CLI, you need to have a apple developer license and re-sign this code with your team ID.

1. Clone the repository:
```bash
git clone https://github.com/nufuturo-ufcg/NuAppFirewall.git
```

2. Navigate to the project directory:
```bash
cd NuAppFirewall
```

3. Create the path where the rules will be stored:
```bash
sudo mkdir -p "/private/var/root/Library/Group Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application Support/"
```

4. Move the rules file to the path where the extension will read the rules:
```bash
sudo mv ./Rules/rules.json /private/var/root/Library/Group\ Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application\ Support/
```

5. Build and run the project in the terminal:
```
make run
```

Grant the requested permission.

# Uninstallation

1. Open Activity Monitor;
2. Search for 'com.nufuturo.nuappfirewall.extension';
3. Double-click the process that appears;
4. Click 'Quit', then 'Force Quit';
5. Enter your computer password.

The extension will be deactivated. To confirm, run the following command:
```bash
systemextensionsctl list
```

# Minimum Test

If the installation process was completed correctly, you can use the following command to check the syslog for flow interception and rule application:  

```bash
log stream --predicate "subsystem='com.nufuturo.nuappfirewall.extension'" --info
```

# Experiments

## CPU and Memory Usage

1. Run the application;
2. Open Activity Monitor on macOS;
3. Search for 'com.nufuturo.nuappfirewall.extension';
4. CPU and memory information can be found in their respective tabs and columns.

Open Activity Monitor and search for 'com.nufuturo.nuappfirewall.extension'.

## How to Run Unit Tests 

To run the unit tests, follow the instructions below: 

1. Clone the repository:
```bash
git clone https://github.com/nufuturo-ufcg/NuAppFirewall.git
```

2. Navigate to the project directory:
```bash
cd NuAppFirewall
```
    
3. Run the command to execute the tests:
```bash
make test
```

## How to Run System Tests

1. Ensure that the firewall is deactivated.     
    1.1 Run the following command to check if the extension is deactivated:  
    ```bash
    systemextensionsctl list
    ```
   
   1.2 If it is not deactivated, follow the steps in the Uninstallation section to disable it.
   
2. Clone the repository:
```bash
git clone https://github.com/nufuturo-ufcg/NuAppFirewall.git
```

3. Navigate to the project directory:
```bash
cd NuAppFirewall
```

4. Run the command to execute the system tests:
```bash
make systemTest
```

The test rules file will be deployed in the directory where the extension will read from. After that, the application will be activated, and the system tests will perform a check of the correct application of the rules and validation through the syslog.   

# Other Makefile Commands  

To view other available commands in the Makefile, use the following command at the root of the project:  

```
make help
```

# How to Contribute

- Create a branch for the new feature or bug fix:
    ```bash
    git checkout -b feature/new-feature
    ```

- Commit your changes:
    ```bash
    git commit -m 'Add new feature'
    ```

- Push to the branch:
    ```bash
    git push origin feature/new-feature
    ```

- Create a Pull Request. 

# LICENSE  
This project is licensed under the [GPL-2.0 License](LICENSE), see the [LICENSE](LICENSE) file for more details. 
