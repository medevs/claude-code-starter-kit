# Security Standards

## Secrets Management

- Never hardcode secrets, API keys, tokens, or credentials in source code
- Use environment variables for all sensitive configuration
- Add `.env` to `.gitignore` — provide `.env.example` with placeholder values
- Rotate credentials immediately if exposed in version control

## Input Validation

- Validate ALL external input: user input, API responses, file uploads, URL parameters
- Use allowlists over denylists when possible
- Validate data types, ranges, lengths, and formats
- Reject invalid input early — fail fast at system boundaries

## Database Security

- Parameterize all database queries — never concatenate user input into SQL
- Use ORM query builders or prepared statements
- Apply principle of least privilege for database users
- Never expose raw database errors to end users

## Output Security

- Sanitize all output to prevent XSS (Cross-Site Scripting)
- Use framework-provided escaping functions for HTML, URLs, and JavaScript
- Set appropriate Content-Type and security headers
- Implement Content Security Policy (CSP) headers for web applications

## Authentication & Authorization

- Use established auth libraries — never implement custom crypto
- Hash passwords with bcrypt, scrypt, or argon2 — never MD5 or SHA for passwords
- Implement rate limiting on authentication endpoints
- Follow principle of least privilege for all permissions

## Network Security

- Use HTTPS for all external requests
- Validate TLS certificates — never disable certificate verification
- Set appropriate CORS policies — never use wildcard `*` in production

## Logging & Monitoring

- Never log passwords, tokens, session IDs, or PII
- Log authentication failures and access control violations
- Include request IDs for tracing across services
