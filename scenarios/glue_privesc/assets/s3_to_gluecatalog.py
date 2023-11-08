import json
import boto3
import csv
import io


def add_header_to_csv_file(input_bucket, input_key):
    s3 = boto3.client('s3')

    # 원본 파일 다운로드
    response = s3.get_object(Bucket=input_bucket, Key=input_key)
    content = response['Body'].read().decode('utf-8')
    # print("content : ", content)
    # print("content[0] : ", content.split('\n')[0])

    header = content.split('\r\n')[0]
    # print("header : ", header)

    if header == 'order_date,item_id,price,country_code':
        # print(1)
        output_bucket = 'glue-final-bucket2'
        output_key = 'result.csv'
        s3.put_object(Bucket=output_bucket, Key=output_key, Body=content)

        return [output_bucket, output_key]

    else:
        # 헤더 추가
        header = 'order_date,item_id,price,country_code'
        content_with_header = header + "\r\n" + content
        # print("content_with_header : ", content_with_header)

        output_bucket = 'glue-final-bucket2'
        output_key = 'result.csv'
        s3.put_object(Bucket=output_bucket, Key=output_key, Body=content_with_header)

        return [output_bucket, output_key]


def lambda_handler(event, context):
    # print(event)
    glue = boto3.client('glue')
    job_name = "ETL_JOB"  # 실행할 Glue Job의 이름으로 변경
    s3_bucket = "test-glue-scenario2"  # 데이터가 업로드되는 S3 버킷 이름으로 변경
    s3_object_key = event['Records'][0]['s3']['object']['key']
    # print(s3_bucket, s3_object_key)

    # 파일 확장자 표시
    file_format = s3_object_key.split('.')[-1]

    if file_format == 'csv':
        output_bucket, output_key = add_header_to_csv_file(s3_bucket, s3_object_key)

        # Glue Job (ETL_JOB)실행
        response = glue.start_job_run(
            JobName=job_name,
            Arguments={
                '--s3_source_path': f's3://{output_bucket}/{output_key}'
            }
        )
        return response

    else:
        return print('file_format is not csv')