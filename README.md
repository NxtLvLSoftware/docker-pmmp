# docker-pmmp
Hosts the files used to build [nxtlvlsoftware/pmmp](https://hub.docker.com/repository/docker/nxtlvlsoftware/pmmp) & [nxtlvlsoftware/pmmp-phpstan](https://hub.docker.com/repository/docker/nxtlvlsoftware/pmmp-phpstan) docker images.

## About
This repository contains the source for building a minimal docker image for running a [pocketmine](https://github.com/pmmp/PocketMine-MP)
server and an image for running static analysis on plugin source code using [phpstan](https://github.com/phpstan/phpstan).

If you're interested in building your own images, want to understand how everything works or just feel like reading
something, you can take a look at the documentation for the pocketmine image [here](pocketmine-mp/README.md) and the
phpstan image [here](phpstan/README.md).

## Index
* [What is docker?](#what-the-heck-is-docker)
* [Running PocketMine](#running-pocketmine)
    * [Quick start](#quick-start)
        * [Required volumes](#required-volumes)
        * [Mounting the volumes](#mounting-the-volumes)
        * [Setting file permissions](#setting-file-permissions)
        * [Starting the server](#starting-the-server)
        * [Changing the port](#changing-the-port)
    * [Run the server in the background](#run-the-server-in-the-background)
        * [Reattaching to a server in the background](#reattaching-to-a-server-in-the-background)
        * [Viewing background server logs](#viewing-background-server-logs)
    * [Full Documentation](pocketmine-mp/README.md)
* [Running phpstan](#running-phpstan-code-analysis)
    * [Quick start](#quick-start-phpstan)
        * [Required volume (source directory)](#required-volume)
        * [Running the analysis](#running-the-analysis)
            * [Resolving plugin dependencies](#resolving-plugin-dependencies)
            * [Resolving composer dependencies](#resolving-composer-dependencies)
        * [Custom phpstan configuration](#custom-phpstan-configuration)
            * [Autoloading pocketmine](#autoloading-pocketmine)
            * [Default configuration](#default-configuration)
    

## What the heck is docker?
Docker lets you install software more easily by "copying the whole machine over".
To use Docker, you must be on a Linux/MacOS machine.
(Docker also works on Windows, but trying to run Linux containers on Windows usually creates more problems than it solves.)

To install Docker, refer to the [official Docker docs](https://docs.docker.com/install/).

## Running PocketMine
There are pre-built images avalible on [dockerhub](#link-coming) that you can install with the steps below or you may
build your own images from a specific git tag by following the directions [here]().

### Quick start
__You do NOT need to clone this repo to install pocketmine via docker!__

Although this is a quick start guide, you will still need to know how to run commands on a Linux/MacOS machine and
already have Docker installed.

(If you prefer a more technical reference, there is [in-depth documentation](pocketmine-mp/README.md) available with the
full build instructions.)
 
#### Required volumes
The pocketmine image uses two volumes for storing your servers data, `/data` (where things like server.properties, plugin
data, player data, etc. is stored) and `/plugins` where your .phar files are stored.

#### Mounting the volumes
If you want to use existing directories or don't want the server data or plugins stored in the container you can mount
the directories from your host machine. First, make sure the directories `data` and/or `plugins` exist (you can create
them in your current working directory with `mkdir data plugins` & they can have any name you like).

#### Setting file permissions
Set the owner of these directories to user of UID `1000`. Docker containers identify file owners using the UID, so if your
current user is coincidentally also UID 1000 (you can check this with `echo $UID`), this operation might do nothing.
Otherwise, you might need root access to change the owner of a directory:

```bash
sudo chown -R 1000:1000 data plugins
```

#### Starting the server
You can now start the server with the following command:

```bash
docker run -it -v $PWD/data:/data -v $PWD/plugins:/plugins nxtlvlsoftware/pmmp:stable
```

If your directories aren't named `data` or `plugins` you can replace `$PWD/data` and/or `$PWD/plugins` with the full/absolute
path to your directories:

```bash
docker run -it -v /home/user/server-1/data:/data -v /home/user/server-1/plugins:/plugins nxtlvlsoftware/pmmp:stable
```

#### Changing the port
Do NOT change the server port in server.properties. If you want to open the server on another port (e.g. `12345` instead),
start the server with the following command:

```bash
docker run -it -p 12345:19132 -v $PWD/data:/data -v $PWD/plugins:/plugins nxtlvlsoftware/pmmp:stable
```
(The second number is ALWAYS `19132`)
 
### Run the server in the background
To run the server in the background, simply change `-it` to `-itd` in the commands above. This will run the server in
the background even if you close the console. (No need to `screen`/`tmux` anymore!)

When you run this command, it will display the container name that runs the server, e.g. `admiring_boyd`, `bold_kilby`,
or other random names.

#### Reattaching to a server in the background
To open the console of a background server (reattach), run the following command:

```
docker attach container_name
```

To leave the console again, just press `Ctrl p` `Ctrl q`.

#### Viewing background server logs
Alternatively, you can use `docker logs container_name` to view the console output without getting stuck in the console.
 
## Running phpstan (code analysis)
You can also choose to use a pre-built image from [dockerhub]() for running phpstan but if you are targetting a specific
tag or fork of pocketmine you will need to build your own image following the [provided instructions](#coming-soon).

### Quick start (phpstan)
__You do NOT need to clone this repo to install the pocketmine phpstan code analysis image!__

Although this is a quick start guide, you still need to know how to run commands on a Linux/MacOS machine and already
have Docker installed.

(If you prefer a more technical reference, there is [in-depth documentation](phpstan/README.md) section available with
the full build instructions.)

#### Required volume
The phpstan image uses a single volume for running analysis on your code, this is usually the directory where your `src`
folder and `plugin.yml` file are located. Make sure to create the directory or have your plugins source directory available
(easiest if you `cd` to it/its your current working directory).

#### Running the analysis
Now you can run phpstan analysis with the following command:

```
docker run -it -v $PWD:/source nxtlvlsoftware/pmmp-phpstan:stable
```
 
This will run php stan with the [default configuration](phpstan/phpstan.neon) provided with image on the plugin in your
current working directory. If your plugin source is in another directory you can replace `$PWD` with the full/absolute path
to your plugins source folder:

```
docker run -it -v /home/dev/my-plugin:/source nxtlvlsoftware/pmmp-phpstan:stable
```

#### Resolving plugin dependencies
If your plugin lists dependencies in its plugin.yml (`depend`, `softdepend` or `loadbefore`) the container will try and
find the latest versions of each plugin listed on poggit and download them into `/deps` if found. The default phpstan
configuration will automatically autoload all files under `/deps` so the analysis is aware of your plugins dependencies.

#### Resolving composer dependencies
If a `composer.json` file is present in your plugins root directory (along side `plugin.yml`) the container will attempt
to install the dependencies. The default phpstan configuration does not include the autoloader generated by the `composer install`
command so you will need to provide your own config.

#### Custom phpstan configuration
If the default phpstan configuration is not sufficient you can specify the path to your own `phpstan.neon` file as an
environment variable if it exists in your plugins source folder:

```
docker run -it -v $PWD:/source -e PHPSTAN_CONFIG=/source/phpstan.neon.dist nxtlvlsoftware/pmmp-phpstan:stable
```

Given your plugins directory structure looks something like the following:
```text
my-plugin
  > src
  > plugin.yml
  > phpstan.neon.dist
```

This will tell php stan to look for the `phpstan.neon.dist` file provided by your `source` directory (this should be the
root directory that includes /src, /plugin.yml, etc). In the container your plugins root directory will be mounted under
`/source` so you need to provide the path to your configuration file relative to the path you mount to `/source`.

#### Autoloading pocketmine
If you provide your own phpstan configuration you will need to tell phpstan to autoload the pocketmine classes or the
analysis will fail. The easiest way to achieve this is by telling phpstan about the composer generated autoloader in the phar:

```neon
autoload_files:
	- phar:///pocketmine/PocketMine-MP.phar/vendor/autoload.php
```

#### Default configuration
If you run into issues configuring phpstan you may find it helpful to take a look at the [default configuration](phpstan/phpstan.neon)
provided.