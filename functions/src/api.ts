import * as express from "express";
import * as firebase from "firebase-admin";
import {animalNames} from "./names"

import axios from 'axios'

const admin = firebase;

const db = firebase.firestore();

export const app = express();

app.get("/ring/:id", async (req, res) => {
	console.log(animalNames)
	console.log("LEN", animalNames.length)
  const localReference = db.collection("Lokale").doc(req.params.id);

  const docHandle = await localReference.get();

  if (!docHandle.exists) {
    res.send(`Oh, Klingel ${req.params.id} existiert nicht`);
  } else {
    await admin.messaging().send({
      topic: req.params.id,
      data: {},
      notification: {
        title: "Klinglen betätigt!",
        body: "Bitte die Tür öffnen",
      },
      android: {
        notification: {
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },

    });
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


app.get("/qrcode", async (req, res) => {
	const getIdentifier = () => {return animalNames[Math.floor(Math.random() * animalNames.length)]}
	const qrCodeSize = 200
	let qrCodeUrl: string;
	let identifier: string;

	let created: Boolean = false
	let retry: number = 0

	while (!created && retry < 10) {
		identifier = `${getIdentifier()}-${getIdentifier()}-${getIdentifier()}`
		qrCodeUrl = `https://ring.linssenste.com/${identifier}`

		const codeReference = db.collection("codes").doc(identifier);
		const docHandle = await codeReference.get();

		if (!docHandle.exists) {
			await db.collection("codes").doc(identifier).set({
				created: (+ new Date()), 
				url: qrCodeUrl, 
				size: qrCodeSize, 
			});
			console.log("CREATED!")
			created = true;
			break;

		} else {
			retry += 1
		}
	}
	

	let url = `http://api.qrserver.com/v1/create-qr-code/?data=${qrCodeUrl}&size=${qrCodeSize}x${qrCodeSize}`

	const reqResult = await axios.get(url,  {responseType: 'arraybuffer'})
	let imageData = Buffer.from(reqResult.data, 'binary').toString('base64')
	imageData = `data:${reqResult.headers['content-type'].toLowerCase()};base64,${imageData}`;
	db.collection("codes").doc(identifier).set({base64: imageData});
	return res.send(imageData);

  });


