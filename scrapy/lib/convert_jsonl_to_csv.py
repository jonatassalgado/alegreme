
import glob
import json
import csv

import time


start = time.time()
#import pandas as pd
from flatten_json import flatten

#Path of jsonl file
File_path = './jsonl_to_convert'
#reading all jsonl files
print(glob.glob("./**/*.jsonl", recursive=True))
files = [f for f in glob.glob("./**/*.jsonl", recursive=True)]
i=0

for f in files:
    with open(f, 'r') as F:
        for line in F:
            data = json.loads(line)
            data = flatten(data)
            with open('./path-to-csv-file.csv', 'a' , newline='') as f:
                print(data)
                thewriter = csv.writer(f)
                thewriter.writerow([data['shortcode']])