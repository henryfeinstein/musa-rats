import { initializeBlocks, initializeMap } from "./map.js";
import { parseRequestData, buildPredictionList } from "./dataProcessing.js";

// initialize site
let map = await initializeMap();
let blocks = await initializeBlocks(map);
let requests = await parseRequestData();
buildPredictionList(requests);


window.blocks = blocks;
window.requests = requests;

// get DOMs
let listContainer = document.querySelector("#list-container");
// let wardMenu = document.querySelector("#ward-menu");
// let ratHotspotCheckbox = document.querySelector("#rat-hotspot");
// let callHotspotCheckbox = document.querySelector("#call-hotspot");
//
// // event listeners
// ratHotspotCheckbox.addEventListener('change', onRatHotspotCheck);
// callHotspotCheckbox.addEventListener('change', onCallHotspotCheck);
// wardMenu.addEventListener('change', onWardMenuSelection);