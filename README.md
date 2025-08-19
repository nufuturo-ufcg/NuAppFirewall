# Nu-App-Firewall
[![Licença GPL-2.0](https://img.shields.io/badge/Licença-GPLv2-blue.svg)](LICENSE)

NuAppFirewall is a firewall developed for macOS using Swift. The main goal is to implement a PoC of our content-filter, which will operate in passive-allow mode. The generated logs should use macOS's infrastructure and must comply with the requirements raised iteratively and incrementally.
The rules generator mentioned in the article is [available in this repository](https://github.com/nufuturo-ufcg/NuAppFirewall-catalog)

**Paper Abstract**: Managing network access is essential to ensure the security of both users and corporate ecosystems. On macOS, this control is implemented through Content Filters in firewall applications. However, the state of the practice consists mainly of proprietary consumer tools, while open-source alternatives lack the modularity needed for enterprise adoption. This paper introduces NuAppFirewall, an open-source application firewall developed and deployed in production at Nubank. It includes more than 250,000 automatically generated rules for macOS applications, derived from Nubank's validated accesses, minimizing VPN usage and providing a security foundation that other organizations can leverage for their own implementations.

# Video Demonstration
There is a video demonstration of how to install, execute and uninstall NuAppFirewall [here](https://drive.google.com/file/d/1KU959bDe9e71uaQchiK5_rbPXxX80QgM/view).

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
The considered badges are: **Available** (SeloD), **Functional** (SeloF), **Sustainable** (SeloS) and **Reproducible** (SeloR).

# Basic Information  
These are the minimum requirements to run the tool:  

- macOS 12.4 or later  
- Xcode 12.0 or later  
- Swift 5.0 or later  

# Dependencies  

To run the tool via CLI, you must have a paid Apple Developer account. This is required because some certificates and entitlements used by the application are only available with a paid subscription. No additional dependencies are needed.  

# Security Concerns

There are no security concerns.

# Installation

Please be advised that the installation described below will block your access to the following browsers: **Firefox** and **Arc**. This restriction can be reverted by uninstalling the application and its extension, as described in the [Uninstallation](#uninstallation) section.

## Run via DMG

1. Download the disk image NuAppFirewall2.0.1.dmg from the repository root, open it, and drag NuAppFirewall.app to the Applications folder;

![](/docs/images/dmg.png)

2. At the root of the project, run the Makefile target to install the rules (this will prompt for your Developer Team ID if needed):  

```bash
make install-rules-user RULES=./Rules/Demo/rules.json
```

3. Click on the application icon that appears in Finder. 

Grant the requested permissions. The firewall will be activated. To check the logs, use: 

```bash
log stream --predicate "subsystem='com.nufuturo.nuappfirewall.extension'" --info
```

## Run via CLI

If you want to run this project via the command line, please note that it requires a **paid Apple Developer account** and additional signing configurations.

To access the full guide, please refer to [CLI Guide](docs/tutorials/signing_tutorial.md).

# Uninstallation

1. Open Activity Monitor;
2. Search for 'com.nufuturo.nuappfirewall.extension';
3. Double-click the process that appears;
4. Click 'Quit', then 'Force Quit';
5. Enter your computer password;
6. Search for 'com.nufuturo.nuappfirewall.app' and follow the steps 3-5.

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

## Claim #1 – Performance Analysis (CPU and Memory)

**Objective:** Evaluate the CPU and memory consumption of the `com.nufuturo.nuappfirewall.extension` in a real environment, focusing on resource usage and stability.  

**Test Configuration:**  
- Devices: 5 × MacBook Air M1 (8 GB RAM)  
- Tested version: NuAppFirewall 2.0.0  
- Samples collected: 308,709  
- Usage period: continuous collection during real execution (between 3 and 7 days per machine)
- Measurement tool: `psutil` 6.1.0 (automatic collection)

**Execution Steps:**  

1. Run the application;  
2. Open Activity Monitor on macOS;  
3. Search for `com.nufuturo.nuappfirewall.extension`;  
4. CPU and memory information can be found in their respective tabs and columns.  

**Expected resource usage:**  
- CPU: average consumption of 0.72%  
- Memory: average consumption of 10.97 MB 

> **Note:** During the first few seconds after the extension’s activation, spikes in both CPU and memory usage were observed due to the intensive initial processing. Subsequently, both consumptions decreased and remained at low levels during continuous use.  

**Expected outcome:** Confirmation that CPU and memory consumption remain low most of the time, with spikes limited to the initialization phase.

## Claim #2 – Unit Tests Execution

**Objective:** Validate the correctness of the firewall's core functionalities through automated unit tests, ensuring code quality and reliability.

**Execution Steps:**  
   
> **Note:** Before running the unit tests, ensure you have completed the code signing steps described earlier in [Run via CLI (signing configuration will be required)](#run-via-cli-signing-configuration-will-be-required).  
> You do **not** need to run `make run` (as described in the previous steps); for system tests, run only `make test`.

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

**Expected execution time:** Approximately 15 seconds.

**Results obtained:**

- All unit tests executed successfully with a 100% pass rate.

- No errors reported.

**Expected outcome:** Confirmation that all implemented functionalities behave as expected in isolated testing, with no regressions detected.

## Claim #3 – System Tests Execution

**Objective:** Verify the correct integration and behavior of the firewall extension in a real macOS environment, validating the application of rules and logging.

**Execution Steps:**  

> **Note:** Before running the system tests, ensure you have completed the code signing steps described earlier in [Run via CLI (signing configuration will be required)](#run-via-cli-signing-configuration-will-be-required).  
> You do **not** need to run `make run` (as described in the previous steps); for system tests, run only `make systemTest`.
> Also, if you do not apply the `Makefile` modifications indicated in the previous steps, the firewall may start with rules different from those expected by the tests, leading to discrepancies in the log search results.

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

**Expected execution time:** Approximately 2 minutes.

**Results obtained:**

- All predefined rules applied successfully.
- Syslog entries matched expected firewall events.

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
