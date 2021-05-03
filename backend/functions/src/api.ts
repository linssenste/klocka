/* eslint-disable */
import * as express from "express";
import { registerCompany, createSticker, ring, checkExistence, login } from "./api.methods"

export const apiNode = express.Router();

// API nodes
// -- GET: 
apiNode.get("/ring/:id", ring); // see API Doc: (digital) ring
apiNode.get("/sticker/create", createSticker); // see API Doc: Create QR-Codes
apiNode.get("/exists/:id", checkExistence); // see API Doc: QR-Code exists

// -- POST:
apiNode.post("/register/:id", registerCompany); // see API Doc: Register Company
apiNode.post("/auth/:id", login); // see API Doc: Authenticate QR-Code


module.exports = apiNode;


