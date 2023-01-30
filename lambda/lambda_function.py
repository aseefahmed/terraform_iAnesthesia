import json
import os
import glob
import boto3
import requests
import datetime

today = datetime.datetime.today()
s3 = boto3.resource('s3')
bucket = "anesthesia-archives-20220704105512429800000001"
# a  =requests.get('https://opensearch.org/')
# print(a)
# exit()

def lambda_handler(event, context):
    my_path = '/mnt/lambda-efs'
    files = glob.glob(my_path + '/**/*.gz', recursive=True)
    print('files found : ', len(files))
    for file in files:
        
        modified_date = datetime.datetime.fromtimestamp(os.path.getmtime(file))
        duration = today - modified_date
        duration = (today - modified_date).days
        if duration > 3:
            print(file, ' removed')
            os.remove(file)
        else:
            s3.meta.client.upload_file(file, bucket, file[1:])
       