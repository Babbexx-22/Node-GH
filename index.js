const express = require('express');
const app = express();
const port = 3000;

// Serve static files from the 'public' folder
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.send('Hello, world!');
});

// app.listen(port, () => {
//   console.log(`App listening at http://localhost:${port}`);
// });

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});