const logger = require("./logger")
const mainFile = require("./index")
const procHandler = require("./procHandler")
let configsJSON;
let securityToken = undefined
const fs = require("fs")
fs.readFile("./config.json", "utf8", (err, jsonString) => {
    if (err) {
    } else {
        configsJSON = JSON.parse(jsonString)
        securityToken = configsJSON["serverSettings"]["auth"]["accessToken"];
    }
})
// i will set a property of req to the config string
// so that any route can access it
module.exports = async function (req, res, next) {
    try {
        if (securityToken != "") {
            if (req.headers["token"] == securityToken) {
                logger.announce("Accessed the API : " + req.originalUrl.split('?')[0], req)
                req.configs = configsJSON
                const procID = await procHandler.createProc();
                req.procID = procID;
                next();
            } else {
                res.status = 400;
                res.send("INVALID AUTH TOKEN!")
                logger.announceError("Failed to access the API", req)
            }
        } else {
            res.sendStatus(500);
            console.log("Please specify a security token in config.json")
            logger.announceError("Please specify a security token in config.json")
            throw "Please specify a security token in config.json";
        }
    } catch (err) {
        logger.announceError(err, req)
        res.sendStatus(400)
    }
}