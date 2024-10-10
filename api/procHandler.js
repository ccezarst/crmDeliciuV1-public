const logger = require("./logger")
// PROC IS SHORT FOR PROCCESS IF YOU'RE WONDERING
let procArray = {}

// these are the statuses i will use:
//   init -> when the proccess is initialising
//   working -> while the proccess is handling the request
//           -> in case of working, the following info values may be present:
//                                         -> x,y:
//                                             -> has done x actions of y total count
//   done -> after it has finnished working
//        -> the info value is going to be set to the result of the route

function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

// TODO: RESET PROC ARRAY AFTER A DAY

module.exports = {
    // i use this proccess aproach to be able to have loading statuses and more, along with easier tracking and logging of functions
    // basically i allow the app to show a loading screen
    createProc: async function () {
        // create a random procID and make sure that it isn't already present in procArray
        const procID = getRandomInt(10000000000)
        while (procID in procArray) {
            procID = getRandomInt(10000000000)
        }
        procArray[procID] = {
            "status": "init",
            "info": ""
        };
        logger.announce("Created a new proccess with Proccess ID: " + procID)
        return procID;
    },
    updateProcStatus: async function (procID, newStatus, newInfo = "") {
        if (procID != undefined && procID != "" && newStatus != undefined) {
            // set the proccesses new status and info
            procArray[procID] = {
                "status": newStatus,
                // if new info wasn't specified, then don't set new info
                "info": (newInfo == "") ? procArray[procID]["info"] : newInfo
            }
        } else {
            logger.announceError("Undefined parameters passed to updateProcStatus")
            throw "Undefined parameters passed to updateProcStatus";
        }
    },
    getProcInfo: async function (procID) {
        if (procID != undefined && procID != "") {
            return procArray[procID]
        } else {
            logger.announceError("Incorrect parameters passed to getProcInfo")
            throw "Incorrect parameters passed to getProcInfo";
        }
    },
    deleteProc: async function (procID) {
        if (procID != undefined && procID != "") {
            delete procArray[procID];
            logger.announce("Deleted a proccess with Proccess ID: " + procID)
        } else {
            logger.announceError("Incorrect parameters passed to deleteProc")
            throw "Incorrect parameters passed to deleteProc";
        }
    },
}