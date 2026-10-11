# Web security skills

Agent skills for authorized web application and web server security testing. Each skill lives in `skills/<name>/SKILL.md`.

## Install

Uses the [`skills` CLI](https://github.com/vercel-labs/skills); no clone needed.

```bash
# list what is available
npx skills add joaomarqu3ss/Skills --list

# install every skill in this repo into the current project
npx skills add joaomarqu3ss/Skills --skill '*'

# install one skill globally for Claude Code
npx skills add joaomarqu3ss/Skills --skill auditing-nginx-apache-web-servers -g -a claude-code -y

# update or remove later
npx skills update
npx skills remove auditing-nginx-apache-web-servers
```

Without `-g` the skills go to the project (`./<agent>/skills/`); with `-g` they go to your user directory (`~/<agent>/skills/`). `-a` accepts any agent the CLI supports (`claude-code`, `codex`, `cursor`, ...).

## Skills

### Server, scanning, and reconnaissance

- [Audit Nginx / Apache](skills/auditing-nginx-apache-web-servers/SKILL.md)
- [Web application penetration test](skills/performing-web-application-penetration-test/SKILL.md)
- [Nikto web scanner](skills/performing-web-application-scanning-with-nikto/SKILL.md)
- [Subdomain enumeration with Subfinder](skills/performing-subdomain-enumeration-with-subfinder/SKILL.md)

### API and authorization

- [OWASP API Security Top 10 testing](skills/testing-api-security-with-owasp-top-10/SKILL.md)
- [GraphQL security assessment](skills/performing-graphql-security-assessment/SKILL.md)
- [Forced-browsing authentication checks](skills/bypassing-authentication-with-forced-browsing/SKILL.md)
- [Broken access control](skills/testing-for-broken-access-control/SKILL.md)
- [IDOR](skills/exploiting-idor-vulnerabilities/SKILL.md)
- [Mass assignment](skills/exploiting-mass-assignment-in-rest-apis/SKILL.md)
- [OAuth misconfiguration](skills/exploiting-oauth-misconfiguration/SKILL.md)
- [JWT vulnerabilities](skills/testing-for-json-web-token-vulnerabilities/SKILL.md)
- [JWT token security](skills/testing-jwt-token-security/SKILL.md)
- [Broken-link hijacking](skills/exploiting-broken-link-hijacking/SKILL.md)
- [Business-logic vulnerabilities](skills/testing-for-business-logic-vulnerabilities/SKILL.md)

### Injection and input handling

- [Cross-site scripting (XSS)](skills/testing-for-xss-vulnerabilities/SKILL.md)
- [XSS testing with Burp Suite](skills/testing-for-xss-vulnerabilities-with-burpsuite/SKILL.md)
- [SQL injection](skills/exploiting-sql-injection-vulnerabilities/SKILL.md)
- [SQL injection with sqlmap](skills/exploiting-sql-injection-with-sqlmap/SKILL.md)
- [Second-order SQL injection](skills/performing-second-order-sql-injection/SKILL.md)
- [NoSQL injection](skills/exploiting-nosql-injection-vulnerabilities/SKILL.md)
- [Server-side template injection](skills/exploiting-template-injection-vulnerabilities/SKILL.md)
- [XML injection](skills/testing-for-xml-injection-vulnerabilities/SKILL.md)
- [XXE injection](skills/testing-for-xxe-injection-vulnerabilities/SKILL.md)
- [Directory traversal](skills/performing-directory-traversal-testing/SKILL.md)
- [Server-side request forgery (SSRF)](skills/exploiting-server-side-request-forgery/SKILL.md)
- [Blind SSRF](skills/performing-blind-ssrf-exploitation/SKILL.md)
- [Insecure deserialization](skills/exploiting-insecure-deserialization/SKILL.md)
- [Prototype pollution](skills/exploiting-prototype-pollution-in-javascript/SKILL.md)
- [Type juggling](skills/exploiting-type-juggling-vulnerabilities/SKILL.md)
- [HTTP parameter pollution](skills/performing-http-parameter-pollution-attack/SKILL.md)

### Browser, HTTP, and cache behavior

- [CORS misconfiguration](skills/testing-cors-misconfiguration/SKILL.md)
- [CSRF testing](skills/performing-csrf-attack-simulation/SKILL.md)
- [CSP bypass assessment](skills/performing-content-security-policy-bypass/SKILL.md)
- [Clickjacking](skills/performing-clickjacking-attack-test/SKILL.md)
- [Security headers audit](skills/performing-security-headers-audit/SKILL.md)
- [Host-header injection](skills/testing-for-host-header-injection/SKILL.md)
- [Open redirects](skills/testing-for-open-redirect-vulnerabilities/SKILL.md)
- [HTTP request smuggling](skills/exploiting-http-request-smuggling/SKILL.md)
- [WebSocket vulnerabilities](skills/exploiting-websocket-vulnerabilities/SKILL.md)
- [Web-cache deception](skills/performing-web-cache-deception-attack/SKILL.md)
- [Web-cache poisoning](skills/performing-web-cache-poisoning-attack/SKILL.md)
- [Web application firewall bypass assessment](skills/performing-web-application-firewall-bypass/SKILL.md)
- [Race-condition testing](skills/exploiting-race-condition-vulnerabilities/SKILL.md)
- [Sensitive-data exposure](skills/testing-for-sensitive-data-exposure/SKILL.md)

## Adding a skill

Create `skills/<name>/SKILL.md` with `name` and `description` in the frontmatter. The CLI discovers it with no further configuration; add it to the relevant index section. Skills copied from third parties retain their original `LICENSE` and attribution metadata.
