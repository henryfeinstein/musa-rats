import { fetchJSON } from "./utils.js";

mapboxgl.accessToken = 'pk.eyJ1IjoieWVzZW5pYW8iLCJhIjoiY2tlZjAyM3p5MDNnMjJycW85bmpjenFkOCJ9.TDYe7XRNP8CnAto0kLA5zA';

function initializeMap() {
    const map = new mapboxgl.Map({
        container: 'map', // container ID
        // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
        style: 'mapbox://styles/mapbox/light-v9', // style URL
        center: [-77.03380390100355, 38.9092301970931], // starting position [lng, lat],
        zoom: 9, // starting zoom
    });

    return map;
}

async function initializeBlocks(map) {
    // pull city block shapefile
    let blocks = await fetchJSON('./data/city_blocks.geojson');

    // add to new map layer
    // map.blockLayer = L.geoJSON(blocks, {
    //     style: {
    //         opacity: 0.3,
    //         fillOpacity: 0,
    //         weight: 1,
    //         color: "#000000",
    //     },
    // }).addTo(map);

    map.on('load', () => {
        // Add a data source containing GeoJSON data.
        map.addSource('blocks-boundary', {
            'type': 'geojson',
            'data': blocks
        });

        map.addLayer({
            'id': 'blocks',
            'type': 'fill',
            'source': 'blocks-boundary', // reference the data source
            'layout': {},
            'generateId': true,
            'paint': {
                // 'fill-color': '#0080ff', // blue color fill
                // 'fill-opacity': 0,
                'fill-outline-color': 'rgba(0,0,0,0.1)',
                // 'fill-color': '#627BC1',
                'fill-opacity': 0.1,
            },
        });
        map.addLayer({
            'id': 'outline',
            'type': 'line',
            'source': 'blocks-boundary',
            'layout': {},
            'paint': {
                'line-color': '#ffffff',
                'line-width': 1,
            },
        });
    });

    return blocks;
}

export {
    initializeMap,
    initializeBlocks,
}