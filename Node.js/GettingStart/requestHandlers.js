const querystring = require("querystring"),
    fs = require("fs"),
    formidable = require('formidable');

const start = (response, request) => {
    response.writeHead(200, {"Content-Type": "text/html"});
    response.write(
        `
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
            </head>
            <body>
                <form action="/upload" enctype="multipart/form-data" method="post">
                    <input type="file" name="upload" multiple="multiple" />
                    <input type="submit" value="Upload file" />
                </form>
            </body>
        </html>
        `
    );
    response.end(); 
};

const upload = (response, request) => {
    console.log("Request handler 'upload' was called.");
    
    let form = new formidable.IncomingForm();
    form.uploadDir = __dirname;
    form.parse(request, (err, fields, files) => {
        console.log('parsing done');
        fs.renameSync(files.upload.path, 'test.png');
        
        response.writeHead(200, {"Content-Type": "text/html"});
        response.write('<img src="/show" />');
        response.end();
    });
};

const show = (response, request) => {
    console.log("Request handler 'show' was called.");
    fs.readFile("test.png", "binary", (error, file) => {
        if(error) {
            response.writeHead(500, {"Content-Type": "text/plain"});
            response.write(error + "\n");
            response.end(); 
        } else {
            response.writeHead(200, {"Content-Type": "image/png"});
            response.write(file, "binary");
            response.end(); 
        } 
    });
};

exports.start = start;
exports.upload = upload;
exports.show = show;