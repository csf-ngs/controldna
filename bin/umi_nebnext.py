#!/usr/bin/env python

import sys, re
from dataclasses import dataclass
from typing import TextIO, Tuple
import click, unittest

#using UMITOOLS_UMI_EXTRACT for now

@dataclass
class FQ():
    name1: str
    seq: str
    name2: str
    qual: str

    def nebnext_umi(self) -> str:
        return self.seq[8:]

    def append_umi(self):
        self.name = f"{self.name}"

def fq_lines(it: TextIO) -> FQ:
    lines = it.readlines(4)
    return FQ(lines[0], lines[1], lines[2], lines[3])

def read_fq(f1: FQ, f2: FQ, f3: FQ) -> Tuple[FQ,FQ]:
    
        something(inf)



@click.command()
@click.option("--r1", help="r1 file")
@click.option("--r3", help="r3 file")
@click.option("--umi",help="umi pattern string")
@click.option("--suffix", help="suffix for output files")
def run_cmd(input: str):
    "runs a command"
    pass



class TestCMD(unittest.TestCase):

    def test_cmd(self):
        self.assertEqual(1, 1)

if __name__ == '__main__':
    import platform
    print(f"version: {platform.python_version()}")
    if len(sys.argv) == 1:
        unittest.main(exit=False)
        run_cmd(["--help"])
    else:
        run_cmd()



