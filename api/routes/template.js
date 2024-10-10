module.exports = {
    // boillerplate for other routes :)
    // if someone other than my retarded ass reading this
    // and don't know how this shet works
    // just look at other files
    IGNORE_FILE: function () { 
        // so that this file is skipped because this has no valid routes
        // IGNORE_FILE can be a function a variable it can be anything as long as it's
        // value isn't "undefined"
    },
    Route: class {
        constructor(route) {
            this.route = route;
        }
        get path(){
            return this.route;
        }
        async GET(req, res) { res.sendStatus(400) }
        async POST(req, res) { res.sendStatus(400) }
        async PUT(req, res) { res.sendStatus(400) }
        async DELETE(req, res) { res.sendStatus(400) }
        async HEAD(req, res) { res.sendStatus(400) }
        async CONNECT(req, res) { res.sendStatus(400) }
        async OPTIONS(req, res) { res.sendStatus(400) }
        async TRACE(req, res) { res.sendStatus(400) }
        async PATCH(req, res) { res.sendStatus(400) }
    }
}