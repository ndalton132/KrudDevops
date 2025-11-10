const { Pool } = require('pg');
require('dotenv').config();

console.log('Testing PostgreSQL connection...\n');
console.log('Credentials from .env:');
console.log('  DB_USER:', process.env.DB_USER);
console.log('  DB_HOST:', process.env.DB_HOST);
console.log('  DB_NAME:', process.env.DB_NAME);
console.log('  DB_PASSWORD:', process.env.DB_PASSWORD ? '****' + process.env.DB_PASSWORD.slice(-2) : 'NOT SET');
console.log('  DB_PORT:', process.env.DB_PORT);
console.log('\nAttempting connection...\n');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

pool.query('SELECT NOW() as current_time, current_database() as database', (err, res) => {
  if (err) {
    console.error('❌ CONNECTION FAILED!');
    console.error('\nError details:', err.message);
    console.error('\nCommon causes:');
    console.error('  1. Wrong password in .env file');
    console.error('  2. PostgreSQL service not running');
    console.error('  3. Wrong database name');
    console.error('  4. Wrong port number');
  } else {
    console.log('✅ CONNECTION SUCCESSFUL!');
    console.log('\nDatabase info:');
    console.log('  Current time:', res.rows[0].current_time);
    console.log('  Connected to:', res.rows[0].database);
    console.log('\n🎉 Your .env credentials are correct!');
  }
  pool.end();
});