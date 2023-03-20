import { fetchJSON } from "./utils.js";

// function to get new service requests and parse into proper format
async function parseRequestData() {
    // pull new rat treatment requests (for now, from static requests JSON)
    // NOTE: I HAD TO CONVERT THE CSV TO JSON USING R, BUT WE SHOULD FIGURE OUT A BETTER WAY TO DO THIS
    // predictions is an array of JSON objects where each object is a service request and associated probability
    let requests = await fetchJSON('./data/GB_results.json');
    

    for (let request of requests) {
        if (request.Probs <= 0.33) {
            request.priorityLevel = "Low Priority";
        } else if (request.Probs > 0.33 & request.Probs <= 0.66) {
            request.priorityLevel = "Medium Priority";
        } else {
            request.priorityLevel = "High Priority";
        }
    }

    return requests;
}

// function to create list of service requests on list tab of app
function buildPredictionList(requests) {
    let listContainer = document.getElementById("list-container");
    listContainer.innerHTML = "";

    // only show top 100 to speed up loading time
    // TODO: sort by date before doing this probably? Or make sure source data is organized by date
    let i = 0;
    for (let request of requests) {
        let html = `
            <div class="listed-request">
                <span class="list-priority">${request.priorityLevel}</span>
                <span class="list-address">Address Placeholder</span>
                <span class="list-date">${request.SERVICEORDERDATE}</span>
            </div>
        `;
        listContainer.innerHTML += html;
        i++;
        if (i == 100) {
            break;
        }
    }
}

export {
    parseRequestData,
    buildPredictionList,
}