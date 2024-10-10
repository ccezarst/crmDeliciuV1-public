const logger = require("../logger")
const procHandler = require("../procHandler")
const template = require("./template")
module.exports = {

    getProcStatus: class extends template.Route{
        constructor() {
            const route = "proccess/getStatus"
            super(route);
        }
        async GET(req, res) {
            try {
                const procID = req.headers["proccessid"]
                await procHandler.updateProcStatus(req.procID, "done")
                const result = await procHandler.getProcInfo(procID)
                if (result == undefined) {
                    res.sendStatus(500)
                } else {
                    res.send(result);
                }
                procHandler.deleteProc(req.procID);
            } catch (err) {
                logger.announceError(err)
                res.sendStatus(400)
            }
        }
    },
}