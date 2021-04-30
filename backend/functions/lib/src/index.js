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
console.log("ININIININININININININININININININ");
// const runtimeOpts: any = {
// 	timeoutSeconds: 300,
// 	memory: '1GB'
//   }
const api_1 = require("./api/api");
const main = express();
main.use('/', api_1.apiNode);
exports.api = functions.region("us-central1").https.onRequest(main); //.runWith(runtimeOpts)
//# sourceMappingURL=index.js.map