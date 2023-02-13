#!/usr/bin/env python

import sys, re
from dataclasses import dataclass
from typing import TextIO, Tuple
import click, unittest
import gzip
from gzip import GzipFile

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

def fq_lines(it: GzipFile) -> FQ:
    lines = it.readlines(4)
    return FQ(lines[0].decode('utf-8'), lines[1].decode('utf-8'), lines[2].decode('utf-8'), lines[3].decode('utf-8'))


def iterateFiles(r1: str, r2: str, r3: str, out: str):
    with gzip.open(r1) as r1in, gzip.open(r2) as r2in, gzip.open(r3) as r3in, gzip.open(out,"wb") as outf:
        
        f1 = fq_lines(r1in)

def read_fq(f1: FQ, f2: FQ, f3: FQ) -> Tuple[FQ,FQ]:
    with open(f1
        something(inf)



@click.command()
@click.option("--r1", help="r1 file")
@click.option("--r3", help="r3 file")
@click.option("--umi",help="umi pattern string")
@click.option("--out",help="output file")
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



