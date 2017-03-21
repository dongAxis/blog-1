const process = require('process');
const express = require('express');

const app = express();
app.use('/', (req, res) => {
  console.log(`${req.method} ${req.url}`);
  express.static(`${__dirname}/out`)(req, res);
});
app.listen(3456, () => {
  console.log('Server listening');
});
