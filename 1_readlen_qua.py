import time
import datetime
from Bio import SeqIO
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os
import numpy as np
from math import log


def ave_qual(quals):
    """Calculate average basecall quality of a read.
    Receive the integer quality scores of a read and return the average quality for that read
    First convert Phred scores to probabilities,
    calculate average error probability
    convert average back to Phred scale
    """
    if quals:
        return -10 * log(sum([10 ** (q / -10) for q in quals]) / len(quals), 10)
    else:
        return None


def extract_from_fastq(fq):
    """Extract quality score from a fastq file."""
    try:
        for rec in SeqIO.parse(fq, "fastq"):
            yield rec.id, len(rec.seq), ave_qual(rec.letter_annotations["phred_quality"])
    except Exception as e:
        print(f"Error processing file: {e}")
        return None


def timepoint(event):
    time_point = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return time_point + '\t' + event


if __name__ == '__main__':
    time_start = time.time()
    # crop
    # data_list = []
    barcode_to_location = {
        "LB_1": {
            "barcode01": "NHM 0m",
            "barcode02": "Vauxhall",
            "barcode03": "Pimlico",
            "barcode04": "Victoria",
            "barcode05": "St. James’s Park",
            "barcode06": "Water blank",
            "barcode07": "Regent’s Park"
        },
        "LB_2": {
            "barcode01": "St. Mary’s Hospital",
            "barcode02": "Marylebone",
            "barcode03": "Piccadilly",
            "barcode04": "Trafalgar Square",
            "barcode05": "Embankment",
            "barcode06": "Monument",
            "barcode07": "Liverpool Street"
        },
        "LC_1": {
            "barcode01": "NHM 30m",
            "barcode02": "NHM 15m",
            "barcode03": "NHM 0m",
            "barcode04": "Vauxhall",
            "barcode05": "Pimlico"
        },
        "LC_2": {
            "barcode06": "Victoria",
            "barcode07": "St. James’s Park",
            "barcode08": "Regent’s Park",
            "barcode09": "St. Mary’s Hospital",
            "barcode10": "Marylebone"
        },
        "LC_3": {
            "barcode11": "Piccadilly",
            "barcode12": "Trafalgar Square",
            "barcode01": "Embankment",
            "barcode02": "Monument",
            "barcode03": "Liverpool Street"
        }
    }

    locations = {
        "LB_1": "/mnt/shared/projects/nhm/clark-student/LondonLocationSampling/London_part1/subsample/subbarcodes_marti/fastq_chunks/",
        "LB_2": "/mnt/shared/projects/nhm/clark-student/LondonLocationSampling/London_part2/subsample/subbarcodes_marti/fastq_chunks/",
        "LC_1": "/mnt/shared/projects/nhm/clark-student/LondonLocationSampling/DARPA_LonCol_Pool1_12092019/subsample/subbarcodes_marti/fastq_chunks/",
        "LC_2": "/mnt/shared/projects/nhm/clark-student/LondonLocationSampling/DARPA_LonCol_Pool2_12092019/subsample/subbarcodes_marti/fastq_chunks/",
        "LC_3": "/mnt/shared/projects/nhm/clark-student/LondonLocationSampling/DARPA_LonCol_Pool3_12092019/subsample/subbarcodes_marti/fastq_chunks/"
    }

    with open("qualityInfo0801.txt", "w") as fw:
        fw.write("Read_ID\tExperiment_ID\tSamples(Barcodes)\tLocation\tFastq\tRead_length\tRead_quality\n")
        for location_name, location_path in locations.items():
            print(timepoint(f"{location_name} start:"))
            for sample_folder in os.listdir(location_path):
                if "barcode" in sample_folder:
                    sample_path = os.path.join(location_path, sample_folder)
                    if os.path.isdir(sample_path):
                        print(timepoint(f"{sample_folder} start"))
                        for filename in os.listdir(sample_path):
                            if filename.endswith(".fastq"):
                                fastq_file = os.path.join(sample_path, filename)
                                for record_id, read_length, read_quality in extract_from_fastq(fastq_file):
                                    if read_quality is not None:
                                        location_label = barcode_to_location[location_name].get(sample_folder, sample_folder)
                                        fw.write(f"{record_id}\t{location_name}\t{sample_folder}\t{location_label}\t{filename}\t{read_length}\t{read_quality}\n")

    print(timepoint("Processing complete"))
