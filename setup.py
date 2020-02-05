#!/usr/bin/env python3

from distutils.core import setup

setup(name='VGE',
      version='2.1.1',
      description='Virtual Grid Engine for running bioinformatics pipelines on MPI-base supercomputers',
      author='Satoshi ITO, Masaaki YADOME, and Satoru MIYANO',
      author_email='sito.public@gmail.com',
      url='https://github.com/SatoshiITO/VGE',
      packages=['VGE'],
      data_files=[('bin', ['vge.cfg'])],
      scripts=['vge', 'vge_connect', 'cleanvge'],
      )
