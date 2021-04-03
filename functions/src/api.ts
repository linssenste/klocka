/* eslint-disable */
import * as express from "express";
import { registerCompany, createSticker, ring, checkExistence, login } from "./api-handler"

// const slowDown = require("express-slow-down");


// const ringLimiter = slowDown({
// 	windowMs: 1 * 60 * 1000, // 15 minutes
// 	delayAfter: 5, // allow 100 requests per 15 minutes, then...
// 	delayMs: 5000
// });

export const apiNode = express();

// API nodes

// -- GET: 
apiNode.get("/ring/:id", ring); // see API Doc: (digital) ring
apiNode.get("/sticker/create", createSticker); // see API Doc: Create QR-Codes
apiNode.get("/exists/:id", checkExistence); // see API Doc: QR-Code exists

// -- POST:
apiNode.post("/register/:id", registerCompany); // see API Doc: Register Company
apiNode.post("/auth/:id", login); // see API Doc: Authenticate QR-Code





