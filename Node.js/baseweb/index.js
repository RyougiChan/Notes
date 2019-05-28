const server = require('./server');
const router = require('./router');
const requestHanders = require('./requestHanders');

let handle = {};
handle["/"] = requestHanders.start;
handle["/start"] = requestHanders.start;
handle["/upload"] = requestHanders.upload;
handle["/show"] = requestHandlers.show;
server.start(router.route, handle);