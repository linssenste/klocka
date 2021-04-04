/* eslint-disable */ 
import * as express from "express";
import * as functions from "firebase-functions";
import {initializeApp} from "firebase-admin";
import * as firebase from "firebase-admin";

const admin = firebase;

initializeApp();

const runtimeOpts: any = {
	timeoutSeconds: 300,
	memory: '1GB'
  }

import { apiNode } from "./src/api";
const main = express().use("", apiNode);

export const api = functions.runWith(runtimeOpts).region("us-central1").https.onRequest(main);

export const weekdayReminder =  functions.pubsub.schedule('0 8 * * 1-5').onRun(async (context) => {
	return await admin.messaging().send({
		topic: 'workday',
		data: {},
		notification: {
			title: "Erinnerung",
			body: "Bitte denken Sie an die Klingel!",
		},

	});
  });

  export const saturdayReminder =  functions.pubsub.schedule('0 8 * * 6').onRun(async (context) => {
	return await admin.messaging().send({
		topic: 'weekend',
		data: {},
		notification: {
			title: "Erinnerung",
			body: "Bitte denken Sie an die Klingel. Schönes Wochenende!",
		},

	});
  });