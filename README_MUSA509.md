# MUSA 509 Final Project: RATScanner in the Cloud

*Henry Feinstein, Kate Tanabe, and Eric Yi*

Rats thrive in cities. However, the feeling is not mutual according to city residents. In 2021, DC’s 311 Service received over 11,000 requests for rodent 
inspection and abatement. As inspection requests continue to increase after a pandemic-induced spike in rat populations, inspection departments are inundated 
with requests for treatment. However, inspection and treatment require resources: personnel, time, and money. With over half of the inspection requests in DC 
not finding evidence of rats, the inspection and treatment process is costly to the city.

The RATScanner project explores the spatial and time patterns related to vermin infestation in order to develop a predictive model for estimating the probability of rat 
detection in a given area of Washington, DC. The information provided by the tool will allow city health and vermin inspectors to prioritize exterior inspections of 
properties suspected of vermin infestation based on the actual likelihood of rodents being detected. We aim to create a proof-of-concept infestation forecast that will 
be used as the basis of an inspection optimization data system and web app, which will allow for more targeted and efficient inspections.

More specifically, the web app is intended to be used by the vermin inspectors DC employs, who are typically assigned to a single ward within the city and are tasked
with tackling all the 311 vermin inspection requests that come in every day. The business-as-usual approach relies on inspectors' professional knowledge and ad hoc 
decision-making skills. RATScanner is a simple interface that presents inspectors with a map-based visualization of the day's 311 requests, symbolized by the likelihood
of rat infestation based on the predictions of our model. The app also contains information on notes from previous inspections at every city block, along with data on 
rat infestation and 311 request hotspots. This information will help inspectors prioritize sites for inspection, ideally leading to a higher rate of 
rat infestation identification and a more efficient use of resources by the city. 

Our MUSA 509 final project extends the RATScanner web app implemented for Spring 2023 MUSA Practicum by adding cloud-based data infrastructure on top of the existing
app. There are two cloud-based elements in this project:

1. **Cloud-based data storage:** All of the static data used in the app (such as ward boundaries, city block shapefiles, historical 311 inspection data, and the model's block-level predictions) is stored in Google Cloud Storage and accessed using the Cloud Storage API. The code used to access this API can be found primarily in the `site/map.js` module, which is where the data processing for the map element of the web app is executed.
2. **Data extraction, processing, and loading:** In addition to the static data stored in the cloud, this project now features the capacity to extract up-to-date 311 request data from [DC's Open Data website](https://opendata.dc.gov/). This functionality is used by scrolling the buttons at the top of the map to the left and clicking on the *Show Recent Data* button. On the back end, a data exctraction (`site/js/app.js`) and data processing script (`site/filter_311data.py`) are each running in the cloud periodically to pull down the 311 request data and store it in a Google Cloud bucket.

The RATScanner web app is ready for use and can be accessed [here](https://henryfeinstein.github.io/musa-rats/site/). Select a ward, click on a block, and learn about
how rats run (or, hopefully, don't run) the great city of Washington, DC! For more information, check out our accompanying [presentation](https://docs.google.com/presentation/d/1Non1TrbtR7V-argKlhQPqlGbOnRUnK2Dj_73y-234zQ/edit?usp=sharing) about RATScanner and the modeling behind it.
