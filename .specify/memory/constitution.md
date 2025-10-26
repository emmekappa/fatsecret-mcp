<!--
Sync Impact Report
- Version change: N/A → 1.0.0
- Modified principles: Replaced placeholders with concrete code-quality principles
- Added sections: Core Principles (5), Additional Engineering Constraints, Development Workflow & Quality Gates, Governance
- Removed sections: None
- Templates requiring updates:
  - .specify/templates/plan-template.md → ✅ updated
  - .specify/templates/spec-template.md → ✅ updated
  - .specify/templates/tasks-template.md → ✅ updated
  - .specify/templates/commands/* → ⚠ pending (directory not present in repo)
- Follow-up TODOs: None
-->

# FatSecret MCP Constitution

## Core Principles

### I. Test-First and Coverage Gates (NON-NEGOTIABLE)
All non-trivial logic MUST be protected by automated tests. New behavior SHOULD be added using a red-green-refactor loop. Minimum coverage thresholds apply to touched areas.
- Unit tests for pure logic; integration tests for cross-module/contracts; lightweight smoke for CLIs.
- Write tests before or alongside implementation; a failing test MUST precede fixes for regressions.
- Coverage thresholds for changed code: ≥90% lines, ≥80% branches (exceptions require explicit, documented waiver in PR).
- Tests MUST be deterministic, isolated, and runnable locally and in CI.

### II. Static Typing and Explicit Contracts
Type safety is a primary quality mechanism.
- TypeScript MUST run with strict type checking; avoid implicit any and unsafe casts.
- Public surfaces (functions, modules, CLI entrypoints) MUST declare explicit input/output types.
- When crossing trust boundaries (I/O, JSON, env, process args), validate at runtime and fail fast with actionable errors.
- Schemas or type definitions MUST be the single source of truth; do not duplicate contract shapes.

### III. Readability, Simplicity, and Small Surface Area
Optimize for maintainability over cleverness.
- Prefer small, single-purpose modules and functions; keep cyclomatic complexity reasonable (target ≤10 per function).
- Follow clear naming, remove dead code, and document non-obvious decisions with concise comments.
- Keep PRs focused and reasonably sized (aim ≤300 net LOC diff) with one atomic change per PR.
- Choose the simplest design that satisfies requirements; justify added complexity in the Plan's "Complexity Tracking" table when needed.

### IV. Linting, Formatting, and CI Gatekeeper
Consistency is enforced automatically.
- ESLint and Prettier (or project equivalents) MUST run clean (0 errors) on every PR; warnings are treated as issues to address or explicitly suppress with rationale.
- CI MUST block merges on failing build, typecheck, tests, or coverage below threshold.
- No leftover TODO/FIXME without linked issue ID; temporary suppressions MUST include a timestamp and rationale.

### V. Errors, Observability, and Security Hygiene
Software MUST fail loudly and predictably, with signals for diagnosis.
- Do not swallow errors; convert to typed, actionable error messages and propagate appropriately.
- Use structured logs for significant events and errors; prefer levels (info/warn/error) and include correlation data when helpful.
- Keep secrets out of source control; pin dependencies and address high-severity advisories before release.

## Additional Engineering Constraints

- Runtime: Node.js LTS; Language: TypeScript. Source under `src/`, tests under `tests/`.
- tsconfig SHOULD enable strictness flags to maximize type safety.
- Commit messages SHOULD follow Conventional Commits; branches SHOULD follow `[###-feature-name]` as used in templates.
- Performance and reliability goals MUST be captured in feature specs' Success Criteria when relevant; micro-optimizations are deferred until measured.

## Development Workflow, Review Process, Quality Gates

- Every PR MUST:
  - Pass lint, format, build, and typecheck.
  - Include or update tests for changed behavior and meet coverage thresholds.
  - Update docs/README/quickstart where user-facing or developer-facing behavior changes.
  - Include a brief rationale for significant design choices.
- Definition of Done (DoD) for a task/feature includes: all gates green in CI, reviewer approval, and no unresolved comments.
- Complexity exceptions (e.g., lowering coverage for a file) REQUIRE a one-time waiver documented in the Plan's Complexity Tracking.

## Governance

This constitution supersedes ad-hoc practices. Compliance is mandatory for all changes.
- Amendments: open a PR labeled `constitution`, include a Sync Impact Report, rationale, and migration notes. Require at least two maintainer approvals.
- Versioning: semantic version for this document. MAJOR for rule removals/incompatible changes, MINOR for new principles/sections, PATCH for clarifications.
- Review cadence: at least quarterly, or sooner if quality gates routinely cause friction requiring adjustment.
- Enforcement: CI policy and code review checklist MUST enforce these rules.

**Version**: 1.0.0 | **Ratified**: 2025-10-26 | **Last Amended**: 2025-10-26
