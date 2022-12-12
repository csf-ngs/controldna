#!/usr/bin/env python

import sys, re
#import click
import unittest
import pysam



def extract_umi(readname: str) -> str:
    rn = readname.split()[0]
    umi = rn.split("_")[-1]
    return umi

def insert_umis(inputbam: str, outputbam: str):
    input = pysam.AlignmentFile(inputbam, "rb")
    output = pysam.AlignmentFile(outputbam, "wb", template=input)
    for read in input.fetch(until_eof=True ):
        rn = read.query_name
        umi = extract_umi(rn)
        read.set_tag("RX",umi) #--UMI_TAG_NAME 
        output.write(read)

    input.close()
    output.close()

#no click in umi_tools SINGULARITY
#@click.command()
#@click.option("--inputbam", help="input bam")
#@click.option("--outputbam", help="output bam")
#def run_cmd(inputbam: str, outputbam: str):
#    "runs a command"
#    insert_umis(inputbam, outputbam)



class TestCMD(unittest.TestCase):

    def test_cmd(self):
        self.assertEqual(1, 1)

if __name__ == '__main__':
    import platform
    print(f"version: {platform.python_version()}")
    if len(sys.argv) == 1:
        unittest.main(exit=False)
        #run_cmd(["--help"])
    else:
        insert_umis(sys.argv[1], sys.argv[2])



