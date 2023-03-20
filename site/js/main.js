import { initializeBlocks, initializeMap } from "./map.js";
import { parseRequestData, buildPredictionList } from "./dataProcessing.js";

// initialize site
let map = initializeMap();
let blocks = await initializeBlocks(map);
let requests = await parseRequestData();
buildPredictionList(requests);


window.blocks = blocks;
window.requests = requests;

// get DOMs
let listButton = document.querySelector("#list-button");
let mapButton = document.querySelector("#map-button");
let analysisButton = document.querySelector("#analysis-button");
let listContainer = document.querySelector("#list-container");

// event listener functions
function onListButtonClick() {
    listButton.classList.remove("unpressed");
    listButton.classList.add("pressed");
    mapButton.classList.remove("pressed");
    mapButton.classList.add("unpressed");
    analysisButton.classList.remove("pressed");
    analysisButton.classList.add("unpressed");
    listContainer.classList.add("list-up");
    listContainer.classList.remove("list-down");
}

function onMapButtonClick() {
    listButton.classList.remove("pressed");
    listButton.classList.add("unpressed");
    mapButton.classList.remove("unpressed");
    mapButton.classList.add("pressed");
    analysisButton.classList.remove("pressed");
    analysisButton.classList.add("unpressed");
    listContainer.classList.remove("list-up");
    listContainer.classList.add("list-down");
}

function onAnalysisButtonClick() {
    listButton.classList.remove("pressed");
    listButton.classList.add("uppressed");
    mapButton.classList.remove("pressed");
    mapButton.classList.add("unpressed");
    analysisButton.classList.remove("unpressed");
    analysisButton.classList.add("pressed");
}

// event listeners
listButton.addEventListener('click', onListButtonClick);
mapButton.addEventListener('click', onMapButtonClick);
analysisButton.addEventListener('click', onAnalysisButtonClick);