const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const { exec } = require('child_process');

// Define a route for GET requests to '/'
app.get('/', (req, res) => {
    res.send('Hello, this is your API!');
});

// Define a route for GET requests to '/status-success'
app.get('/status-success', (req, res) => {
    // Execute a shell script to create success.txt
    exec('/mnt/c/Users/meracle.tinambacan/my-api/success_script.sh', (err, stdout, stderr) => {
        if (err) {
            console.error(err);
            return res.status(500).send('Internal Server Error');
        }
        res.send('Success file created!');
    });
});

// Define a route for GET requests to '/status-failed'
app.get('/status-failed', (req, res) => {
    // Execute a shell script to create error.txt
    exec('/mnt/c/Users/meracle.tinambacan/my-api/failed_script.sh', (err, stdout, stderr) => {
        if (err) {
            console.error(err);
            return res.status(500).send('Internal Server Error');
        }
        res.send('error file created!');
    });
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
