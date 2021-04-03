/* eslint-disable */
import axios from 'axios'
import * as firebase from "firebase-admin";
import * as bcrypt from "bcrypt"

import {Request, Response} from "express"
import { animalNames } from "../assets/names"
import { RegisterCompany, QrCodeObject } from "./api.types"

const admin = firebase;
const db = firebase.firestore();
// const { mdToPdf } = require('md-to-pdf');


async function getCodeData(entryId: string) {
	const localReference = db.collection("codes").doc(entryId);
	return await localReference.get();
}

async function getDatabaseEntry(entryId: string) {
	const localReference = db.collection("Lokale").doc(entryId);
	return await localReference.get();
}


async function setDatabaseEntry(entryId: string, payload: Object) {
	try {
		await db.collection("Lokale").doc(entryId).set(payload);	
		return true;
	} catch (error) {
		console.debug(error)
		return false;
	}
}


/**
 * This function creates an identifier from three animal names. The animal names are stored in a JSON file in the project. 
 * (e.g. 'affe-blauwal-giraffe')
 * 
 * @returns string with identifer
 */
async function createIdentifier() {

	// function to retrieve random animal name as identifier
	const getIdentifier = () => { return animalNames[Math.floor(Math.random() * animalNames.length)] }
	
	const qrCodeSize: number = 200

	var created: Boolean = false
	var retryCounter: number = 0

	while (!created && retryCounter < 10) {

		try {
			// url identifier containing three animal names (easy access)
			var identifier: string = `${getIdentifier()}-${getIdentifier()}-${getIdentifier()}`
			var qrCodeUrl: string = `https://ring.linssenste.com/${identifier}`

			var responseData: QrCodeObject = {
				identifier: identifier,
				created: (+ new Date()),
				url: qrCodeUrl,
				size: qrCodeSize,
			}

			const codeReference = db.collection("codes").doc(identifier);
			const docHandle = await codeReference.get();

			if (!docHandle.exists) {
				return responseData;
			} else {
				retryCounter += 1
			}

		} catch (error) {
			console.debug(error)
			retryCounter += 1
		}
	}

	throw new Error('Error occured while creating QR-Code identifier'); 

}


/**
 * Check if the sticker (QR code ID) is stored in the database. In addition, it is checked whether a local is 
 * already registered on the sticker, if so, then the user must enter the password to obtain the data. Otherwise, the 
 * user can register the pub again. 
 * 
 * @returns status of existence (http stati)
 */
export async function checkExistence(req: Request, res: Response) {
	console.log("CHECK EXISTENCE!")
	// Verification if register ID is existent; the QR-Code has to be saved in the database
	if (!(await getCodeData(req.params.id)).exists) {
		return res.status(404).send({message: "QR-Code ID does not exist. ok?"});
	}

	// Checking whether ID is already registered.
	if ((await getDatabaseEntry(req.params.id)).exists) {
		return res.status(401).send({message: "ID is already registered."})
	} else {
		return res.status(200).send({message: "ID is free to be registered."})
	}
}


/**
 * If a sticker already exists, the user who is trying to set up the sticker can activate it on his smartphone by 
 * entering the sticker's password. 
 * 
 * @returns if successful, project data
 */
export async function login(req: Request, res: Response) {

	if (!req.body.password) {
		res.status(404).send('Password forgotten')
	}

	const docHandle = await getDatabaseEntry(req.params.id)

	if (docHandle != undefined && docHandle.exists) {

		var companyData = docHandle.data()

		if ((await bcrypt.compare(req.body.password, companyData.password)) == true) {
			delete companyData.password
			return res.status(200).send(docHandle.data())
		} else {
			return res.status(401).send({message: 'Password does not match'})
		}
	} else {
		return res.status(404).send({message: 'QR-Code does not exist. Please try another ID.'})
	}
}


export async function ring(req: Request, res: Response) {
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
						sound: "bell_sound.wav",
					},
				},
			},

		});

		// res.send(`RING: ${req.params.id}`);
		if (docHandle.data().website) {
			res.redirect(docHandle.data().company.website)
		} else {
			res.send("Es wurde geklingelt.")
		}
	}
	// check if ID exists; if not: empty webseite; else: full website!
}



/**
 * In this function, a new unique ID is created (from three animal names), which in turn are converted into a QR code. 
 * A sticker is automatically created from this as a PDF. The code is stored in the database. 
 * 
 * @returns QR-Code Sticker (as PDF)
 */
export async function createSticker(req: Request, res: Response) {
	console.log("CREATE STICKER")

	var qrCodeData: QrCodeObject = await createIdentifier()
	console.log("CREATED!", qrCodeData)
	const apiUrl: string = `http://api.qrserver.com/v1/create-qr-code/?data=${qrCodeData.url}&size=${qrCodeData.size}x${qrCodeData.size}&ecc=H&`

	try {

		// reformat png response to base64 style
		const reqResult = await axios.get(apiUrl, { responseType: 'arraybuffer' })
		let imageData = Buffer.from(reqResult.data, 'binary').toString('base64')
		qrCodeData.base64 = `data:${reqResult.headers['content-type'].toLowerCase()};base64,${imageData}`;

		// update collection document with base64 image
		db.collection("codes").doc(qrCodeData.identifier).set(qrCodeData);

		//const pdf = await mdToPdf({ content: `\n# QR Code Pdf Placeholder\n\n\n\n<br/><br/>![QR-Code](${qrCodeData.base64})` })
		// let pdfData = Buffer.from(pdf.content, 'binary').toString('base64')


		//res.contentType("application/pdf");
		//res.setHeader('Content-Disposition', 'attachment; filename=quote.pdf');
		//return res.send(pdf.content);
		return res.send(qrCodeData.base64)

	} catch (error) {
		return res.status(500).send({message: 'Internal sever error occured. Please try again.'})

	}
}
 

/**
 * With this function, a user or local can re-register. Some information is required for this to be performed (see API Documentation for more information). 
 * During registration, the system checks whether the QR code is in the database (i.e. has been registered). 
 * 
 * @returns RegisterData
 */
export async function registerCompany(req: Request, res: Response) {
	
	// Verification that all necessary parameters to register a local have been specified. The request 
	// aborts if parameters are missing. 
	if (!req.body.password || !req.body.address || !req.body.address.city ||
		!req.body.address.zip || !req.body.address.street || !req.body.address.city ||
		!req.body.company || !req.body.company.name || !req.body.company.contact
	) {
		return res.status(400).send({ message: "Not all required parameters have been specified. Please refer to the API documentation to provide all the required parameters. " })
	}

	// Verification if register ID is existent; the QR-Code has to be saved in the database
	if (!(await getCodeData(req.params.id)).exists) {
		return res.status(404).send({message: "QR-Code ID does not exist."});
	}


	var registerData: RegisterCompany = req.body 

	// The password is stored hashed in the data bank. It is hashed with 10 salt sounds. 
	registerData.password = await bcrypt.hash(registerData.password, 10)

	const entryHandle = await getDatabaseEntry(req.params.id)

	// If the ID of the project already exists, this cannot be simply overwritten. For this you have to take 
	// another route. The request will then be aborted. 
	if (!entryHandle.exists) {
		
		// Data is written to the database
		if (await setDatabaseEntry(req.params.id, registerData) == true) {
			delete registerData.password
			return res.send(registerData)
		} else {
			return res.status(500).send({message: 'An internal server error occured while creating entry. Please try again.'})
		}

	} else {
		return res.status(406).send({message: `Project (ID: ${req.params.id}) already exists in the database. Please use the authentication function to access the resource.`});
	}
};
