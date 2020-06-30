const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const app = express();

app.set("view engine", "ejs");

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));
// http://localhost:5000/parking?lot=Athena&spots=A,B,C,D
// http://localhost:5000/parking?lot=Athena
app.get("/parking", (req, res) => {
  if (req.query.lot) app.locals.lot = req.query.lot;
  else app.locals.lot = undefined;

  if (req.query.spots) {
    const spotTypes = req.query.spots.split(",");

    if (spotTypes[0]) {
      app.locals.spot0 = spotTypes[0];
    } else app.locals.spot0 = undefined;
    if (spotTypes[1]) {
      app.locals.spot1 = spotTypes[1];
    } else app.locals.spot1 = undefined;
    if (spotTypes[2]) {
      app.locals.spot2 = spotTypes[2];
    } else app.locals.spot2 = undefined;
  }

  res.render("parking");
});

exports.app = functions.https.onRequest(app);
