const serverless = require("serverless-http");
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
    const availability = Object.entries(lotInfo["Availability"]);
    const lotName = lotInfo["LocationName"];
    const lotContext = lotInfo["LocationContext"];
    var isHistoric;
    lotInfo["LocationProvider"] == "Historic"
      ? (isHistoric = true)
      : (isHistoric = false);

    // if (!req.query.spots) {
    //   res.render("parking");
    // }
    let str = req.query.spots;
    const spotTypes = str.split(",");

    const numSpots = spotTypes.length;

    var spot0, spot1, spot2

    if (spotTypes[0]) spot0 = spotTypes[0];
    if (spotTypes[1]) spot1 = spotTypes[1];
    if (spotTypes[2]) spot2 = spotTypes[2];

    var totalSpots = 0;
    var lotData = {};
    // var availableData = {};
    for (const [spotType, data] of availability) {
      //Iterate through all spot types in this parking lot data
      console.log(spotType);
      if (spotTypes.includes(spotType)) {
        //User has selected this spot type and there are spots of these type in this lot

        totalSpots += parseInt(data["Total"]);

        lotData[spotType] = Math.floor(
          (100 * parseInt(data["Open"])) / parseInt(data["Total"])
        );
      } else {
        //User has not selected this spot type
      }
    }
    totalSpacesData = lotData;
    const totalSpaces = totalSpots;

    const cardWidth = req.query.width ? parseInt(req.query.width) : 200;
    const cardHeight = req.query.height ? parseInt(req.query.height) : 200;

    res.render("parking", {
      lotName: lotName ? lotName : undefined,
      lotContext: lotContext ? lotContext : undefined,
      totalSpaces: totalSpaces ? totalSpaces : undefined,
      numSpots: numSpots ? numSpots : undefined,
      spot0: spot0 ? spot0 : undefined,
      spot1: spot1 ? spot1 : undefined,
      spot2: spot2 ? spot2 : undefined,
      isHistoric: isHistoric ? isHistoric : undefined,
      cardWidth: cardWidth ? cardWidth : undefined,
      cardHeight: cardHeight ? cardHeight : undefined,
    });
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
module.exports.handler = serverless(app);
// exports.app = functions.https.onRequest(app);
