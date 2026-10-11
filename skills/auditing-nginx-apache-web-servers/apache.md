# Apache httpd checklist

Run each check against the files listed by `httpd -t -D DUMP_INCLUDES` plus `httpd -M` and `httpd -S`. Grep the files one by one (`grep -nE '<directive>' <listed files>`) so each hit carries its file:line. A row with no matching directive evaluates to the default stated in Why.

| # | Check | Pass when | Why |
|---|---|---|---|
| 1 | `ServerTokens` / `ServerSignature` | `ServerTokens Prod` and `ServerSignature Off` | Default `Full` prints version and modules in `Server`. |
| 2 | `TraceEnable` | `Off` | Default `On` answers `TRACE`. |
| 3 | `Options` per `<Directory>` | no `Indexes`, no `ExecCGI` outside CGI dirs, `SymLinksIfOwnerMatch` rather than `FollowSymLinks` where users write content | Listings, script execution, symlink escapes. |
| 4 | Root directory policy | `<Directory />` has `Require all denied` and `AllowOverride None`; each served tree opens access explicitly | Default access should be denied. |
| 5 | `AllowOverride` | `None` except trees that need `.htaccess`, and then scoped (`AuthConfig`, `FileInfo`), never `All` | `.htaccess` is a per-request config surface. |
| 6 | `mod_status` / `mod_info` | `server-status` and `server-info` locations carry `Require local` or `Require ip` | Exposes requests, clients and config. |
| 7 | Unused modules | each of `dav`, `userdir`, `cgi`/`cgid`, `autoindex`, `info`, `status`, `proxy_ftp`, `proxy_html`, `heartmonitor` in `httpd -M` is used | Advisories cluster in optional modules; an unused one is attack surface. |
| 8 | `ProxyRequests` | absent or `Off` | `On` makes a forward proxy that anyone can use. |
| 9 | Hidden files | `.ht*` files denied, and `.git`, `.svn`, `.env` denied (`<DirectoryMatch "/\.(git|svn)">`, `<FilesMatch "^\.env">`) | VCS data and secrets under a web root. |
| 10 | Request limits | `Timeout` is set on purpose, `mod_reqtimeout` is loaded, `LimitRequestBody` is set on upload locations | Default body size is unlimited; slow-read exhaustion. |
| 11 | Worker user | `User` and `Group` are non-root accounts | Children as root turn a memory bug into full compromise. |
| 12 | Catch-all vhost | the first `<VirtualHost>` for each address:port is a deliberate default that serves nothing sensitive (`httpd -S`) | The first vhost answers unknown `Host` values. |
| 13 | `UserDir` and `ScriptAlias` | `UserDir disabled` unless in use; each `ScriptAlias` target is intended | Per-user trees and CGI directories widen the surface. |
| 14 | Key and config files | `stat` shows `SSLCertificateKeyFile` files not world-readable and config files not world-writable | A readable private key is a stolen identity. |
