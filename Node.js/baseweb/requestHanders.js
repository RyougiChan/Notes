const start = () => {
    console.log("Request handler 'start' was called.");
};

const upload = () => {
    console.log("Request handler 'upload' was called.");
};

exports.start = start;
exports.upload = upload;