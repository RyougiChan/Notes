const http = require('http');
const url = require('url');

const start = (route, handle) => {
    http.createServer((req, res) => {
        let postData = '';
        let pathname = url.parse(req.url).pathname;
        console.log('Request Received, pathname: ', pathname);
        req.setEncoding('utf8');
        req.addListener('data', (postDataChunk) => {
            postData += postDataChunk;
            console.log("Received POST data chunk '"+ postDataChunk + "'.");
        }); 
        req.addListener('end', () => {
            route(handle, pathname, res, postData);
        });
    }).listen(8888);
    console.log('Server Started');
};

exports.start = start;