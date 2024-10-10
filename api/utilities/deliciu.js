const axios = require('axios');
const logger = require("../logger")
const fs = require('fs')
const xlsx = require('node-xlsx');
let providersLookupTable = {};
fs.readFile("./config.json", "utf8", (err, jsonString) => {
    if (err) {
        logger.announceError("Error reading config file")
        logger.announceError("Error thrown by utillities/deliciu.js")
        throw "Error reading config file!";
    } else {
        try {
            configsJSON = JSON.parse(jsonString)
            let temp = xlsx.parse(configsJSON["siteSettings"]["providersFileLocation"]);
            temp = temp[0]["data"]
            providersLookupTable = {}
            temp.forEach((value) => {
                let productSKU = value[0]
                let productProvider = value[9];
                let comestibil = value[6]
                providersLookupTable[productSKU] = [productProvider, comestibil];
            })
        } catch (err) {
            logger.announceError("Failed to read providers file")
            logger.announceError(err)
        }
    }
})

function customParseInt(str) {
    // Check if the string contains any non-numeric characters
    if (/[^0-9]/.test(str)) {
        return NaN;
    }

    // If it only contains numeric characters, parse it as an integer
    return parseInt(str, 10);
}


module.exports = {
    //sad that i can't use named parameters to make the code easier to read :(
    getInfo: async function (path, acessToken, params) {
        try {
            // had an if function here but decided to scrap
            // cuz the networking lib is going to check for params
            // and see that it is undefined so it's going to think
            // that i didn't pass a value
            let result = await axios.get(path, {
                headers: {
                    "Apikey": acessToken
                },
                params: params
            },)
            if (result != undefined && result != null) {
                return result;
            } else {
                logger.announceError("Encountered error when making a request to DeliciuDeCiocolata")
                logger.announceError("Error encountered at function getInfo")
                logger.announceError("Result variable was undefined/null")
                throw "Result has invalid state";
            }
            return result;
        } catch (err) {
            // had a retarded bug where the error didn't get passed upwards
            // so i had two different errors and i didn't know why
            // now i do💀
            logger.announceError(err)
            throw err;
        }
    },
    getProductProvider: function (productSKU) {
        try {
            let result = providersLookupTable[productSKU];
            if (result != undefined) {
                return providersLookupTable[productSKU];
            } else {
                return [
                    "NU AM GASIT",
                    "NU AM GASIT"
                ]
            }
        } catch (err) {
            logger.announceError(err);
            return "NU GASIT"
        }
    },
    getNovapanOrders: function (path) { 
        try {
            let temp = xlsx.parse(path);
            temp = temp[0]["data"]
            NovaPanOrders = {}
            temp.forEach((value) => {
                let productSKU = value[3];
                // get rid of retarded 0 before sku
                let newSKU = customParseInt(productSKU + "") + ""
                if (newSKU != NaN && newSKU != "NaN") {
                    productSKU = newSKU;
                }
                let quantity = value[4];
                let date = value[8]
                if (NovaPanOrders[productSKU] != undefined) {
                    NovaPanOrders[productSKU] = parseInt(quantity) + parseInt(NovaPanOrders[productSKU])
                } else {
                    NovaPanOrders[productSKU] = quantity
                }
            })
            return NovaPanOrders;
        } catch (err) {
            logger.announceError(err);
            logger.announceError("FUCK YOU NODEJS")
        }
    }
}
