/* eslint-disable */ 
import * as express from "express";
import * as functions from "firebase-functions";
import {initializeApp} from "firebase-admin";

initializeApp();

const runtimeOpts: any = {
	timeoutSeconds: 300,
	memory: '1GB'
  }

import { apiNode } from "./api";
const main = express()
main.use("/api", apiNode);

export const webApi = functions.runWith(runtimeOpts).region("europe-west3").https.onRequest(main);