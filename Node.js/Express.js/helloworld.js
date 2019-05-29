const express = require('express'),
    app = express();

app.get('/', (req, res) => {
    res.send('hello world');
});

app.listen(3000, () => {
    console.log('Hello World app listening on 3000');
});
