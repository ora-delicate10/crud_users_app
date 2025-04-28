const express = require('express');
const app = express();
const mysql = require('mysql');

// Middleware to parse JSON
app.use(express.json());


// Create a MySQL connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',   // Empty password if you didn’t set one
    database: 'system' // <-- replace with your actual database name
});

// Connect to MySQL
db.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err.stack);
        return;
    }
    console.log('Connected to MySQL database ✅');
});
// ROUTES

// 1. Create a new user (POST)
app.post('/users', (req, res) => {
    const { user_name, gender, password } = req.body;
    const sql = 'INSERT INTO users (user_name, gender, password) VALUES (?, ?, ?)';
    db.query(sql, [user_name, gender, password], (err, result) => {
        if (err) throw err;
        res.send('User added successfully!');
    });
});

// 2. Read all users (GET)
app.get('/users', (req, res) => {
    const sql = 'SELECT * FROM users';
    db.query(sql, (err, results) => {
        if (err) throw err;
        res.json(results);
    });
});

// 3. Read single user by ID (GET)
app.get('/users/:id', (req, res) => {
    const { id } = req.params;
    const sql = 'SELECT * FROM users WHERE user_id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) throw err;
        res.json(result[0]);
    });
});

// 4. Update a user (PUT)
app.put('/users/:id', (req, res) => {
    const { id } = req.params;
    const { user_name, gender, password } = req.body;
    const sql = 'UPDATE users SET user_name = ?, gender = ?, password = ? WHERE user_id = ?';
    db.query(sql, [user_name, gender, password, id], (err, result) => {
        if (err) throw err;
        res.send('User updated successfully!');
    });
});

// 5. Delete a user (DELETE)
app.delete('/users/:id', (req, res) => {
    const { id } = req.params;
    const sql = 'DELETE FROM users WHERE user_id = ?';
    db.query(sql, [id], (err, result) => {
        if (err) throw err;
        res.send('User deleted successfully!');
    });
});

// Start the server
app.listen(3000, '0.0.0.0', () => {
    console.log('Server is running on port 3000 🚀');
});