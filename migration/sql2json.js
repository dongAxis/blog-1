var fs = require('fs');
var mysql = require('mysql');

var connection;
var tablesToDump = ['wp_posts', 'wp_terms', 'wp_term_relationships'];

function run() {
  tablesToDump.forEach((table) => {
    connection.query(`SELECT * FROM \`${table}\``, (err, results, fields) => {
      fs.writeFileSync(`${table}.json`, JSON.stringify(results, null, 2));
    });
  });
}

function main() {
  connection = mysql.createConnection(process.env.MYSQL_URL);
  connection.connect((err) => {
    if (err) {
      console.error('error connecting: ' + err.stack);
      return;
    }
    console.log('connected as id ' + connection.threadId);
  });
  run();
  connection.end();
}

main();
