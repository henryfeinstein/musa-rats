const https = require('https');
const {Storage} = require('@google-cloud/storage');

const storage = new Storage({
    projectId: 'rats-385116',
    keyFilename: './rats-385116-2e1015a9127a.json',
});
const bucketName = 'rats_app_data';

const fileName = 'test.geojson';

// 311 request data in 2018
const url = 'https://opendata.arcgis.com/api/v3/datasets/2a46f1f1aad04940b83e75e744eb3b09_9/downloads/data?format=geojson&spatialRefId=4326&where=1%3D1';

// Create a writable stream to the new file in the bucket
const file = storage.bucket(bucketName).file(fileName).createWriteStream({
  metadata: {
    contentType: 'text/plain',
    // Set the ACL to public read access
    acl: [{ entity: 'allUsers', role: storage.acl.READER_ROLE }]
  }
});


https.get(url, (response) => {
  response.pipe(file);

  file.on('finish', () => {
    console.log(`File ${fileName} uploaded to ${bucketName}.`);
  });

  file.on('error', (err) => {
    console.error(`Error uploading file to GCS: ${err}`);
  });
});