const axios = require('axios');
const logger = require("../logger")
const fs = require('fs')
let nextUpUsername;
let nextUpPassword;
let nextUpDatabase;
let nextUpServerIP;
let nextUpServerPort;
let standardPath
fs.readFile("./config.json", "utf8", (err, jsonString) => {
    if (err) {
        logger.announceError("Error reading config file")
        logger.announceError("Error thrown by utillities/nextUp.js")
        throw "Error reading config file!";
    } else {
        configsJSON = JSON.parse(jsonString)
        configsJSON = configsJSON["nextUpSettings"]
        nextUpUsername = configsJSON["auth"]["username"]
        nextUpPassword = configsJSON["auth"]["password"]
        nextUpDatabase = configsJSON["auth"]["database"]
        nextUpServerIP = configsJSON["ip"]
        nextUpServerPort = configsJSON["port"]
        standardPath = "http://" + nextUpServerIP + ":" + nextUpServerPort + "/NextUpServices/msc/POST";
    }
})

module.exports = {
    login: async function () {
        // copy pasting code from deliciu.js
        // getting the auth token from the api
        const body = {
            "Method": "GetAuthenticationToken",
            "Params": {
                "UserName": nextUpUsername,
                "Password": nextUpPassword,
                "Database": nextUpDatabase
            }
        }
        let result = await axios({
            method: "post",
            url: standardPath,
            headers: {
                // REMEMBER TO SET CONTENT-TYPE TO TEXT/PLAIN
                // OTHERWISE YOU'RE GOING TO GET 400 RESPONSE STATUS
                "content-type": "text/plain "
            },
            data: body
        })
        // makes it easier to read
        const decodedData = result.data;
        if (decodedData["Error"] == null) {
            return decodedData["Result"]
        } else {
            logger.announceError("Error thrown from NextUp login function")
            logger.announceError("Failed to get auth token from NextUp")
            logger.announceError("Params were: ")
            logger.announceError("Username: " + nextUpUsername)
            logger.announceError("Password: " + nextUpPassword)
            logger.announceError("Database: " + nextUpDatabase)
            logger.announceError("NextUp returned: " + decodedData["Error"])
            throw "Failed to login to NextUp";
        }
    },
    // GetArticleByCode
    // • code: Parametru obligatoriu de tip string unde se completeaza codul articolului
    // • excludeArticlesWithBatch: Parametru optional de tip boolean. Daca se seteaza cu true se vor exclude articolele
    // care au lot.
    // • includeArticleWarehousePrice: Parametru optional de tip boolean. Valoare ne spune daca trebuie aduse si
    // informatiile despre pretul pe depozite.
    // • includeArticleWarehouseStock: Parametru optional de tip boolean. Valoare ne spune daca trebuie adus si stocul
    // pe depozite.
    // • includeOnlyArticlesForMobileDevice: Parametru optional de tip boolean. Daca se seteaza pe true atunci va aduce
    // doar articolele specifice dispozitivelor mobile.
    // • stockDate: Parametru optional de tip data. Reprezinta data la care se doreste obtinerea informatiilor despre stoc.
    // Daca este nula atunci se va aduce la data curenta. Data trebuie sa fie in formatul yyyy-MM-dd.
    // • NCCode: – returneaza codul NC de pe fisa articol; daca nu este completat va returna null.
    getArticle: async function (acessToken, productCode) {
        // axios({
        //     method: "post",
        //     url: standardPath,
        //     headers: {
        //         "content-type": "text/plain "
        //     },
        //     data: body
        // })
        const body = {
                "AuthenticationToken": acessToken,
                "Method": "GetArticleByCode",
                "Params": {
                    "code": productCode,
                    "includeArticleWarehouseStock": true,
                }
            }
        let result = await axios({
            method: "post",
            url: standardPath,
            data: body,
            headers: {
                // REMEMBER TO SET CONTENT-TYPE TO TEXT/PLAIN
                // OTHERWISE YOU'RE GOING TO GET 400 RESPONSE STATUS
                "content-type": "text/plain",
            }
        })
        const decodedData = result.data;
        if (decodedData["Error"] == null) {
            return decodedData["Result"]
        } else {
            logger.announceError("Error thrown from NextUp getArticle function")
            logger.announceError("Failed to get article from NextUp")
            logger.announceError("Params were: ")
            logger.announceError("Article code: " + productCode)
            logger.announceError("Auth token: " + acessToken)
            logger.announceError("NextUp returned: " + decodedData["Error"])
            throw "Failed to get Article from NextUp";
        }
    }
}