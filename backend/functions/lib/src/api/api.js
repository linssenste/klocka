"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.apiNode = void 0;
/* eslint-disable */
const express = require("express");
const api_methods_1 = require("./api.methods");
exports.apiNode = express.Router();
// API nodes
// -- GET: 
exports.apiNode.get("/ring/:id", api_methods_1.ring); // see API Doc: (digital) ring
exports.apiNode.get("/sticker/create", api_methods_1.createSticker); // see API Doc: Create QR-Codes
exports.apiNode.get("/exists/:id", api_methods_1.checkExistence); // see API Doc: QR-Code exists
// -- POST:
exports.apiNode.post("/register/:id", api_methods_1.registerCompany); // see API Doc: Register Company
exports.apiNode.post("/auth/:id", api_methods_1.login); // see API Doc: Authenticate QR-Code
module.exports = exports.apiNode;
//# sourceMappingURL=api.js.map