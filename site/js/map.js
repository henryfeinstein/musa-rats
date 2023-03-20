import { fetchJSON } from "./utils.js";

function initializeMap() {
    let map = L.map('map').setView([38.9092301970931, -77.03380390100355], 13);

    const mapboxAccount = 'mapbox';
    const mapboxStyle = 'light-v10';
    const mapboxToken = 'pk.eyJ1IjoiaGVucnlmZWluc3RlaW4iLCJhIjoiY2w4dzIyYXc0MDN2dTNwcnE3ZnMzOXh5OCJ9.Xj0CS62yWWvKB-v_uYz9sQ';
    L.tileLayer(`https://api.mapbox.com/styles/v1/${mapboxAccount}/${mapboxStyle}/tiles/256/{z}/{x}/{y}@2x?access_token=${mapboxToken}`, {
    maxZoom: 19,
    attribution: '© <a href="https://www.mapbox.com/about/maps/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> <strong><a href="https://www.mapbox.com/map-feedback/" target="_blank">Improve this map</a></strong>',
    }).addTo(map);

    return map;
}

async function initializeBlocks(map) {
    // pull city block shapefile
    let blocks = await fetchJSON('./data/city_blocks.geojson');

    // add to new map layer
    map.blockLayer = L.geoJSON(blocks, {
        style: {
            opacity: 0.3,
            fillOpacity: 0,
            weight: 1,
            color: "#000000",
        },
    }).addTo(map);

    return blocks;
}

export {
    initializeMap,
    initializeBlocks,
}