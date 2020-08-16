const serverless = require("serverless-http");
const express = require("express");
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
const functions = require("firebase-functions");

var fs = require("fs");

const spot_type_data = JSON.parse(fs.readFileSync("spot_types.json")).spots;

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
    console.log(lotInfo);
    const availability = lotInfo["Availability"];
    const lotName = lotInfo["LocationName"];
    const lotContext = lotInfo["LocationContext"];

    //Helps to add special message warning data is not live.
    var isHistoric;
    lotInfo["LocationProvider"] == "Historic"
      ? (isHistoric = true)
      : (isHistoric = false);

    var totalSpacesForThisSelection = 0;
    var numSpotsSelected = 0;

    // Get data (text and color) for spot types from query string
    var userSpotData = {};
    let str = req.query.spots ? req.query.spots : "";
    const selectedSpotsFromQuery = str.split(",");
    for (var i = 0; i <= 2; i++) {
      const selected = selectedSpotsFromQuery[i];
      if (selected) {
        const spotTypeData = getSpotTypeDataFromContext(selected);
        var thisSpotData = {};
        thisSpotData["text"] = spotTypeData[0];
        thisSpotData["color"] = spotTypeData[1];
        thisSpotData["total"] = availability[selected]
          ? availability[selected]["Total"]
          : 0;
        totalSpacesForThisSelection += thisSpotData["total"];
        thisSpotData["open"] = availability[selected]
          ? availability[selected]["Open"]
          : 0;

        if (thisSpotData["total"] == 0) {
          thisSpotData["percent"] = 0;
          thisSpotData["percentText"] = "NA";
        } else {
          var percent = Math.floor(
            100 *
              ((thisSpotData["total"] - thisSpotData["open"]) /
                thisSpotData["total"])
          );
          thisSpotData["percent"] = percent;
          thisSpotData["percentText"] = percent.toString() + "%";
        }
        userSpotData[selected] = thisSpotData;
        numSpotsSelected++;
      }
    }

    res.render("parking", {
      lotName: lotName,
      lotContext: lotContext,
      totalSpaces: totalSpacesForThisSelection,
      userSpotData: userSpotData,
      isHistoric: isHistoric,
      numSpotsSelected: numSpotsSelected,
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

//Gets color, key
function getSpotTypeDataFromContext(spotType) {
  for (var i = 0; i < spot_type_data.length; i++) {
    if (spot_type_data[i].key == spotType) {
      return [spot_type_data[i].text, spot_type_data[i].color];
    }
  }
}
// module.exports.handler = serverless(app);
exports.app = functions.https.onRequest(app);
