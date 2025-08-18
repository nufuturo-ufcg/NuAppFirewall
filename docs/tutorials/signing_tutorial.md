# Running via CLI

**Note on Apple Developer:** Running via the command line **requires a paid Apple Developer account**. The DMG/GUI route often works out of the box because it ships as a prebuilt bundle. Note that the CLI flow requires you to build and sign targets using certificates/entitlements available only to paid accounts. With a free account you may do limited GUI testing, but the CLI flow usually will not work as expected.

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

   4.2. Under the **Debug** section, enable *Automatically manage signing* — Xcode, logged into your account, should generate the necessary certificate. (Note: Some signatures in NuAppFirewall, such as the network extension, require the paid Apple Developer version.)

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

5. Before running the project, run the Xcode setup target to prepare signing and other Xcode-specific configuration:
```
make setup-xcode
```

6. Build and run the project in the terminal:
```
make run
```

Grant the requested permission.