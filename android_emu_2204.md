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

```
mkdir -p /usr/lib/android-sdk
cd /usr/lib/android-sdk
```

Download & extract platformtools and cmdlinetools

```
wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
wget https://dl.google.com/android/repository/platform-tools_r34.0.5-linux.zip
unzip commandlinetools-linux-10406996_latest.zip
unzip platform-tools_r34.0.5-linux.zip
```

Fix cmdlinetools directory structure

```
mv cmdline-tools latest
mkdir cmdline-tools
mv latest cmdline-tools
```

