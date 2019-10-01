#!/bin/bash

instdir=$(cd ..;pwd)/public
export PYTHONPATH=$instdir/lib/python3.6/site-packages:${PYTHONPATH:-}
export PATH=$instdir/bin:$PATH

cd ..
python3 setup.py install --prefix=$instdir

vge --version
