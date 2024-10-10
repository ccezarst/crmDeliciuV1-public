const logger = require("../logger")
const procHandler = require("../procHandler")
const siteActions = require("../utilities/deliciu")
const nextUpActions = require("../utilities/nextUp")
const csv = require("csv2json");
const date_ob = new Date();
const template = require("./template")
const cofetarulIstet = {
    fileToCSV: async function (rawFileData) {
        let jsonFileData = await csv().fromString(rawFileData)
        console.log(jsonFileData)
    }
}

// this in my opinion is a bettter way of organazing
// cuz i can do deliciu.someFunction
const deliciu = {
    getWithStatusID: async function (statusID, basePath, accessToken, initialMap) {
        try {
            if (statusID != undefined) {
                //  Accepted parameters
                // {
                //  "date": "Data comanda",
                //  "startDate": "Comanda inregistrata dupa data",
                //  "endDate": "Comanda inregistrata inainte de data",
                //  "number": "Numar comanda",
                //  "statusIds": "Id status comanda",
                //  "customer": "Client",
                //  "updated": "Data ultimei modificari",
                //  "page": "Pagina"
                // }
                let pages = 1
                // if param is passed then set it to param
                // if not set it to blank object
                let allProductsOrdered = initialMap != undefined ? initialMap : {};
                // i is equal to 1 because the index starts at 1 not zero
                // loop through the pages
                for (let i = 1; i <= pages; i++){
                    // request the current page
                    let result = await siteActions.getInfo(
                        basePath + "order/read/json",
                        accessToken,
                        {
                            "statusIds": statusID,
                            "page": i,
                            "startDate": date_ob.getFullYear() + "-00-00"
                        }
                    )
                    logger.announce("Just sent a request to " + basePath + "order/read/json")
                    let decodedData = result.data
                    let orders = decodedData["orders"]
                    let ordersSeen = []
                    pages = decodedData["pages"]
                    // loop through the orders
                    for (const orderID in orders) {
                        let orderNumber = orders[orderID]["number"];
                        if (!(orderNumber in ordersSeen)) {
                            ordersSeen.push(orderNumber)
                            const items = orders[orderID]["items"]
                            // loop through the items inside an order
                            for (let i = 0; i < items.length; i += 1) {
                                allProductsOrdered[items[i]["sku"]] = {
                                    "name": items[i]["name"],
                                    "productsOrdered": (items[i]["sku"] in allProductsOrdered) ?
                                    allProductsOrdered[items[i]["sku"]]["productsOrdered"] += parseInt(items[i]["quantity"]) : 
                                        parseInt(items[i]["quantity"]),
                                    "nextUpStock": 0,
                                    "stockAfterPackaging": (items[i]["sku"] in allProductsOrdered) ?
                                    allProductsOrdered[items[i]["sku"]]["stockAfterPackaging"] += parseInt(items[i]["quantity"]) : 
                                        parseInt(items[i]["quantity"]),
                                }
                            }
                        }
                    }
                }
                // turner operation that checks if initialMap param was passed
                // if not then set allProductsORdered to {}
                // if it was specified then set allProductsOrdered to the initialMap

                return allProductsOrdered;
            } else {
                logger.announceError("getWithStatusID called with no statusID provided!")
                throw "getWithStatusID called with no statusID provided!"
            }
        } catch (err) {
            // log the error then pass it to the func that called this func
            // so that it basically send status 400 or the error gets handled some way
            // but now that i think about it maybe i could get rid of the try catch statement
            // and just let the error reach the first try catch statement that it finds
            // but i wanna be extra safe :)
            logger.announceError("At func getWithStatusID: " + err)
            throw "At func getWithStatusID: " + err;
        }

    }
}

const nextUp = {
    securityToken: 0,
    login: async function () {
        securityToken = await nextUpActions.login()
    },
    getArticleStock: async function (ArticleCode, WarehouseName) {
        // get the article from NextUp
        const productJSON = await nextUpActions.getArticle(securityToken, ArticleCode)
        if (productJSON == null) {
            return 0
        } else {
            // loop through Warehouses
            const Warehouses = productJSON["ArticlesWarehouseStocks"]
            if (Warehouses == null) {
                return 0;
            }
            for (const warehouse of Warehouses) {
                if (warehouse["WarehouseName"] == WarehouseName) {
                    return warehouse["StockQuantity"];
                }
            }
        }
    }
}


module.exports = {

    getRequiredProducts: class extends template.Route {
        constructor() {
            const route = "products/getRequired"
            super(route);
        }
        async GET(req, res) {
            try {
                const siteAddress = req.configs["siteSettings"]["address"]
                const acessToken = req.configs["siteSettings"]["auth"]["clientsAndOrdersToken"]
                const getStatuses = req.configs["siteSettings"]["getStatuses"]
                const warehouseName = req.configs["nextUpSettings"]["currentWarehouseName"]
                const NovaPanOrdersFile = req.headers["novapanpath"]
                const currentProcID = req.procID;
                let NovaPanOrders;
                if (NovaPanOrdersFile != undefined && NovaPanOrdersFile != null && NovaPanOrdersFile != "") {
                    if (NovaPanOrdersFile == "debug") {
                        NovaPanOrders = siteActions.getNovapanOrders("\\\\22.25.28.6\\all\\04. Comenzi Furnizori\\Comenzi la NovaPan\\comenzi.csv")
                    } else {
                        NovaPanOrders = siteActions.getNovapanOrders("/volume2/ALL/04. Comenzi Furnizori/Comenzi la NovaPan/comenzi.csv")
                    }
                }
                let productsThatWereOrdered = {}
                // get all of the orders with each status specified in config.json
                for (const status of getStatuses) {
                    productsThatWereOrdered  = await deliciu.getWithStatusID(status, siteAddress, acessToken, productsThatWereOrdered)
                } 
                // login into nextUp
                await nextUp.login()
                const productsCount = Object.keys(productsThatWereOrdered).length;
                let currentWorkingProduct = 0;
                procHandler.updateProcStatus(currentProcID, "working", "0," + productsCount)
                //send the current proccess ID after loading from deliciu
                res.status = 200;
                res.send(currentProcID.toString())
                // get every products stock in nextUp
                for (const productSKU in productsThatWereOrdered) {
                    currentWorkingProduct += 1;
                    procHandler.updateProcStatus(currentProcID, "working", currentWorkingProduct + "," + productsCount)
                    const stock = await nextUp.getArticleStock(productSKU, warehouseName)
                    productsThatWereOrdered[productSKU]["nextUpStock"] = stock;
                    productsThatWereOrdered[productSKU]["stockAfterPackaging"] = stock - productsThatWereOrdered[productSKU]["stockAfterPackaging"] 
                    productsThatWereOrdered[productSKU]["productProvider"] = siteActions.getProductProvider(productSKU)[0];
                    productsThatWereOrdered[productSKU]["consumable"] = siteActions.getProductProvider(productSKU)[1];
                    if (NovaPanOrdersFile != undefined && NovaPanOrdersFile != null && NovaPanOrdersFile != "") {
                        if (NovaPanOrders[productSKU] != undefined) {
                            productsThatWereOrdered[productSKU]["orderedNovaPan"] = NovaPanOrders[productSKU] + "";
                            productsThatWereOrdered[productSKU]["stockAfterPackaging"] = parseInt(productsThatWereOrdered[productSKU]["stockAfterPackaging"]) + parseInt(NovaPanOrders[productSKU])
                        }
                    }
                }
                procHandler.updateProcStatus(currentProcID, "done", productsThatWereOrdered)
            } catch (err) { 
                logger.announceError(err, req)
                res.sendStatus(500)
            }
        }
    },
}