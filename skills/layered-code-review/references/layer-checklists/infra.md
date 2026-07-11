# Infrastructure & Configuration Layer — Review Checklist

Review every item against the changed files. Mark as ✅ PASS, ⚠️ CONCERN, or 🔴 ISSUE.

## Secrets & Credentials

- [ ] No secrets, API keys, tokens, or passwords are hardcoded or committed.
- [ ] Secrets are loaded from environment variables or a secrets manager.
- [ ] `.gitignore` / `.dockerignore` excludes sensitive files.
- [ ] Logs and error messages do not leak secrets or credentials.

## Environment Configuration

- [ ] Environment-specific values (URLs, feature flags, limits) are configurable, not hardcoded.
- [ ] Default values are safe for production (fail-closed, not fail-open).
- [ ] Required environment variables are documented and validated at startup.
- [ ] Configuration changes are backward-compatible with running instances.

## Docker & Containerization

- [ ] Docker images use specific version tags, not `:latest`.
- [ ] Multi-stage builds minimize image size and attack surface.
- [ ] Containers run as non-root users.
- [ ] Health checks are defined and meaningful.
- [ ] Volume mounts and port mappings are intentional and documented.

## CI/CD Pipeline

- [ ] Pipeline changes are intentional and tested (not just copied from another project).
- [ ] Build steps are cached where possible.
- [ ] Test steps run before deploy steps.
- [ ] Deploy steps have rollback capability.
- [ ] Secrets in CI are stored in the platform's secret manager, not in pipeline files.

## Dependencies

- [ ] New dependencies are from trusted, maintained sources.
- [ ] Dependency versions are pinned (not floating ranges).
- [ ] Lock files are committed and up to date.
- [ ] No unnecessary dependencies added (check if the functionality exists in-house or in existing deps).
- [ ] License compatibility is verified for new dependencies.

## Infrastructure as Code

- [ ] IaC changes are reviewed for cost, security, and blast radius.
- [ ] Resource names and tags follow conventions.
- [ ] IAM permissions follow least-privilege.
- [ ] Network rules (security groups, firewalls) are restrictive and documented.

## Questions To Ask The User

- "This Dockerfile installs [package]. Is this needed for production or just for dev/build?"
- "The CI pipeline deploys to [environment] on [trigger]. Is that intentional, or should it require manual approval?"
- "This new environment variable [X] has no default. What happens if it's missing in [environment]?"
- "I see [dependency] was added. Is there a reason the existing [alternative] couldn't be used?"
- "This IAM policy grants [permission]. Is that the minimum required, or can it be scoped further?"
