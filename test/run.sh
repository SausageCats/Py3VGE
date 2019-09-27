#$ -S /bin/bash
#$ -pe mpi 3-3
#$ -cwd
#$ -e ./log
#$ -o ./log
#$ -l s_vmem=8G,mem_req=8G,os7

#
# public path
# (mpi and python)
#
PUBLICHOME=$HOME/work/py3VGE/public
MPIHOME=$PUBLICHOME/mpich_3.2
export PATH=$MPIHOME/bin:$PATH
export LD_LIBRARY_PATH=$MPIHOME/lib:${LD_LIBRARY_PATH:-}
export LD_RUN_PATH=$MPIHOME/lib:${LD_RUN_PATH:-}
#
export PATH=$PUBLICHOME/bin:$PATH
export PYTHONPATH=$PUBLICHOME/lib/python3.6/site-packages:${PYTHONPATH:-}


#
# configs
#
#export VGE_CONF=$HOME


#
# remove and create directory
#
[[ -d log ]] && rm -rf log
[[ -d vge_output ]] && rm -rf vge_output
mkdir log


#
# clean
#
#mpiexec -n 3 cleanvge --verbose 0 &>log/cleanvge


#
# start VGE up
#
mpiexec -n 3 vge &>log/vge &


#
# wait for VGE to run
#
vge_connect --start &>log/start


#
# run client
#
time ./client &>log/client


#
# wait for vge_test(s) to finish
#
vge_connect --wait --monitor vge_test --wait_maxtime 300 --sleep &>log/wait


#
# stop VGE
#
vge_connect --stop --force --target vge_test --stop_maxtime 300 &>log/stop
