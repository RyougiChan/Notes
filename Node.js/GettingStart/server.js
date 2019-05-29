const http = require('http');
const url = require('url');

const start = (route, handle) => {
    http.createServer((req, res) => {
        let pathname = url.parse(req.url).pathname;
        console.log('Request Received, pathname: ', pathname);
        route(handle, pathname, res, req);
    }).listen(8888);
    console.log('Server Started');
};

exports.start = start;