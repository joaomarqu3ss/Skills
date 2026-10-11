# Web security skills

Agent skills for assessing and hardening web applications and web servers. Each skill lives in `skills/<name>/SKILL.md`.

## Install

Uses the [`skills` CLI](https://github.com/vercel-labs/skills); no clone needed.

```bash
# list what is available
npx skills add joaomarqu3ss/Skills --list

# install every skill in this repo into the current project
npx skills add joaomarqu3ss/Skills --skill '*'

# install one skill for all your projects, for Claude Code
npx skills add joaomarqu3ss/Skills --skill auditing-nginx-apache-web-servers -g -a claude-code -y

# update or remove later
npx skills update
npx skills remove auditing-nginx-apache-web-servers
```

Without `-g` the skills go to the project (`./<agent>/skills/`); with `-g` they go to your user directory (`~/<agent>/skills/`). `-a` accepts any agent the CLI supports (`claude-code`, `codex`, `cursor`, ...).

## Skills

| Skill | Use when |
|---|---|
| [`auditing-nginx-apache-web-servers`](skills/auditing-nginx-apache-web-servers/SKILL.md) | Matching an Nginx or Apache httpd version to security advisories, or reviewing its effective config for misconfiguration. |

## Adding a skill

Create `skills/<name>/SKILL.md` with `name` and `description` in the frontmatter. The CLI discovers it with no further configuration; add a row to the table above.
