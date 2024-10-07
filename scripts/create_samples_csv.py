#!/usr/bin/env python

import sys,os,re
import click
from dataclasses import dataclass
from typing import List
import unittest

SAMPLEID_PAT=re.compile(r"(\d{6})")

# currently UMI is R2, r2 => R3 if R3 is present
@dataclass
class Sample:
    id: str
    r1: str
    r2: str
    r3: str

    def to_line(self, with_umi: bool, subsample: str):
        read2 = self.r2
        read3 = self.r3
        umi = ""
        if self.r3 != "":
           read2 = read3
           if with_umi:
              read3 = self.r2
              umi = "R2:NNNNNNNNNNN"
           else:
              read3 = ""
        return ",".join([self.id, self.r1, read2, umi, read3, "", subsample])

    @staticmethod
    def to_header() -> str:
        return "sample,fastq_1,fastq_2,umi,umi_file,strandedness,subsample"

def get_file(files, read) -> str:
    f = list(filter(lambda x: read in x, files))
    if len(f) == 1:
       return f[0]
    else:
       return ""


def get_samples(folder: str) -> List[Sample]:
    samples: List[Sample] = []
    for f in os.listdir(folder):
        fpath = f"{folder}/{f}"
        if os.path.isdir(fpath):
            m = SAMPLEID_PAT.match(f)
            if m:
                files = [f"{fpath}/{f}" for f in os.listdir(fpath)]
                sample = Sample(m.group(1), get_file(files, "_R1_00"), get_file(files, "_R2_00"), get_file(files, "_R3_00"))
                samples.append(sample)
    return sorted(samples, key=lambda s: s.id)

def write_csv(samples: List[Sample], with_umi: bool, subsample: str, outputpath: str):
    with open(outputpath, 'w') as outf:
        outf.write(f"{Sample.to_header()}\n")
        for s in samples:
            outf.write(f"{s.to_line(with_umi, subsample)}\n")


@click.command()
@click.option('--inputfolder', help='absolute path to folder with demultiplexed directories (no pooled samples)', required=True)
@click.option('--outputpath', help='path of output csv', required=True)
@click.option('--with_umi/--no_umi', default=True, help='with or without umi if possible', required=False)
@click.option('--subsample', default="", required=False, help="subsample data, overrides subsample from run.sh?, e.g. 0 = no subsample, 10M = 10M random subsample, 10Mf = first 10M from file")
def create_csv(inputfolder: str, outputpath: str, with_umi: bool, subsample: str):
    """Creates sample CSV for alignment with nf-core-controldna pipeline"""
    samples = get_samples(inputfolder)
    if len(samples) == 0:
        print(f"ERROR: could not find any sample folders within {inputfolder}")
    write_csv(samples, with_umi, subsample, outputpath)


class TestItems(unittest.TestCase):

    def test_dummy(self):
        self.assertEqual(True, True)

if __name__ == '__main__':
    import sys
    if len(sys.argv) == 1:
        unittest.main(exit=False)
        create_csv(["--help"])
    else:
        create_csv()


