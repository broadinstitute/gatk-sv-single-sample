#!/usr/bin/env python

import argparse
import json
import sys

# takes a GATKSVClinicalPipeline input json file and creates a tsv formatted output table
# that can be uploaded to terra as workspace data to represent the reference panel and workflow parameters
#
# removes sample_id and bam/cram file info since they should be supplied by sample entities in terra
#
# currently terra does not allow uploading very large tsvs, and also does not support uploading arrays inside
# tsvs (although reportedly this can be worked around by changing the type of the field from "string" to
# "string list" after upload, so this script does not include entries with array values in the output -- these
# need to be added manually to the terra workspace data at this time
parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument('-o', '--outfile', help='Output file [default: stdout]')

parser.add_argument('input_json')

args = parser.parse_args()

if args.outfile is None:
    fout = sys.stdout
else:
    out = args.outfile

with open(args.input_json, "r") as read_file:
    data = json.load(read_file)

    for arraykey in [key for key in data if isinstance(data[key], list)]:
        del data[arraykey]

    del data["GATKSVPipelineClinical.sample_id"]
    del data["GATKSVPipelineClinical.bam_or_cram_file"]
    del data["GATKSVPipelineClinical.bam_or_cram_index"]


    fout.write("workspace:" + "\t".join([key.split(".")[1] for key in data]) + "\n")
    fout.write("\t".join([json.dumps(data[key]) for key in data]) + "\n")
