import { fetchJSON } from "./utils.js";

mapboxgl.accessToken = 'pk.eyJ1IjoieWVzZW5pYW8iLCJhIjoiY2tlZjAyM3p5MDNnMjJycW85bmpjenFkOCJ9.TDYe7XRNP8CnAto0kLA5zA';

async function initializeMap() {
    const map = new mapboxgl.Map({
        container: 'map', // container ID
        // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
        style: 'mapbox://styles/mapbox/light-v9', // style URL
        center: [-77.03380390100355, 38.9092301970931], // starting position [lng, lat],
        zoom: 11, // starting zoom
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

    // load data for hotspots
    let ratHotspot = await fetchJSON('./data/rat_hotspot.geojson');
    let callHotspot = await fetchJSON('./data/req_hotspot.geojson');
    let wards = await fetchJSON('./data/Wards.geojson');

    // store my layers, for the convenience of removing
    let myLayers = [];

    window.wards = wards;
    window.map = map;
    window.myLayers = myLayers;

    map.addSource('rats-hotspot', {
        'type': 'geojson',
        'data': ratHotspot
    });

    console.log(ratHotspot)

    map.addSource('call-hotspot', {
        'type': 'geojson',
        'data': callHotspot
    });

    map.addSource('wards', {
        'type': 'geojson',
        'data': wards
    });

    return map;
}

async function initializeBlocks(map) {
    // pull city block shapefile
    let blocks = await fetchJSON('./data/city_blocks.geojson');

    // pull model results
    let block_results = await fetchJSON('./data/SVM_results.json');

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

        myLayers.push('blocks');

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

        myLayers.push('outline');

        map.addLayer({
            'id': 'wards',
            'type': 'fill',
            'source': 'wards', // reference the data source
            'layout': {},
            'generateId': true,
            'paint': {
                // 'fill-color': '#0080ff', // blue color fill
                // 'fill-opacity': 0,
                'fill-outline-color': 'rgba(0,0,0,0.1)',
                // 'fill-color': '#627BC1',
                'fill-opacity': 0,
            },
        });

        myLayers.push('wards');

        map.addLayer({
            'id': 'ward_outline',
            'type': 'line',
            'source': 'wards',
            'layout': {},
            'paint': {
                'line-color': '#fa0808',
                'line-width': 1,
            },
        });

        myLayers.push('ward_outline');

    });

    // When clicked, show the block information
    map.on('click', 'blocks', (e) => {
        console.log(e)
        let features = map.queryRenderedFeatures(e.point, { layers: ['blocks'] });
        console.log(features);
        let clicked_block = features[0].toJSON()['properties']['block_id'];
        let clicked_block_info = block_results.filter(function(data) {
            return data.block_id === clicked_block;
        });

        console.log(clicked_block);
        console.log(clicked_block_info);

        // $("#geocoder-roof").trigger('change');

        // clicked_address = "";

        const coordinates = features[0].toJSON()["geometry"]["coordinates"][0];

        // Create a 'LngLatBounds' with both corners at the first coordinate.
        const bounds = new mapboxgl.LngLatBounds(
            coordinates[0],
            coordinates[0]
        );

        console.log(bounds)

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

        myLayers.push('selectedBlock');

        if (clicked_block_info[0]) {
            new mapboxgl.Popup()
            .setLngLat(e.lngLat)
            // .setHTML(e.features[0].properties.block_id)
            .setHTML(`
                <span>Last Inspection: ${clicked_block_info[0].INSPECTIONDATE}</span><br>
                <span>Inspection Notes: ${clicked_block_info[0].SERVICENOTES}</span><br>
                <span>Rat Probability: ${clicked_block_info[0].Probs}</span>
            `)
            .addTo(map);
        } else {
            new mapboxgl.Popup()
            .setLngLat(e.lngLat)
            .setHTML(`No Inspection History Available`)
            .addTo(map);
        }

    });

    map.on('mouseenter', 'blocks', () => {
        map.getCanvas().style.cursor = 'pointer';
    });

    map.on('mouseleave', 'blocks', () => {
        map.getCanvas().style.cursor = '';
    });

    return blocks;
}

$("#select-ward").change(function(){
    let selectVal = $("#select-ward option:selected").val();

    for (let i = 0; i < wards['features'].length; i++) {
        if (wards['features'][i]['properties']['NAME'] === selectVal) {
            const coordinates = wards.features[i].geometry.coordinates[0];

            // Create a 'LngLatBounds' with both corners at the first coordinate.
            const bounds = new mapboxgl.LngLatBounds(
                coordinates[0],
                coordinates[0],
            );

            // Extend the 'LngLatBounds' to include every coordinate in the bounds result.
            for (const coord of coordinates) {
                bounds.extend(coord);
            }

            map.fitBounds(bounds, {
                padding: 20,
            });

            let feature = wards['features'][i];

            if (typeof map.getLayer('selectedWard') !== "undefined" ){
                map.removeLayer('selectedWard');
                map.removeSource('selectedWard');
            }

            map.addSource('selectedWard', {
                "type":"geojson",
                "data": feature,
            });
            map.addLayer({
                "id": "selectedWard",
                "type": "line",
                "source": "selectedWard",
                "layout": {
                    "line-join": "round",
                    "line-cap": "round",
                },
                "paint": {
                    "line-color": "red",
                    "line-width": 6,
                },
            });

            myLayers.push('selectedWard');

            break;
        }
    }
});

// Clear all layers except for the basic layers: ward_outline, wards, blocks-boundary, blocks

function clearLayers(map) {
    let basic_layers = ['blocks', 'outline', 'wards', 'ward_outline'];
    for (let i = 0; i < myLayers.length; i++) {
        if (basic_layers.indexOf(myLayers[i]) === -1) {
            map.removeLayer(myLayers[i]);

            // delete the layerId in myLayers
            let index = myLayers.indexOf(3); // find the index of the element to be removed
            if (index !== -1) {
              myLayers.splice(index, 1); // remove the element at the specified index
            }
        }
    }
}

$("#rats-hotspots").click(function(){

    clearLayers(map);

    // map.addLayer({
    //   'id': 'call-hotspot',
    //   'type': 'fill',
    //   'source': 'rats-hotspot',
    //   'layout': {},
    //   'paint': {
    //     'fill-color': [
    //       'interpolate',
    //       ['linear'],
    //       ['get', 'Rat_Count'], // 用于渐变的属性
    //         7, 'rgb(235,59,31)',
    //         20, 'rgb(255,129,43)',
    //         36, 'rgb(243,175,36)',
    //         56, 'rgb(149,210,105)',
    //         83, 'rgb(84,159,40)',
    //         119, 'rgb(81,120,254)',
    //         165, 'rgb(33,86,254)',
    //         235, 'rgb(56,3,219)',
    //         452, 'rgb(31,3,106)' // 从0到100的范围内渐变颜色
    //     ],
    //     'fill-opacity': 0.7
    //   }
    // });

    map.addLayer({
        'id': 'rats-hotspot',
        'type': 'fill',
        'source': 'rats-hotspot', // reference the data source
        'layout': {},
        'paint': {
            'fill-color': [
              'interpolate',
              ['linear'],
              ['get', 'Rat_Count'],
                2, 'rgb(235,59,31)',
                7, 'rgb(243,175,36)',
                16, 'rgb(84,159,40)',
                35, 'rgb(33,86,254)',
                52, 'rgb(31,3,106)'
            ],
            'fill-opacity': 0.7
        }
    });
    myLayers.push('rats-hotspot');
});

$("#311-hotspots").click(function(){

    clearLayers(map);

    map.addLayer({
      'id': 'call-hotspot',
      'type': 'fill',
      'source': 'call-hotspot',
      'layout': {},
      'paint': {
        'fill-color': [
          'interpolate',
          ['linear'],
          ['get', 'Req_Count'],
            7, 'rgb(235,59,31)', // value range & color
            20, 'rgb(255,129,43)',
            36, 'rgb(243,175,36)',
            56, 'rgb(149,210,105)',
            83, 'rgb(84,159,40)',
            119, 'rgb(81,120,254)',
            165, 'rgb(33,86,254)',
            235, 'rgb(56,3,219)',
            452, 'rgb(31,3,106)'
        ],
        'fill-opacity': 0.7
      }
    });
    myLayers.push('call-hotspot');
});

export {
    initializeMap,
    initializeBlocks,
}