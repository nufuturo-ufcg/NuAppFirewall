# Running via CLI

**Note on Apple Developer:** Running via the command line **requires a paid Apple Developer account**. The DMG/GUI route often works out of the box because it ships as a prebuilt bundle. Note that the CLI flow requires you to build and sign targets using certificates/entitlements available only to paid accounts. With a free account you may do limited GUI testing, but the CLI flow usually will not work as expected.

**Important:** The initial setup for running via CLI involves steps required by Apple (Xcode configuration, signing targets, etc.). These steps are only necessary the first time. After the first setup, you only need to follow the uninstall process described in the main README, run `make run`, and optionally update the rules with `make install-rules-dev`.

Some of the configuration steps have been automated in scripts to make the process easier, but a few steps—like signing targets in Xcode—still need to be completed via the interface.

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

5. First-time setup (only once) – at the root of the project, configure Xcode and accept the license agreements

   ```bash
   make setup-xcode
   ```
   
6. At the root of the project, run the Makefile target to install the rules (this will prompt for your Developer Team ID if needed):

   ``` bash
   make install-rules-dev RULES=./Rules/Demo/rules.json
   ```
    
7.  After the command completes, you can run the project:

   ```bash
   make run
   ```

   Enter your password and grant the necessary permissions for the application. In the first pop-up, click **Open System Settings** and enter your password to enable the extension. In the second pop-up, allow the extension to filter your network.
