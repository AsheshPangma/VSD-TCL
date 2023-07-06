# VlSI SYSTEM DESIGN - TCL WORKSHOP

This reopository provides infomation on comprehensive 5 days TCL workshop by VLSI System Design where I learned TCL scripting techniques form basics to advanced for design and synthesis.

## Introduction

TCL stands for Tool Command Language and was created by John Ousterhout in the late 1980s. It is a dynamic scripting language and used commonly in software development, system admim, embedded system as well as in EDA(Electronic Design Automation). TCL is popular because it is simple to use, flexible and it can be integrated easily with other programming languages and tools. One of the main advantage of TCL is scripting that it greatly helps to automate tasks, build application, execute commands and manipulate data.

# Content

- [Day-1](#Day-1)
- [Day-2](#Day-2)
- [Day-3](#Day-3)
- [Day-4](#Day-4)
- [Day-5](#Day-5)

# Day-1

## Create command 'vsdsynth' 

We need to create a command 'vsdsynth' that takes .csv file as input from UNIX shell to TCL script. The command can be created using the following steps:
1. Let the system know that its a UNIX script

` #! /bin/tcsh -f `

2. Creating logo

Create a `vsdsynth` file using the command `vim vsdsynth`. Then, create a banner as shown below:
```
echo ""
echo "---------------------------------------------------- TCL Workshop done by Ashesh Pangma -------------------------------------------------------"
echo ""
echo "  ***                 ***   ********    *********         **********   ****       ****   ******       ****  ******************  ****      **** "
echo "   ***               ***  ************  ***********     *************   ****     ****    ********     ****  ******************  ****      **** "
echo "    ***             ***   *******       ***      ****   ******            **** *****     *********    ****         ****         ****      **** "
echo "     ***           ***    *****         ***       ***   *****              ********      ****  ****   ****         ****         ****      **** "
echo "      ***         ***     **********    ***       ***   ***********         ******       ****   ****  ****         ****         ************** "
echo "       ***       ***      ************  ***       ***   *************       ******       ****    **** ****         ****         ************** "
echo "        ***     ***             ******  ***       ***          ******       ******       ****     ********         ****         ****      **** "
echo "         ***   ***               *****  ***      ***            *****       ******       ****      *******         ****         ****      **** "
echo "          *** ***        ************   **********      *************       ******       ****       ******         ****         ****      **** "
echo "           *****           ********     *********         *********         ******       ****        *****         ****         ****      **** "
echo ""
echo "			An unique User Interface (UI) that will take RTL netlist & SDC constraints as an input and will generate "
echo "			synthesized netlist & pre-layout timing report as an output. It uses Yosys open-source tool for synthesis"
echo "						and Opentimer to generate pre-layout timing reports."
echo ""
echo "					Developed and Maintained by VLSI System Design Corporation Pvt. Ltd."
echo "					For any queries and bugs, please drop a main to Kunalpghosh@gmail.com"
echo ""
echo "						******** A vlsisystemdesign.com initiative ********"
echo ""
```

You can run the command by typing the following command in the prompt. NOTE: The file should be made executable by using the command `chmod -R 777 vsdsynth`

`./vsdsynth`



3. There are three general cases. 

I. The script takes an input argument which is cvs file. So, we need to check if the user has provided an argument or not. 
* The user does not provide a file or an argument
![](images/1_1.1.png)

* If an argument/file is provided then we need to check if it is correct cvs file or not.

![](images/1_1.2.png)

* If the user enters `-help` as argument

![](images/1_1.3.png)

4. Finally, we need to source the Tcl script by passing the required csv file as
```
tclsh vsdsynth.tcl $argv[1]
```

# Day-2

## Create Variables
First, the csv file is converted into matrix and the variables are created. 

![](images/2_2.1.png)

## Checking if the files and directories exists or not.

After the variables are created, we check if the required directory and file exists within the specified path or not. This can be seen in the following picture.

![](images/2_2.2.png)

In case files are not present or found within specified path then we specify an error and stop the execution.

## Convert constraints.csv file into matrix object

Further, complex matrix processing is done to constraints.csv file to obtain various necessary informations as follows:

![](images/2_2.3.png)


# Day-3

The main task for the third day is to read the provided constraints.csv file and generate a SDC file which is induatry standard format. We write TCL script to read the clock constraints as well as input constraints from the constraints.csv file and generate SDC file. 
We also had to identify bussed and non-bussed input ports before generating SDC file. For bussed ports, we add an `*` at the end of the port. The following screenshot shows that our script ran successfully.

![](images/2_3.1.png)

Here, we can differentiate the bussed and non-bussed ports.
![](images/2_3.2.png)

The following snipet shows the generated SDC file. We can see that the multi-bit ports has `*` at the end.

![](images/3_3.3.png)

The nexe step includes the processing of the constraint.csv file for the output constraints.

# Day-4
# Day-5

