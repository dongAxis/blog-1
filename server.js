const process = require('process');
const express = require('express');

const app = express();
app.use('/', express.static(`${__dirname}/out`));
app.listen(3456);
