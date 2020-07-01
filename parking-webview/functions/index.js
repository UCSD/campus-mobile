const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const app = express();

app.set("view engine", "ejs");

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));
//localhost:5000/parking?lot=P406&spots=A,B,S
app.get("/parking", function (req, res) {
  let loc = app.locals
  loc.lotName = undefined;
  loc.lotContext = undefined;
  loc.totalSpaces = undefined;
  loc.numSpots = undefined;
  loc.spot0 = undefined;
  loc.spot1 = undefined;
  loc.spot2 = undefined;
  if (!req.query.lot) {
    res.render("parking");
  }
  let lotID = req.query.lot;
  const url =
    "https://4pefyt8qv7.execute-api.us-west-2.amazonaws.com/dev/parking/v1.1/status/" +
    lotID;
  var client = new HttpClient();
  client.get(url, (response) => {
    var lotInfo = JSON.parse(response);
    loc.lotName = lotInfo["LocationName"];
    loc.lotContext = lotInfo["LocationContext"];
    var availability = lotInfo["Availability"];
    console.log(availability);

    var totalSpots = 0;

    loc.totalSpaces = 0;

    if (!req.query.spots) {
      res.render("parking");
    }
    str = req.query.spots;
    const spotTypes = str.split(",");

    console.log(spotTypes.length);

    loc.numSpots = spotTypes.length;

    if (spotTypes[0]) loc.spot0 = spotTypes[0];
    if (spotTypes[1]) loc.spot1 = spotTypes[1];
    if (spotTypes[2]) loc.spot2 = spotTypes[2];

    res.render("parking");
  });
});

// Resusable code to make an XML HTTP request
var HttpClient = function () {
  this.get = function (aUrl, aCallback) {
    var anHttpRequest = new XMLHttpRequest();
    anHttpRequest.onreadystatechange = function () {
      if (anHttpRequest.readyState == 4 && anHttpRequest.status == 200)
        aCallback(anHttpRequest.responseText);
    };

    anHttpRequest.open("GET", aUrl, true);
    anHttpRequest.send(null);
  };
};

exports.app = functions.https.onRequest(app);
