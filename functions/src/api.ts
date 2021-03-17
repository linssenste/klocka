import * as express from "express";
import * as firebase from "firebase-admin";
// const admin = firebase

const db = firebase.firestore();

export const app = express();

app.get("/ring/:id", async (req, res) => {
  const localReference = db.collection("Lokale").doc(req.params.id);

  const docHandle = await localReference.get();

  if (!docHandle.exists) {
    res.send(`Oh, Klingel ${req.params.id} existiert nicht`);
  } else {
    res.send(`RING: ${req.params.id}`);
  }
  // check if ID exists; if not: empty webseite; else: full website!
});


app.post("/register/:id", async (req, res) => {
  const localReference = db.collection("Lokale").doc(req.params.id);

  const docHandle = await localReference.get();
  if (!docHandle.exists) {
    await db.collection("Lokale").doc(req.params.id).set(req.body);
    return res.send(`Successfully registered ${req.params.id}`);
  } else {
    return res.status(403).send("Lokal already exists");
  }
});


