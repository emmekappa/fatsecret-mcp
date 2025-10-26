# Repository Guidelines

## Project Structure & Module Organization
- `src/index.ts` hosts the MCP server entry point; `src/cli.ts` provides the OAuth console utility. Keep new server logic modular and colocated with related helpers.
- Compiled assets land in `dist/` via the TypeScript build; never edit generated files directly.
- Ad-hoc diagnostic scripts live under `utils/`. Extend this area when adding new manual test harnesses or spike code.

## Build, Test, and Development Commands
- `npm install` installs the SDK and fetch tooling.
- `npm run build` compiles TypeScript into `dist/`. Run it before packaging or using the CLI entry points.
- `npm start` launches the server from `dist/index.js`.
- `npm run dev` performs a clean build and immediately starts the server—useful for quick local validation.
- `npm run clean` removes `dist/` so you can perform a clean rebuild.

## Coding Style & Naming Conventions
- Use strict TypeScript with 2-space indentation; `tsconfig.json` already enforces `strict` and `esModuleInterop`.
- Prefer named exports and camelCase function names; reserve PascalCase for classes and TypeScript interfaces.
- Keep async flows explicit—suffix helper names with `Async` when they return promises, mirroring existing SDK patterns.
- Centralize environment access through `dotenv` at the top of modules; avoid reading `process.env` throughout the call graph.

## Testing Guidelines
- Manual integration scripts live in `utils/`: `node utils/test-interactive.js`, `node utils/test-date-conversion.js`, and `node utils/test-mcp.js | node dist/index.js`.
- Build before running scripts so `dist/` is current.
- Name future utilities `test-<feature>.js` and document expected output inline.
- Add automated tests under `utils/` or a new `tests/` directory if you introduce a framework.

## Commit & Pull Request Guidelines
- Follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`), matching the repository history.
- Scope commits tightly and describe behavior changes plus key tools touched.
- Pull requests should include: purpose summary, test evidence (commands/run output), updated docs or configuration snippets, and links to related issues.
- Add screenshots or transcripts for OAuth or UI-driven flows when behavior changes.

## Security & Configuration Tips
- Store FatSecret credentials in `.env` during development and let the server persist tokens in `~/.fatsecret-mcp-config.json`; never commit these files.
- Rotate OAuth tokens if you suspect leakage and scrub logs before sharing them.
