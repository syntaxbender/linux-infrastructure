# linux-fundamentals

## Install JDK (Applied on 22.04)
### Download Binary Files
- Download from https://jdk.java.net/21/

```
sudo mkdir -p /usr/lib/jvm/
cd /usr/lib/jvm/
wget https://download.java.net/java/GA/jdk21.0.1/415e3f918a1f4062a0074a2794853d0d/12/GPL/openjdk-21.0.1_linux-x64_bin.tar.gz
sudo tar xzvf openjdk-21.0.1_linux-x64_bin.tar.gz
nano /etc/profile
```

Edit /etc/profile file add this lines

```
export JAVA_HOME="/usr/lib/jvm/jdk-21.0.1"
export PATH=$JAVA_HOME/bin:$PATH
```

After editing, <ins>**log out and log in again**</ins>.

Check is java home correct.

```
$ echo $JAVA_HOME
> /usr/lib/jvm/jdk-21.0.1
```

Install & update java defaults config 

```
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-21.0.1/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk-21.0.1/bin/javac" 1
sudo update-alternatives --config javac
sudo update-alternatives --config java
```

Check java versionn

```
$ java -version
> openjdk version "21.0.1" 2023-10-17
> OpenJDK Runtime Environment (build 21.0.1+12-29)
> OpenJDK 64-Bit Server VM (build 21.0.1+12-29, mixed mode, sharing)
```

## Remove JDK

```
sudo update-alternatives --remove javac /usr/lib/jvm/jdk-21.0.1/bin/javac
sudo update-alternatives --remove java /usr/lib/jvm/jdk-21.0.1/bin/java
sudo nano /etc/profile
```

Remove lines from /etc/profile

```
export JAVA_HOME="/usr/lib/jvm/jdk-21.0.1"
export PATH=$JAVA_HOME/bin:$PATH
```

Delete installation directory

```
rm -rf /usr/lib/jvm/jdk-21.0.1/
```

