const serverless = require("serverless-http");
const functions = require("firebase-functions");
const express = require("express");
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.set("view engine", "ejs");

// Automatically allow cross-origin requests
// app.use(cors({ origin: true }));
// https://cqeg04fl07.execute-api.us-west-2.amazonaws.com/parking?lot=P406&spots=A,B,S
// http://localhost:5000/parking?lot=P406&spots=A,B,S
app.get("/parking", function (req, res) {
  let loc = app.locals; //shorthand
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
  //multiple
  //for each lot
  var client = new HttpClient();
  client.get(url, (response) => {
    var lotInfo = JSON.parse(response);
    const availability = Object.entries(lotInfo["Availability"]);
    loc.lotName = lotInfo["LocationName"];
    loc.lotContext = lotInfo["LocationContext"];
    // var availability = lotInfo["Availability"];

    if (!req.query.spots) {
      res.render("parking");
    }
    str = req.query.spots;
    const spotTypes = str.split(",");

    loc.numSpots = spotTypes.length;

    if (spotTypes[0]) loc.spot0 = spotTypes[0];
    if (spotTypes[1]) loc.spot1 = spotTypes[1];
    if (spotTypes[2]) loc.spot2 = spotTypes[2];

    var totalSpots = 0;
    var lotData = {};
    var availableData = {};
    for (const [spotType, data] of availability) {
      //Iterate through all spot types in this parking lot data
      console.log(spotType);
      if (spotTypes.includes(spotType)) {
        //User has selected this spot type and there are spots of these type in this lot

        totalSpots += parseInt(data["Total"]);
        // loc.data[spotType] = data;
        // console.log(data);
        lotData[spotType] = Math.floor(
          (100 * parseInt(data["Open"])) / parseInt(data["Total"])
        );
      } else {
        //User has not selected this spot type
      }
    }
    loc.totalSpacesData = lotData;
    loc.totalSpaces = totalSpots;

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
//module.exports.handler = serverless(app);
exports.app = functions.https.onRequest(app);
