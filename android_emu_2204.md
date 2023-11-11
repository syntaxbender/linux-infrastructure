# Android Emulator without Android Studio on Ubuntu 22.04
## Requirements
- [JDK Latest](https://github.com/syntaxbender/linux-fundamentals/blob/main/jdk_latest_2204.md)
- Commandline Tools
- Platform Tools

## Downloads
- [Download Commandline Tools from here](https://developer.android.com/studio#command-line-tools-only)
- [Download Platform Tools from here](https://developer.android.com/tools/releases/platform-tools)

## Installation

Create installation directory

```bash
sudo mkdir -p /usr/lib/android-sdk
cd /usr/lib/android-sdk
```

Download & extract platformtools and cmdlinetools

```bash
sudo wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
sudo wget https://dl.google.com/android/repository/platform-tools_r34.0.5-linux.zip
sudo unzip commandlinetools-linux-10406996_latest.zip
sudo unzip platform-tools_r34.0.5-linux.zip
```

Fix cmdlinetools directory structure

```bash
sudo mv cmdline-tools latest
sudo mkdir cmdline-tools
sudo mv latest cmdline-tools
```

We need to create a usergroup for android-sdk directory, change directory owners and permissions, finally add our user to this group.

```bash
sudo groupadd androidsdk
sudo usermod -a -G androidsdk syntaxbender
sudo chown -R root:androidsdk /usr/lib/android-sdk/
sudo chmod -R 775 /usr/lib/android-sdk/
sudo nano /etc/bash.bashrc
```

Add directories as environment variable to global bashrc file

```bash
export ANDROID_HOME="/usr/lib/android-sdk"
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
```

Let's reboot and check is adb, fastboot, sdkmanager working. <ins>**Emulator will works after sdkmanager package installation process.**</ins>

```
$ adb --version

Android Debug Bridge version 1.0.41
Version 34.0.5-10900879
Installed as /usr/lib/android-sdk/platform-tools/adb
Running on Linux 6.3.3-060303-generic (x86_64)
```
```
$ sdkmanager --version

11.0
```

```
$ fastboot --version

fastboot version 34.0.5-10900879
Installed as /usr/lib/android-sdk/platform-tools/fastboot
```

```
$ emulator --version

INFO    | Android emulator version 32.1.15.0 (build_id 10696886) (CL:N/A)
ERROR   | No AVD specified. Use '@foo' or '-avd foo' to launch a virtual device named 'foo'
```

If everythings is okay, we can continue with sdkmanager package installations.

```
# Update repo cache
$ sdkmanager --update

# List packages
$ sdkmanager --list
```

We need to install this packages; We can choose <ins>**XX**</ins> previous version before the last version.

```
platforms;android-XX
system-images;android-XX;google_apis_playstore;x86_64
build-tools;XX
```

Let's install this packages.

```
sdkmanager "platforms;android-33"
sdkmanager "system-images;android-33;google_apis_playstore;x86_64"
sdkmanager "build-tools;33.0.2"
```

Installed packages looks like this.
```
$ syntaxbender@minimal:~$ sdkmanager --list

[=======================================] 100% Computing updates...             
Installed packages:
  Path                                                  | Version | Description                                | Location                                             
  -------                                               | ------- | -------                                    | -------                                              
  build-tools;33.0.2                                    | 33.0.2  | Android SDK Build-Tools 33.0.2             | build-tools/33.0.2                                   
  emulator                                              | 32.1.15 | Android Emulator                           | emulator                                             
  platform-tools                                        | 34.0.5  | Android SDK Platform-Tools 34.0.5          | platform-tools                                       
  platforms;android-33                                  | 3       | Android SDK Platform 33                    | platforms/android-33                                 
  system-images;android-33;google_apis_playstore;x86_64 | 7       | Google Play Intel x86_64 Atom System Image | system-images/android-33/google_apis_playstore/x86_64

```

We installed all the packages we need. Lets create an emulator

```
$TEMP_VAR_AVD_NAME=virtandro13; \
avdmanager create avd -n $TEMP_VAR_AVD_NAME -k "system-images;android-33;google_apis_playstore;x86_64"

```

Check emulator is added successfully.

```
$ avdmanager list avd

Available Android Virtual Devices:
    Name: virtand13
    Path: /home/syntaxbender/.android/avd/virtand13.avd
  Target: Google Play (Google Inc.)
          Based on: Android 13.0 ("Tiramisu") Tag/ABI: google_apis_playstore/x86_64
  Sdcard: 512 MB

```

Let's run emulator

```
emulator -avd virtand13
```

If freeze your emulator you can delete your snapshot folder.

```
rm -rf ~/.android/avd/virtand13.avd/snapshots/
```
