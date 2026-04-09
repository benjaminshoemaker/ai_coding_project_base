const http = require('http');
const url = require('url');
const fs = require('fs');

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);

  if (parsedUrl.pathname === '/oauth/callback') {
    const code = parsedUrl.query.code;
    const error = parsedUrl.query.error;

    if (code) {
      fs.writeFileSync('/tmp/oauth-code.txt', code);
      res.writeHead(200, {'Content-Type': 'text/html'});
      res.end('<html><body><h1>Authorization successful!</h1><p>You can close this window and return to Claude Code.</p></body></html>');
    } else {
      fs.writeFileSync('/tmp/oauth-error.txt', error || 'unknown');
      res.writeHead(400, {'Content-Type': 'text/html'});
      res.end('<html><body><h1>Authorization failed</h1><p>Error: ' + (error || 'unknown') + '</p></body></html>');
    }

    setTimeout(() => server.close(), 1000);
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(3847, () => {
  console.log('OAuth callback server listening on http://localhost:3847');
});
