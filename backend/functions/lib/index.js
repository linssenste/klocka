"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/* eslint-disable */
const express = require("express");
const functions = require("firebase-functions");
const firebase_admin_1 = require("firebase-admin");
firebase_admin_1.initializeApp();
const runtimeOpts = {
    timeoutSeconds: 300,
    memory: '1GB'
};
const api_methods_1 = require("./src/api/api.methods");
const api = express();
// API nodes
// -- GET: 
api.get("/ring/:id", api_methods_1.ring); // see API Doc: (digital) ring
api.get("/sticker/create", api_methods_1.createSticker); // see API Doc: Create QR-Codes
api.get("/exists/:id", api_methods_1.checkExistence); // see API Doc: QR-Code exists
// -- POST:
api.post("/register/:id", api_methods_1.registerCompany); // see API Doc: Register Company
api.post("/auth/:id", api_methods_1.login); // see API Doc: Authenticate QR-Code
exports.api = functions.runWith(runtimeOpts).region("us-central1").https.onRequest(api); //.runWith(runtimeOpts)
//# sourceMappingURL=index.js.map