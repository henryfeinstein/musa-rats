import { initializeBlocks, initializeMap } from "./map.js";
import { parseRequestData, buildPredictionList } from "./dataProcessing.js";

// initialize site
let map = await initializeMap();
let blocks = await initializeBlocks(map);
let requests = await parseRequestData();
// buildPredictionList(requests);


window.blocks = blocks;
window.requests = requests;

// Get the modal
let modal = document.getElementById("myModal");

// Get the button that opens the modal
let btn = document.querySelector("#myBtn");

// Get the <span> element that closes the modal
let span = document.getElementsByClassName("close")[0];

// When the user clicks on the button, open the modal
btn.addEventListener('click', () => { 
    modal.style.display = "block"; 
});
// btn.onclick = function() {
//   modal.style.display = "block";
// }

// When the user clicks on <span> (x), close the modal
span.onclick = function() {
  modal.style.display = "none";
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
  }
}

// get DOMs
// let listContainer = document.querySelector("#list-container");
// let wardMenu = document.querySelector("#ward-menu");
// let ratHotspotCheckbox = document.querySelector("#rat-hotspot");
// let callHotspotCheckbox = document.querySelector("#call-hotspot");
//
// // event listeners
// ratHotspotCheckbox.addEventListener('change', onRatHotspotCheck);
// callHotspotCheckbox.addEventListener('change', onCallHotspotCheck);
// wardMenu.addEventListener('change', onWardMenuSelection);