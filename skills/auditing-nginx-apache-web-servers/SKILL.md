---
name: auditing-nginx-apache-web-servers
description: Audit an Nginx or Apache httpd server you operate. Use when matching its version to security advisories, or reviewing its effective config for misconfiguration.
domain: cybersecurity
subdomain: web-server-security
tags:
- nginx
- apache-httpd
- hardening
- advisories
- misconfiguration
version: '1.0'
---
# Auditing Nginx / Apache Web Servers

Scope: servers you own or are authorised to assess. Every step reads version and configuration from the host itself.

Audit the **effective** config, the one the running server loads after every include, never a single file read in isolation. An **advisory** counts only when its affected range contains the installed version and its module or directive is in use.

## Steps

1. **Identify.** `nginx -v` / `nginx -V`, or `httpd -v` (`apache2 -v` on Debian). In a container, run the same command inside it. Done when product, exact version, install source (distro package, vendor repo, source build, image) and build flags or loaded modules are recorded.

2. **Capture the effective config.**
   - Nginx: `nginx -T > nginx.dump` tests the config and dumps every include.
   - Apache: `httpd -t -D DUMP_INCLUDES` lists the files; `httpd -S` lists vhosts; `httpd -M` lists modules. Read each listed file. On 2.4.67 `-D DUMP_CONFIG` prints only `Syntax OK`, so it does not dump.
   
   Done when every included file is read and every server block or vhost is listed.

3. **Match advisories.** Fetch the vendor list and compare each entry's affected range to the recorded version:
   - Nginx: https://nginx.org/en/security_advisories.html
   - Apache: https://httpd.apache.org/security/vulnerabilities_24.html

   Distro packages backport fixes without changing the version number; before marking a CVE open on a packaged build, search the package changelog (`apt changelog`, `rpm -q --changelog`) for the CVE id. Done when every advisory whose range contains the version has a row: CVE id, severity, fixed version, module involved, module loaded or not (step 1), and status (open, backported, not reachable).

4. **Check the config.** Apply every row of the branch checklist to the captured config: [nginx.md](nginx.md) or [apache.md](apache.md). Done when every row is pass, fail or n.a., each with evidence: the directive and its file:line from the dump, or the command output.

5. **Report.** One table of fails and open advisories: finding, evidence, severity, fix as a config snippet or target version. Validate each fix with `nginx -t` / `httpd -t` before it is applied. Done when every fail and open advisory has a fix and a validation command.

## Adjacent skills

- TLS protocol and cipher review: `performing-ssl-tls-security-assessment`
- Response headers: `performing-security-headers-audit`
- Active scan of the running server: `performing-web-application-scanning-with-nikto`
- Runtime WAF: `implementing-web-application-logging-with-modsecurity`
