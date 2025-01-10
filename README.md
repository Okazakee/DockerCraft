
<img alt="logo" width='30%' align="right" src="https://github.com/Okazakee/mcserver-lazymc-docker/blob/master/bg.png" />


## DockerCraft

This is a Linux Docker image for creating Minecraft servers with [`lazymc`](https://github.com/timvisee/lazymc).

**Lazymc** is a utility that puts your Minecraft server to rest when idle and wakes it up when players try to connect.
This allows the server to not waste resources if nobody is connected.

This image provides a basic Minecraft server using one of the supported providers. All customizations are left to the user.

# Supported server providers:
### [Vanilla](https://www.minecraft.net/) | [Paper](https://papermc.io/) | [Purpur](https://purpurmc.org/) | [Fabric](https://fabricmc.net/) | [Forge](https://forums.minecraftforge.net/)
Want more? Let me know in the [discussions](https://github.com/Okazakee/mcserver-lazymc-docker/discussions).

# Usage
It is assumed that the user has already acquired a working Docker installation. If that is not the case, [go do that](https://www.docker.com/get-started/) and come back here when you're done.

`Note that running said command or docker compose indicates agreement to the Minecraft EULA.`

## Using docker run:
```bash
sudo docker run -p 25565:25565 -e okazakee/mcserver-lazymc-docker
```
While this command will work just fine in many cases, it is only the bare minimum required to start a functional server and can be vastly improved by specifying more options/envs.

## Using docker compose:

```yaml
version: '3.3'
services:
    mcserver-lazymc-docker:
        ports:
            - '<your-port>:25565'
        container_name: <your-container-name>
        environment:
            - SERVER_PROVIDER=<your-server-provider>
            - LAZYMC_VERSION=<your-lazymc-version>
            - MC_VERSION=<your-mc-version>
            - SERVER_BUILD=<your-server-build>
            - MC_RAM=<your-ram-budget>
            - JAVA_OPTS=<your-java-arguments>
        volumes:
            - '<your-volume-or-path>:/mcserver'
        image: okazakee/mcserver-lazymc-docker:<latest/staging>
```

## Options
There are several command line options that users may want to specify when utilizing this image. These options are listed below with some brief explanation. An example will be provided with each. In the example, the part that the user can change will be surrounded by angle brackets (`< >`). Remember to *remove the angle brackets* before running the command.
- Port
  - This option must be specified. Use port `25565` if you don't know what this is.
  - Set this to the port number that the server will be accessed from.
  - If RCON is to be used, this option must be specified a second time for port `25575`.
  - `-p <12345>:25565`
  - `-p <12345>:25565 -p <6789>:25575`
- Volume
  - Set this to a name for the server's Docker volume (defaults to randomized gibberish).
  - Alternatively, set this to a path to a folder on your computer.
  - `-v <my_volume_name>:/mcserver`
  - `-v </path/to/files>:/mcserver`
- Detached
  - Include this to make the container independent from the current command line.
  - `-d`
- Terminal/Console
  - Include these flags if you want access to the server's command line via `docker attach`.
  - These flags can be specified separately or as one option.
  - `-t` and `-i` in any order
  - `-ti` or `-it`
- Restart Policy
  - If you include this, the server will automatically restart if it crashes.
  - Stopping the server from its console will still stop the container.
  - It is highly recommended to only stop the server from its console (not via Docker).
  - `--restart on-failure`
- Name
  - Set this to a name for the container (defaults to a couple of random words).
  - `--name "<my-container-name>"`

There is one more command line option, but it is a bit special and deserves its own section.
### Environment Variables
Environment variables are options that are specified in the format `-e <NAME>="<VALUE>"` where `<NAME>` is the name of the environment variable and `<VALUE>` is the value that the environment variable is being set to. Please note that setting an evironment variable with no value leaves the default value, which you can look up below.

[comment]: <> (Mandatory `ENV` fields will have a `*` after their name.)

This image has seven environment variables:
- Server Provider
  - **Name:** `SERVER_PROVIDER`
  - Set this to the server [Provider](#supported-server-providers) you want to use.
  - Default value: `purpur`.
  - `-e SERVER_PROVIDER="<paper>"`
- Lazymc Version
  - **Name:** `LAZYMC_VERSION`
  - Set this to the version of Lazymc you want to use or disable it if you don't need it.
  - Avaliable values are: `latest`, `custom-ver` or `disabled`.
  - Default value: `latest`.
  - `-e LAZYMC_VERSION="<latest>"`
- Minecraft Version
  - **Name:** `MC_VERSION`
  - Set this to the Minecraft version that the server should support.
  - Note: there must be a [Provider](#supported-server-providers) release for the specified version of Minecraft.
  - Default value: `latest`.
  - Changing this on an existing server will change the version *without wiping the server*.
  - `-e MC_VERSION="<latest>"`
- Server Build
  - **Name:** `SERVER_BUILD`
  - Set this to the number of the [Provider](#supported-server-providers) build that the server should use (**not the Minecraft version**).
  - Default value: `latest`.
  - Changing this on an existing server will change the version *without wiping the server*.
  - `-e SERVER_BUILD="<latest>"`
- RAM
  - **Name:** `MC_RAM`
  - Set this to the amount of RAM the server can use.
  - Must be formatted as a number followed by `M` for "Megabytes" or `G` for "Gigabytes".
  - If this is not set, Java allocates its own RAM based on total system/container RAM.
  - `-e MC_RAM="<4G>"`
- Java options
  - **Name:** `JAVA_OPTS`
  - **ADVANCED USERS ONLY**
  - Set to any additional Java command line options that you would like to include.
  - By default, this environment variable is set to the empty string.
  - `-e JAVA_OPTS="<-XX:+UseConcMarkSweepGC -XX:+UseParNewGC>"`
- Custom Run command
  - **Name:** `RUN_COMMAND`
  - **ADVANCED USERS ONLY**
  - Set to the name of the custom server jar you want to use.
  - also allows pointing to a scrpt file, this reqires the full path to the file.
  - For more information, see [Lazymc's documentation](https://github.com/timvisee/lazymc/blob/master/docs/command-bash.md).
  - By default, this environment variable is set to the empty string.
  - `-e RUN_COMMAND="<custom.jar>"` or `-e RUN_COMMAND="/mcserver/<custom.sh>"`

## Further Setup
From this point, the server should be configured in the same way as any other Minecraft server. The server's files, including `server.properties`, can be found in the volume that was specified earlier. The port that was specified earlier will probably need to be forwarded as well. For details on how to do this and other such configuration, Google it, because it works the same as any other Minecraft server.
### Suggested repo for optimizing your settings: [YouHaveTrouble/minecraft-optimization](https://github.com/YouHaveTrouble/minecraft-optimization)

## Thanks to:
- [ServerJars](serverjars.com) - They're API helped me a lot massively reducing my codebase size.
- [Timvisee](https://github.com/timvisee) - Lead developer of Lazymc.
- [Crbanman's Repo](https://github.com/crbanman/papermc-lazymc-docker) - Original fork on which this project is based of.
- [Contributors](https://github.com/Okazakee/mcserver-lazymc-docker/graphs/contributors) - Thanks to everybody who has or will help with this project.

## Technical
This project *does **NOT** redistribute the Minecraft server files*.

**PLEASE NOTE:** This is an unofficial project. I did not create any of the supported [Providers](#supported-server-providers).

## Project Pages
- [GitHub page](https://github.com/okazakee/mcserver-lazymc-docker).
- [Docker Hub page](https://hub.docker.com/r/okazakee/mcserver-lazymc-docker).
