# API & Routes Layer — Review Checklist

Review every item against the changed files. Mark as ✅ PASS, ⚠️ CONCERN, or 🔴 ISSUE.

## Authentication & Authorization

- [ ] Every endpoint enforces authentication (unless explicitly public).
- [ ] Authorization checks match the intended permission model (roles, scopes, ownership).
- [ ] Tenant/organization boundaries cannot be crossed by manipulating request parameters.
- [ ] Token validation covers expiration, revocation, and audience.

## Input Validation

- [ ] All user-supplied input is validated before reaching business logic.
- [ ] Validation errors return clear, specific messages with correct HTTP status (400/422).
- [ ] Path parameters, query strings, headers, and body are all validated.
- [ ] File uploads are validated for type, size, and content.
- [ ] No raw user input is interpolated into queries, shell commands, or templates.

## Request/Response Contract

- [ ] DTOs match the documented API contract (field names, types, nullability).
- [ ] Breaking changes to existing endpoints are versioned or behind feature flags.
- [ ] Response shapes are consistent across similar endpoints.
- [ ] Pagination, sorting, and filtering follow established conventions.
- [ ] Error responses use the project's standard error format.

## HTTP Semantics

- [ ] HTTP methods match intent (GET reads, POST creates, PUT/PATCH updates, DELETE removes).
- [ ] Status codes are accurate (201 for creation, 204 for no-content, 404 for not-found, 409 for conflict).
- [ ] Idempotency headers are respected where applicable.
- [ ] Content-Type and Accept headers are validated.

## Middleware & Cross-Cutting

- [ ] Rate limiting is applied to sensitive or expensive endpoints.
- [ ] CORS configuration is restrictive and intentional.
- [ ] Request logging does not leak sensitive data (passwords, tokens, PII).
- [ ] Timeouts are configured for long-running operations.

## Questions To Ask The User

These are prompts for the interactive review phase — ground them in actual code:

- "What authentication mechanism does this endpoint expect? I see [specific code] but want to confirm."
- "Should this endpoint be accessible by [role X]? The current guard allows [specific roles]."
- "The response includes [field]. Is this intentional for this consumer, or is it leaking internal state?"
- "This endpoint accepts [parameter] but I don't see validation for [case]. Is that intentional?"
