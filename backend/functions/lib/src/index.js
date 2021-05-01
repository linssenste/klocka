"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.webApi = void 0;
/* eslint-disable */
const express = require("express");
const functions = require("firebase-functions");
const firebase_admin_1 = require("firebase-admin");
firebase_admin_1.initializeApp();
const api_1 = require("./api/api");
const main = express();
main.use('/', api_1.apiNode);
exports.webApi = functions.region("us-central1").https.onRequest(main); //.runWith(runtimeOpts)
//# sourceMappingURL=index.js.map