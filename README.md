# openISBT_analyser

[openISBT](https://github.com/martingrambow/openISBT "openISBT") is a Benchmark tool to test REST service based on its openAPI3.0 interface description.

The openISBT_analyser is a bash programm to collect log data produced by openISBT, clean up this data and measure coverage criteria as described in my thesis.

## Quick start

```console
foo@bar:~# apt install git
foo@bar:~# git clone https://github.com/AmitJerochim/openISBT_analyser.git
foo@bar:~# cd openISBT_analyser
foo@bar:~/openISBT_analyser# chmod +x *.sh
```
open main.sh with an editor of your choice:
`foo@bar:~/openISBT_analyser#  vi main.sh`

and set the following variables depending on your own directory structure:
```console
#!/bin/bash

#setup the path for a directory containing openAPI 3.0 files in json format.
#don't use slash at the end of the file: ../oasFiles instead of ../oasFiles/
OAS_FILES=../openapi-data/oasFilesJson

#setup the path for a directory where your Logging files should be saved
#don't use slash at the end of the file: ../logFiles instead of ../logFiles/
LOG_FILES_DIRECTORY=./log_files

#setup the path for a pattern configuration file
PATTERN_CONFIG_FILE=../openISBT/resources/patternConfigs/amitExperiment.json

#setup the path for openISBT root directory
OPENISBT_ROOT_DIRECTORY=../openISBT

```

you can run the script using:
`foo@bar:~/openISBT_analyser# ./main.sh >result.log`



## Structure
The openISBT_analyser contains five bash script files.
-  run_openisbt.sh
-  clean_data.sh
-  helper_functions.sh
- analyse_apis.sh
- main.sh

The main.sh script just states directory variables and runs the other scripts in a sequential order which could be changed.


##  Usage

##### Notice, each script except the main.sh supports usage manual. if run with -h, or --help option.

The openISBT_analyser requires the scripts to be run in the following order:
- first, logfiles should be collected using the openisbt.sh script.
- second, the data has to be cleaned up using the clean_data.sh
- third, we can run two measurements using the analyse_apis.sh

##### run_openisbt.sh
to collect log files first run this script
It needs the folloging options to run successfully.

```console
foo@bar:~/openISBT_analyser# ./run_openisbt.sh --help
Usage:
	 -h, --help                                           --> display usage information and exits
	 To run this script all options below are required:
	 --log-files-directory                      --> specify a directory containing logfiles
	 --oas-files-directory                     --> specify a directory containing oas Files
	 --openisbt-root-directory          --> specify the root directory of the openISBT project
	 --pattern-config-file                     --> specify a patten configuration file
```
##### clean_data.sh
clean data removes unwanted files which have the wrong format or implement toy apis. It is only possible to run it with one cleaning method as used in main.sh. removing corrupt data using the --remove-corrupt-files option should be done first.

```console
foo@bar:~/openISBT_analyser#  ./clean_data.sh -h
Usage:
	 -h, --help 	 	 --> display usage information and exits
	 --directory	 	 --> specify a directory containing logfiles(always required)
	 --remove-corrupt-files	 --> data cleaning method to run
	 --remove-oauth-apis	 --> data cleaning method to run
	 --remove-petstore-apis	 --> data cleaning method to run
	 --remove-iot-apis	 --> data cleaning method to run
```
##### analyse_apis.sh
clean data removes unwanted files which have the wrong format or implement toy apis. It is only possible to run it with one cleaning method as used in main.sh. removing corrupt data using the --remove-corrupt-files option should be done first.

```console
foo@bar:~/openISBT_analyser# ./analyse_apis.sh --help
Usage:
	 -h, --help                                                      --> display usage information and exits
	 --directory                                                   --> specify a directory containing logfiles(always required)                                  
	 --determine-full-supported-apis       --> analyse method to run
	 --determine-supported-operations  --> analyse method to run
```
##### helper_functions.sh
This file is used by the other scripts and shouldn't be used. Nevertheless it is possible to use the -h, or --help option to take a deeper look at it.
