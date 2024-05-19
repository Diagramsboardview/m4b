# m4b
M4B was created to test the battery performance on MacBooks

# Supported versions
Ventura macOS 13.3.1 (a) (22E772610a)

Sonoma macOS 14.3.1 (23D60)

# Before execute script
To measure battery consumption, please close all unnecessary programs on your MacBook and maximize the brightness

Please deactivate the 'turn off display when battery power' feature in power management, and disable the screensaver

# Features
This script provides the following functionalities:

1. Online Record
 -> Online logging allows you to log battery data online. This feature is available only to members registered on https://diagramsboardview.com.

# The information collected by the script includes
M4B collects the following information for various purposes.

1. Device Serial Number
2. Device Architecture
3. Software Version
4. Battery Design Capacity
5. Battery Serial Number
6. Battery Max Capacity
7. Battery Cycle
8. Battery Voltage
9. Network IP Address

You can disable this collection by referring to the script's help documentation.

# How to use
Below script is a Bash script. After downloading, you need to grant execution permissions using the following command in a suitable location

Please ensure that the battery is at __100%__ before running the script. If the script prompts you to unplug the charger after it starts, you can proceed by unplugging it at that time

You can conduct the test even if the battery is not at 100%, but it is recommended to perform it at 100%.

Open the terminal, navigate to the location where the script is stored, and grant execution permissions.
```
  ~% cd ~/Documents/
  ~% chmod u+x m4b.sh
```
You can run the script as shown below, and the battery logs will be generated in CSV format in the same folder as the script.
```
  ~% bash m4b.sh
```
You can view detailed options by entering -h or --help.
```
~% bash m4b.sh -h
        -h | --help : Display script options.


        -n | --network : Activate network mode. If this option is not used, it will default to the network option during execution.
        example) bash m4b.sh -n on
        example) bash m4b.sh --network on


        -k | --key : Record battery consumption on the Diagramsboardview.com account along with the CSV file. If this option is not used, it will not be activated by default, and the data will be recorded in a local CSV file.
        example) bash m4b.sh -k <my API key>
        example) bash m4b.sh --key <my API key>


        -r | --online-record : Activate online logging of battery consumption. This option must be used with the -k or --key option.
        example) bash m4b.sh -r on -k <my API key>
        example) bash m4b.sh --online-record on --key <my API key>


        -t | --threads-mode : To accelerate battery consumption, the script artificially creates 100 unnecessary processes.
        example) bash m4b.sh -t yes
        example) bash m4b.sh --threads-mode yes


        -c | --clear : Terminate unnecessary processes, except those required for OS operation, to measure battery consumption.
        example) bash m4b.sh -c
        example) bash m4b.sh --clear
```
