/* eslint-disable */ 
import * as express from "express";
import * as functions from "firebase-functions";
import {initializeApp} from "firebase-admin";

initializeApp();

const runtimeOpts: any = {
	timeoutSeconds: 300,
	memory: '1GB'
  }

import { registerCompany, createSticker, ring, checkExistence, login } from "./src/api/api.methods"

const api = express();

// API nodes
// -- GET: 
api.get("/ring/:id", ring); // see API Doc: (digital) ring
api.get("/sticker/create", createSticker); // see API Doc: Create QR-Codes
api.get("/exists/:id", checkExistence); // see API Doc: QR-Code exists

// -- POST:
api.post("/register/:id", registerCompany); // see API Doc: Register Company
api.post("/auth/:id", login); // see API Doc: Authenticate QR-Code


exports.api= functions.runWith(runtimeOpts).region("us-central1").https.onRequest(api); //.runWith(runtimeOpts)