"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.api = void 0;
/* eslint-disable */
const express = require("express");
const functions = require("firebase-functions");
const firebase_admin_1 = require("firebase-admin");
// import * as firebase from "firebase-admin";
// const admin = firebase;
firebase_admin_1.initializeApp();
const runtimeOpts = {
    timeoutSeconds: 300,
    memory: '1GB'
};
const apiNode = require("./src/api");
const main = express().use('/', apiNode);
exports.api = functions.runWith(runtimeOpts).region("us-central1").https.onRequest(main);
// export const weekdayReminder =  functions.pubsub.schedule('0 8 * * 1-5').onRun(async (context) => {
// 	return await admin.messaging().send({
// 		topic: 'workday',
// 		data: {},
// 		notification: {
// 			title: "Erinnerung",
// 			body: "Bitte denken Sie an die Klingel!",
// 		},
// 	});
//   });
//   export const saturdayReminder =  functions.pubsub.schedule('0 8 * * 6').onRun(async (context) => {
// 	return await admin.messaging().send({
// 		topic: 'weekend',
// 		data: {},
// 		notification: {
// 			title: "Erinnerung",
// 			body: "Bitte denken Sie an die Klingel. Schönes Wochenende!",
// 		},
// 	});
//   });
//# sourceMappingURL=index.js.map