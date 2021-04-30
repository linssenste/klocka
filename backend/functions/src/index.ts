/* eslint-disable */ 
import * as express from "express";
import * as functions from "firebase-functions";
import {initializeApp} from "firebase-admin";
// import * as firebase from "firebase-admin";

// const admin = firebase;

initializeApp();
console.log("ININIININININININININININININININ")

// const runtimeOpts: any = {
// 	timeoutSeconds: 300,
// 	memory: '1GB'
//   }

import { apiNode } from "./api/api";
const main = express()

main.use('/', apiNode);

export const api = functions.region("us-central1").https.onRequest(main); //.runWith(runtimeOpts)
