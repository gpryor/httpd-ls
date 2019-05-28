# httpd-ls

Server listing of directories and files with HTTP range support, e.g.

```
// directory listing
curl <host>/<dirname>

// retrieve last line of file, middle of file
curl -H "range: lines=-1" <host>/<filename>
curl -H "range: lines=10-20" <host>/<filename>
```
