// TODO: ADD ERROR CHECKING LIBRARY THAT AUTOMATICALLY CHECKS ANY FUNCTION SPECIFIED FOR ERRORS

const express = require("express");
const app = express();
const fs = require("fs")
const logger = require("./logger")
const customMiddleware = require("./middleware")
const routeTemplate = require("./routes/template")
app.use(customMiddleware)
app.use(express.urlencoded({ extended: true }))

function isClass(variable) {
    return typeof variable === 'function' && variable.prototype && variable.prototype.constructor === variable;
}

async function readConfigs(configJson) {
    const serverPort = configJson["serverSettings"]["port"]
    module.exports = {
        configJSON: configJson,
    }
    logger.announce("Mapping routes...")
    // map routes
    // i would document this but i forgor how i did this😭
    const routesFiles = await fs.readdirSync("./routes")
    let routeFiles = {}
    for (const routeFile of routesFiles) {
        // make sure is javascript file
        if (routeFile.includes(".js")) {
            // get only the file name and import it
            const newInclude = require("./routes/" + routeFile.split(".")[0])
            // so that files like template.js get skipped
            // this value can be defined however u want
            if (newInclude["IGNORE_FILE"] == undefined) {
                for (const value of Object.values(newInclude)) {
                    // make sure this is a route and nuthin else
                    if (isClass(value)) {
                        const valueInstance = new value()
                        if (valueInstance instanceof routeTemplate.Route) {
                            const routePath = "/api/" + valueInstance.path;
                            app.post(routePath, valueInstance.POST)
                            app.get(routePath, valueInstance.GET)
                            app.put(routePath, valueInstance.PUT)
                            app.connect(routePath, valueInstance.CONNECT)
                            app.head(routePath, valueInstance.HEAD)
                            app.delete(routePath, valueInstance.DELETE)
                            app.trace(routePath, valueInstance.TRACE)
                            app.patch(routePath, valueInstance.PATCH)
                            app.options(routePath, valueInstance.OPTIONS)
                            console.log(valueInstance)
                        }
                    }
                }
            }
        }
    }
    logger.announce("Mapped routes!")
    logger.announce("Starting server...")
    var server = app.listen(serverPort, function () {
        logger.announce("Server has started on port " + serverPort)
    })
}
logger.announce("---THE API IS STARTING--")
fs.readFile("./config.json", "utf8", (err, jsonString) => {
    if (err) {
        logger.announceError("Failed to read config file :(")
    } else {
        logger.announce("Read config file!")
        readConfigs(JSON.parse(jsonString))
    }
})