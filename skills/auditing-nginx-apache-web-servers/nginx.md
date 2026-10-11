# Nginx checklist

Run each check against `nginx.dump` (from `nginx -T`). A row with no matching directive evaluates to the default stated in Why.

| # | Check | Pass when | Why |
|---|---|---|---|
| 1 | `server_tokens` | `off` in `http` | Default `on` puts the exact version in `Server` and error pages. |
| 2 | `autoindex` | absent or `off` everywhere except a deliberate public listing | Directory listings expose files. |
| 3 | `alias` under a `location` | `location` and `alias` agree on the trailing slash (`location /img/` + `alias /data/img/;`) | `location /img` + `alias /data/img/;` lets `/img../` read the parent directory. |
| 4 | Hidden files | a rule denies `/.` paths except `.well-known` (e.g. `location ~ /\.(?!well-known) { deny all; }`) | `.git`, `.env`, `.htpasswd` under a web root. |
| 5 | `stub_status` | locations with it carry `allow`/`deny` or `auth_basic` | Unauthenticated status leaks traffic data. |
| 6 | `$uri` in `return` / `rewrite` targets that build a redirect | `$request_uri` is used instead | `$uri` is URL-decoded; `%0d%0a` becomes header injection. |
| 7 | `proxy_pass` | the target host contains no request-derived variable (`$host`, `$http_host`, `$arg_*`) | A client-controlled upstream is an open proxy or SSRF. |
| 8 | `add_header` inheritance | every block that defines any `add_header` redefines all the headers it needs, with `always` for error responses | A child level with its own `add_header` drops every header inherited from its parent. |
| 9 | Catch-all server | a `default_server` per `listen` that returns `444` or a fixed 404 | Unknown `Host` values otherwise land on the first vhost. |
| 10 | Request limits | `client_max_body_size`, `client_header_timeout`, `client_body_timeout` are set on purpose; `limit_req` / `limit_conn` guard login and API locations | Default body cap is 1m; no rate limit by default. |
| 11 | Worker user | `user` is set to a non-root account | A worker as root turns a memory bug into full compromise. |
| 12 | Optional modules | each of `http_dav`, `http_mp4`, `http_ssi`, `http_v3`, `stream` in `nginx -V` is used by at least one block | Advisories cluster in optional modules; an unused one is attack surface. |
| 13 | Key and config files | `stat` shows `ssl_certificate_key` files not world-readable and `nginx.conf` not world-writable | A readable private key is a stolen identity. |
