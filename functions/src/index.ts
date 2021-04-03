/* eslint-disable */ 
import * as express from "express";
import * as functions from "firebase-functions";
import {initializeApp} from "firebase-admin";

initializeApp();


import { apiNode } from "./api";
const main = express().use("", apiNode);

export const api = functions.region("europe-west3").https.onRequest(main);