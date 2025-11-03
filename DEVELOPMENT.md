# Development Guide

## Dependencies

### ESLint Version

This project uses **ESLint v8** instead of v9 for the following reasons:

- **Compatibility**: The `@lwc/eslint-plugin-lwc` (v1.9.0) and existing Salesforce tooling ecosystem are optimized for ESLint v8
- **Stability**: ESLint v8 is in LTS mode and provides stable, well-tested behavior for Lightning Web Components
- **Configuration**: The flat config format required by ESLint v9 requires significant migration effort without immediate benefits

ESLint v8 will remain in maintenance mode until October 2024, providing security updates. When the LWC plugin ecosystem fully supports ESLint v9, we will plan a migration.

## Development Setup

1. Install dependencies:

   ```bash
   npm install
   ```

2. Run linting:

   ```bash
   npm run lint
   ```

3. Format code:

   ```bash
   npm run fmt
   ```

4. Check formatting:
   ```bash
   npm run fmt:check
   ```
