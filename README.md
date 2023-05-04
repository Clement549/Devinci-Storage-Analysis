# Presentation

<img src="https://user-images.githubusercontent.com/13381610/175571776-ef6391dc-94fb-4200-acea-d9621d891afe.jpg" name="image-name" height="300" width="600">

### English

DSA aims to optimize the route of garbage trucks ⬇️

To do this, I built little devices, composed of an ESP32 microcontroller (cheaper version of Arduino), an ulrasonic sensor and a 2G internet module 🖲️

The components are placed in a 3D printed box, designed with SolidWorks.

Theses devices are then placed inside the bin, on the lid, at the top 🗑️ 

Once a day, at 4am, the ultrasonic sensor measures the distance to check if the bin is closed to be empty. 
The data is sent via the 2G module to my Node.js backend server through an HTTP Post request 📡

For this project, I also had to build a Flutter mobile app for the workers 📱

This app uses the Google Map API to display the positions of the bins in the area and their filling percentage 🗺️

Then, it will compute the shortest route to get all the bins that are almost full.

Thus, trucks don't have to pass where bins don't need to be empty 🚚

### French

DSA est un service d’aide au ramassage des déchets prenant la forme d’une application mobile et d'un boitié composé d'un ensemble de capteurs fixé aux poubelles. 
Le taux de remplissage est mesuré quotidiennement par un capteur à ultrason et les données sont ensuite envoyées via requete HTTP Post à un serveur backend Node.js    
Dès la réception de ces données, le backend met à jour automatiquement la base de données NoSQL sur Firebase.

L'application cross-platform Android et IOS (réalisée avec Flutter) permet de visualiser sur une carte Google Maps la localisation des poubelles et de suivre en temps réel toutes les informations les concernats (Niveau de batterie, Photo de l'emplacement...)

## Gallerie

Vidéo de présentation de l'application (réaliséee sur After Effect) :

https://user-images.githubusercontent.com/13381610/175556938-6c254a30-4771-4478-ac09-3108c659ab17.mp4

Screenshots :

<img src="https://user-images.githubusercontent.com/13381610/175567664-96f5e86f-aa4a-4d7d-be59-4de59880a5d2.jpeg" name="image-name" height="400" width="200">
<img src="https://user-images.githubusercontent.com/13381610/175560945-7d5f315f-5e90-4f21-8d89-25c4d91007a7.jpeg" name="image-name" height="400" width="200">
<img src="https://user-images.githubusercontent.com/13381610/175560947-617949f3-8cec-4ee5-b08b-7073051df401.jpeg" name="image-name" height="400" width="200">
<img src="https://user-images.githubusercontent.com/13381610/175560948-4dd2d3d5-2bfd-44ab-8e4a-06a812da6f7d.jpeg" name="image-name" height="400" width="200">
<img src="https://user-images.githubusercontent.com/13381610/175567532-cd7fdfe2-fafd-4ba3-a43c-a87830b01955.jpeg" name="image-name" height="400" width="200">

Modélisation du capteur (sur Solidworks) :

<img src="https://user-images.githubusercontent.com/13381610/175566679-e786c5dd-74e3-4f3d-95b3-0f4e2699a355.jpeg" name="image-name" height="200" width="340">
<img src="https://user-images.githubusercontent.com/13381610/175562001-263ed2b9-6940-47d6-86df-39ce9a097bc8.jpeg" name="image-name" height="400" width="240">
<img src="https://user-images.githubusercontent.com/13381610/175562025-3f943cb1-e900-4bd4-a6de-db53221572ed.jpeg" name="image-name" height="400" width="240">

Objets connectés :

Microcontrolleur ESP32, codage en langage Arduino, module 2G SIM800L et emnify.com pour les cartes SIM.

Autres : 

[Cahier des charges.pdf](https://github.com/Clement549/DSA-Flutter/files/8977074/Cahier.des.charges.57.pdf)

[Budget.xlsx](https://github.com/Clement549/DSA-Flutter/files/8977075/Budget.xlsx)


