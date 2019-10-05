# Virtual Grid Engine for Python3 (Py3VGE)

Py3VGE is a port of [VGE](https://github.com/SatoshiITO/VGE) to Python3.

## Requirements

- Python >= 3.6
- MPI implementation like [MPICH](https://www.mpich.org/) or [Open MPI](https://www.open-mpi.org/)
- [MPI for Python (mpi4py)](https://mpi4py.readthedocs.io/en/stable/index.html)


## Installation

``` bash
$ git clone git@github.com:SausageCats/Py3VGE.git
$ cd Py3VGE
$ python3 setup.py install --user
```

## Manual

The manual can be downloaded from the following link:

- [Manual in English](https://github.com/SatoshiITO/VGE/blob/master/VGE_user_manual.pdf)
- [Manual in Japanese](https://github.com/SatoshiITO/VGE/blob/master/VGE_user_manual_ja.pdf)

## Brief Instructions

VGE is a parallel task processing application that is implemented by Python and MPI.
The parallel algorithm is designed based on a master-worker pattern where one MPI process (master) manages tasks and assigns them to other MPI processes (workers) for execution.
When VGE starts up, the master and worker processes start running and wait for any inquiry tasks from the user.
The user can send multiple tasks to VGE using API provided by VGE.
VGE receives them and the master passes each task to idle workers for parallel processing.
After the tasks are completed, a completion notice is send to the user.
The user cannot proceed to the next step until the notification is received.
The VGE API, `vge_task` described later, performs the sequence from sending tasks to receiving the results.
To send and receive them, socket communication is used between user (client) and VGE (server).
The server must be started first because client's tasks cannot be sent without the server being started.

The following video shows the basic use of VGE, including how to start VGE and run a simple command.

![](https://github.com/SausageCats/video/raw/master/Py3VGE/Py3VGE_demo.gif)

Below is a description of the command executed in the video.

### Set configuration options

A configuration file `vge.cfg` is provided to adjust VGE behavior.
For example, changing `verbose` of that file to 1 displays an INFO log.
The default is to display nothing.
In this video, an INFO log is set to display and the socket communication interval is set to a small value such as 1.0.
The modified configuration file must be placed in the current directory or specified using the environment variable `VGE_CONF`.
This file will be loaded by the `vge_init` function described below.

### Start VGE

VGE provides that one MPI process (master) becomes the administrator and controls all other MPI processes (workers).
The application is started by the MPI launcher and `vge` command, such as `mpirun -n 3 vge`.
The n option value determines how many worker processes are used.
In this case, one master process and two worker processes are started up.
This command starts the VGE server and waits for a query from the client.

### Check socket connection

On the client side (bottom of the video), `vge_connect --start` is used to check if the started VGE server can be contacted.
If there is a response like `response from VGE: hello`, it is successful.
Note that this command does not necessarily have to be executed.
This is because a similar command is executed in the `vge_init` function.

### Send tasks to VGE

Now that the communication has been confirmed, execute a simple command on VGE.
Some VGE functions need to be called in Python3.
Here is an example from a video.

``` python
from VGE.vge_init import vge_init
from VGE.vge_task import vge_task
from VGE.vge_finalize import vge_finalize
vge_init()
vge_task("echo TEST${VGE_TASK_ID}\n", 2, "test")
vge_finalize()
```

The `vge_init` function loads a configuration file (vge.cfg) and verifies communication with VGE.
The `vge_task` function sends a command to VGE and waits for the command to complete.

- The first argument specifies a command to be executed on VGE.
Here, an echo command is set.
The `VGE_TASK_ID` environment variable is expanded to a number by VGE internal processing.
For example, if the maximum tasks (the second argument) set to 2, two commands will be generated as follows: `"echo TEST1\n"` and `"echo TEST2\n"`.
Note that `VGE_TASK_ID` is increased by 1 for each task from 1 to the maximum task number.

- The second argument specifies the number of commands to generate (maximum number of tasks).

- The third argument specifies a base name for saving the output of command to a file.

Finally, call the `vge_finalize` function to terminate the communication between VGE and the client.
In the video, these VGE functions are called from the command line using option c in Python3 and two workers are simultaneously processing two tasks in parallel.

### Check the results of command

When the two tasks are complete, VGE outputs the results of the command in the `vge_output` directory in the current directory.
The output file names and its contents are as follows:

``` bash
$ cd ./vge_output
$ ls
test.sh.0  test.sh.0.e0  test.sh.0.o0  test.sh.1  test.sh.1.e1  test.sh.1.o1

$ cat test.sh.0
echo TEST${VGE_TASK_ID}
$ cat test.sh.1
echo TEST${VGE_TASK_ID}

$ cat test.sh.0.o0
TEST1
$ cat test.sh.1.o1
TEST2

$ cat test.sh.0.e0
$ cat test.sh.1.e1
```

In general, the following file names and contents are stored.

- `{basename}.sh.{jobid}`: Command executed
- `{basename}.sh.{jobid}.o.{taskid}`: Standard output of executed command
- `{basename}.sh.{jobid}.e.{taskid}`: Standard error of executed command
<br>The `{basename}` is the value specified in the third argument of `vge_task` function.
<br>The `{jobid}` is a unique number separated by task units starting from 0.
<br>The `{taskid}` is a similar to `{jobid}` but is allocated from 0 each time `vge_task` function is run.

In the video, the grep command is used to check the contents of the file.
Since the standard error file is empty, nothing is displayed on the screen.

### Stop VGE

The VGE server can be stopped with the `vge_connect --stop` command.
In the video, the VGE server in the upper part of the screen has stopped.

### Check task execution results

After stopping, VGE outputs the results of overall task information as csv files to the `vge_output` directory:

- `vge_jobcommands.csv` : Command list
- `vge_worker_result.csv` : Information about which worker processes did what amount of work.
- `vge_joblist.csv` : The detailed information of tasks.

Here are the results in the video:

``` bash
$ cd ./vge_output
$ ls
test.sh.0  test.sh.0.e0  test.sh.0.o0  test.sh.1  test.sh.1.e1  test.sh.1.o1  vge_jobcommands.csv  vge_joblist.csv  vge_worker_result.csv

$ cat vge_jobcommands.csv
command_id,command
0, "echo TEST${VGE_TASK_ID}\n"

$ cat vge_worker_result.csv
worker_rank,job_count,work_time
1,1, 3.51800e-03
2,1, 4.67100e-03

$ cat vge_joblist.csv
jobid,status,unique_jobid,sendvgetime,return_code,max_task,pipeline_pid,pipeline_parent_pid,execjobid,sendtoworker,worker,filename,bulkjob_id,command_id,start_time,finish_time,elapsed_time
0,done,0,2019-10-03 12:35:44.845423,0,2,8847,8847,0,True,2,test.sh.0,0,0,2019-10-03 12:35:44.848213,2019-10-03 12:35:44.852884,0.004671
1,done,0,2019-10-03 12:35:44.845423,0,2,8847,8847,1,True,1,test.sh.1,1,0,2019-10-03 12:35:44.849339,2019-10-03 12:35:44.852857,0.003518
```

The `vge_joblist.csv` file provides many task information including command execution time, command return values etc.
This file can be easily visualized using [columnplot](https://github.com/SausageCats/columnplot).
Please refer to it if you are interested.

Although not covered here, the manual includes detailed VGE design, how to create script files for multitasking, restart capability, and detailed descriptions of VGE output files, command options, and configuration files.
