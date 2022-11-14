#!/usr/bin/env python

import sys, re
from dataclasses import dataclass
import click, unittest
import pysam


@dataclass
class TheClass():
    input: str


def extract_umi(readname: str) -> str:


samfile = pysam.AlignmentFile("ex1.bam", "rb")
pairedreads = pysam.AlignmentFile("allpaired.bam", "wb", template=samfile)
for read in samfile.fetch():
    if read.is_paired:
        pairedreads.write(read)

@click.command()
@click.option("--input", help="input")
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



