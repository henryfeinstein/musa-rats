# -*- coding: utf-8 -*-
'''
@Time    : 2023/4/30 11:41
@Author  : Ericyi
@File    : filter_311data.py

'''
import functions_framework
import json
import geopandas as gpd
from google.cloud import storage
from flask import jsonify

@functions_framework.http
def filter(request):
    client = storage.Client()
    bucket_name = 'rats_app_data'

    raw_blob = client.bucket(bucket_name).blob('311_City_Service_Requests_latest.geojson')
    content = raw_blob.download_as_string()
    data = json.loads(content.decode('utf-8')) # Decode the byte string to a regular string

    # Use the 'features' key from the GeoJSON object
    gdf = gpd.GeoDataFrame.from_features(data['features'])

    # Select "Rodent Inspection and Treatment" from SERVICECODEDESCRIPTION
    filtered_gdf  = gdf[gdf['SERVICECODEDESCRIPTION'] == 'Rodent Inspection and Treatment']

    filtered_data = json.loads(filtered_gdf.to_json())

    file_name = 'rodent_latest.geojson'

    with open(file_name, 'w') as f:
        json.dump(filtered_data, f)

    filtered_blob = client.bucket(bucket_name).blob(file_name)
    filtered_blob.upload_from_filename(file_name)

    filtered_blob.acl.reload() # reload the ACL of the blob
    acl = filtered_blob.acl
    acl.all().grant_read()
    acl.save()

    response = {
        'status': 'success',
        'message': f"Filtered rodent inspection data saved to gs://{bucket_name}/rodent_inspection.geojson"
    }
    return jsonify(response)
