import * as functions from "firebase-functions";
import {initializeApp} from "firebase-admin";

initializeApp();

import * as express from "express";
import {app} from "./api";

const main = express();

main.use("/api/v1", app);


export const webApi = functions.region("europe-west3").https.onRequest(main);
