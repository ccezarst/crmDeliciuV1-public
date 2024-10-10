const logger = require("../logger")
const fs = require("fs")
const procHandler = require("../procHandler")
const template = require("./template")
let accessibleConfigs = {};
let allConfigs;
async function readConfigs(configs) {
    allConfigs = configs;
    let temp_accessibleConfigs = configs["serverSettings"]["userAccessableSettings"]
    for (config of temp_accessibleConfigs) {
        let configField = config[0]
        let configName = config[1]
        if (accessibleConfigs[configField] == null){
            accessibleConfigs[configField] = []
        }
        accessibleConfigs[configField].push(configName)
    }
}
async function restart() {
    fs.readFile("./config.json", "utf8", (err, jsonString) => {
        if (err) {
            logger.announceError("Failed to read config file :(")
        } else {
            readConfigs(JSON.parse(jsonString))
        }
    })
}

async function writeConfigs() {
    fs.writeFile("./config.json", JSON.stringify(allConfigs, null, 4), (err) => {
        if (err) {
            logger.announceError("Failed to write new config file :(")
        }
    })
}
// know the name is confusing but i'm not good at naming things
restart()
module.exports = {

    getSettings: class extends template.Route {
        constructor() {
            const route = "settings"
            super(route);
        }

        async GET(req, res) {
            try {
                let output = {}
                for (let field in accessibleConfigs) {
                    output[field] = {}
                    const settings = accessibleConfigs[field]
                    for (let setting of settings) {
                        const settingValue = allConfigs[field][setting]
                        output[field][setting] = settingValue
                    }
                }
                res.send(output);
                // delete the process as this returns its value normally
                // when i make docs about everything this will probably specified in there
            } catch (err) {
                logger.announceError(err, req);
                res.sendStatus(500);
            }
            procHandler.deleteProc(req.procID)
        }
    },

    setSetting: class extends template.Route {
        constructor() {
            const route = "settings/setOne"
            super(route);
        }
        async POST(req, res) {
            try {
                const fieldName = req.headers.field
                const settingName = req.headers.setting
                const newValue = JSON.parse(req.headers.value);
                allConfigs[fieldName][settingName] = newValue
                res.sendStatus(200)
                writeConfigs();
            } catch (err) {
                logger.announceError(err, req)
                res.sendStatus(500);
            }
            procHandler.deleteProc(req.procID)
        }
    },
    // WHEN A SETTING IS SET THE API RESTARTS WHILE USING NODEMON
}