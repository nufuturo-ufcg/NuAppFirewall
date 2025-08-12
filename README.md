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

There are no dependencies required to run the tool.  

# Security Concerns

There are no security concerns.

# Installation

Please be advised that the installation described below will block your access to the following browsers: **Firefox** and **Arc**. This restriction can be reverted by uninstalling the application and its extension, as described in the [Uninstallation](#uninstallation) section.

## Run via DMG

1. Download the disk image [_NuAppFirewall2.0.1.dmg_](./NuAppFirewall2.0.1.dmg) in this repository's root directory;
2. Open the disk image;  
3. Drag the _NuAppFirewall.app_ to the _Applications_ folder

![](/docs/images/dmg.png)

4. Create the path where the rules will be stored:  
```bash
sudo mkdir -p "/private/var/root/Library/Group Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application Support/"
```

5. Download the [rules file](./Rules/Demo/rules.json) available in the repository;

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

To run this project via CLI, it is necessary to have a paid Apple Developer Account, as some of the certificates of Apple Developer used in this application are exclusive to the paid version.

1. First, with XCode installed, you also need to install (and keep updated) the Xcode Command Line Tools — normally, when you open the General >> Software Update tab on your Mac, you'll see the option to install/update them if it's still pending.

2. Once that’s done, you can open Xcode directly in the NuAppFirewall project. To do this, from the repository root, navigate to the NuAppFirewall folder (`NuAppFirewall/NuAppFirewall`), and once there,type:

   ```
   open NuAppFirewall.xcodeproj
   ```

3. With XCode open, go to the top utility bar on your Mac and click **Xcode >> Settings...**. In the **Accounts** tab, log in to your Apple Developer account. You can then close this tab.

4. With the project open in XCode, click the folder icon in the sidebar (where the project files are shown). Then, click on the root of the project (the Xcode icon labeled *NuAppFirewall*) — the center panel will display information about the project and its targets. To run the project, you need to sign each target.

   4.1. First, click on a target, and in the horizontal bar just above the 'Project' title, navigate to the **Signing & Capabilities** tab.

   4.2. Under the **Debug** section, enable *Automatically manage signing* — Xcode, logged into your account, should generate the necessary certificate. (Note: Some signatures in NuAppFirewall, such as the sandbox, require the paid Apple Developer version.)

   4.3. Repeat this process for all targets.

5. You will need to change the rules location to match your Apple Developer Team ID's group container.

   5.1. Replace the ID in the rules path with your Developer Team ID:

   ``` bash
   sudo mkdir -p "/private/var/root/Library/Group Containers/[teamID].com.nufuturo.nuappfirewall/Library/Application Support/"
   ```

   5.2. Also replace this ID in the project's **Makefile**, located at the repository root (line 10, in `RULES_DESTINATION`).

6. Move the rules file to the path where the extension will read the rules:

   6.1 Navigate to the project directory:

   ```bash
   cd NuAppFirewall
   ```

   6.2 Move the rules file to the path where the extension will read the rules:

    ```bash
    sudo mv ./Rules/Demo/rules.json /private/var/root/Library/Group\ Containers/[teamID].com.nufuturo.nuappfirewall/Library/Application\ Support/
    ```

7.  Back at the repository root in the terminal (`NuAppFirewall`), run:

   ```bash
   make run
   ```

   Enter your password and grant the necessary permissions for the application. In the first pop-up, click **Open System Settings** and enter your password to enable the extension. In the second pop-up, allow the extension to filter your network.

---

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
sudo mv ./Rules/Demo/rules.json /private/var/root/Library/Group\ Containers/27XB45N6Y5.com.nufuturo.nuappfirewall/Library/Application\ Support/
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

**Execution Steps:**  

1. Run the application;  
2. Open Activity Monitor on macOS;  
3. Search for `com.nufuturo.nuappfirewall.extension`;  
4. CPU and memory information can be found in their respective tabs and columns.  

**Expected execution time:** Approximately 5 minutes of continuous use.  

**Expected resource usage:**  
- CPU: average consumption of 0.72%  
- Memory: average consumption of 10.97 MB 

> **Note:** During the first few seconds after the extension’s activation, spikes in both CPU and memory usage were observed due to the intensive initial processing. Subsequently, both consumptions decreased and remained at low levels during continuous use.  

**Expected outcome:** Confirmation that CPU and memory consumption remain low most of the time, with spikes limited to the initialization phase.

## Claim #2 – Unit Tests Execution

**Objective:** Validate the correctness of the firewall's core functionalities through automated unit tests, ensuring code quality and reliability.

**Execution Steps:**  
   
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
