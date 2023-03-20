async function fetchJSON(url) {
    const resp = await fetch(url);
    return await resp.json();
}

function fetchCSV(url) {
    let csvToJson = require('convert-csv-to-json');
    let json = csvToJson.getJsonFromCsv(url);
    return json;
}

export {
    fetchJSON,
    fetchCSV,
}