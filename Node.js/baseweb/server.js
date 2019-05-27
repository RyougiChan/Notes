const http = require('http');
const url = require('url');

const start = (route, handle) => {
    http.createServer((req, res) => {
        let pathname = url.parse(req.url).pathname;
        console.log('Request Received, pathname: ', pathname);
        route(handle, pathname);
        res.writeHead(200, {"Content-Type": "text/plain"});
        res.write('Hello World');
        res.end();
    }).listen(8888);
    console.log('Server Started');
};

exports.start = start;