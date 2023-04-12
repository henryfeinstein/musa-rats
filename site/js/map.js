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

    // Add the control to the map.
    const geocoder = new MapboxGeocoder({
        accessToken: mapboxgl.accessToken,
        mapboxgl: mapboxgl,
        language: 'en-EN',
    });

    document.getElementById('geocoder').appendChild(geocoder.onAdd(map));

    // Add geolocate control to the map.
    map.addControl(
        new mapboxgl.GeolocateControl({
            positionOptions: {
                enableHighAccuracy: true,
            },
            // When active the map will receive updates to the device's location as it changes.
            trackUserLocation: true,
            // Draw an arrow next to the location dot to indicate which direction the device is heading.
            showUserHeading: true,
        }),
    );

    map.addControl(new mapboxgl.NavigationControl());

    return map;
}

async function initializeBlocks(map) {
    // pull city block shapefile
    let blocks = await fetchJSON('./data/city_blocks.geojson');

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

    // When clicked, show the block information
    map.on('click', 'blocks', (e) => {
        console.log(e)
        let features = map.queryRenderedFeatures(e.point, { layers: ['blocks'] });
        console.log(features);
        let clicked_block = features[0].toJSON()['properties']['block_id'];

        // $("#geocoder-roof").trigger('change');

        // clicked_address = "";

        const coordinates = features[0].toJSON()["geometry"]["coordinates"][0];

        // Create a 'LngLatBounds' with both corners at the first coordinate.
        const bounds = new mapboxgl.LngLatBounds(
            coordinates[0],
            coordinates[0]
        );

        // Extend the 'LngLatBounds' to include every coordinate in the bounds result.
        for (const coord of coordinates) {
            bounds.extend(coord);
        }

        map.fitBounds(bounds, {
            padding: 20
        });

        let feature = features[0].toJSON();

        if (typeof map.getLayer('selectedBlock') !== "undefined" ){
            map.removeLayer('selectedBlock');
            map.removeSource('selectedBlock');
        }

        map.addSource('selectedBlock', {
            "type":"geojson",
            "data": feature,
        });
        map.addLayer({
            "id": "selectedBlock",
            "type": "line",
            "source": "selectedBlock",
            "layout": {
                "line-join": "round",
                "line-cap": "round",
            },
            "paint": {
                "line-color": "white",
                "line-width": 6,
            },
        });
        //
        new mapboxgl.Popup()
            .setLngLat(e.lngLat)
            .setHTML(e.features[0].properties.block_id)
            .addTo(map);
    });

    map.on('mouseenter', 'blocks', () => {
        map.getCanvas().style.cursor = 'pointer';
    });

    map.on('mouseleave', 'blocks', () => {
        map.getCanvas().style.cursor = '';
    });

    return blocks;
}

export {
    initializeMap,
    initializeBlocks,
}