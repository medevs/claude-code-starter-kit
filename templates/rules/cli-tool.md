# CLI Tool Rules

## Recommended Libraries

- **Node.js**: `commander` (mature, large ecosystem) or `citty` (modern, lightweight, unjs ecosystem)
- **Python**: `typer` (type-hint-driven, auto-generates help) over `click` (more manual but flexible)
- **Colors/formatting**: `chalk` (Node.js), `rich` (Python) — never use manual ANSI codes

## Architecture

```
src/
  index.ts                   # Entry point — parse args, dispatch commands
  commands/
    init.ts                  # /init command handler
    build.ts                 # /build command handler
    ...
  lib/
    config.ts                # Configuration loading/saving
    logger.ts                # Structured output (stdout/stderr)
    fs-utils.ts              # File system operations
  types/
    index.ts                 # Shared type definitions
```

## Complete Command Handler Example

```ts
import { Command } from "commander";
import { z } from "zod";
import chalk from "chalk";

const initOptionsSchema = z.object({
  template: z.enum(["default", "minimal", "full"]).default("default"),
  force: z.boolean().default(false),
});

export const initCommand = new Command("init")
  .description("Initialize a new project in the current directory")
  .option("-t, --template <name>", "project template", "default")
  .option("-f, --force", "overwrite existing files", false)
  .action(async (rawOpts) => {
    const opts = initOptionsSchema.parse(rawOpts);
    const targetDir = process.cwd();

    if (!opts.force && await hasExistingFiles(targetDir)) {
      console.error(chalk.red("Directory is not empty. Use --force to overwrite."));
      process.exit(1);
    }

    console.error(chalk.blue(`Initializing ${opts.template} project...`));
    await scaffoldProject(targetDir, opts.template);
    console.log(JSON.stringify({ created: targetDir, template: opts.template }));
  });
```

## Argument Parsing

- Define commands, options, and arguments with clear help text
- Support `--help` and `--version` flags
- Provide sensible defaults for all optional arguments
- Validate inputs early with Zod/schemas and provide clear error messages

## Output Conventions

- **stdout**: Program output (data, results) — pipeable to other commands
- **stderr**: Status messages, progress, errors, debug info
- Use exit codes: `0` = success, `1` = general error, `2` = usage error
- Support `--json` flag for machine-readable output
- Support `--quiet` / `--verbose` flags for output control
- Use color only when stdout is a TTY (check `process.stdout.isTTY`)

## Interactive vs CI Mode

```ts
const isInteractive = process.stdout.isTTY && !process.env.CI;

if (isInteractive) {
  const confirmed = await confirm("This will delete all data. Continue?");
  if (!confirmed) process.exit(0);
} else {
  // In CI or piped mode, require explicit --yes flag
  if (!opts.yes) {
    console.error("Destructive operation requires --yes flag in non-interactive mode.");
    process.exit(2);
  }
}
```

## User Experience

- Provide progress indicators for long operations (spinners, progress bars)
- Confirm destructive operations with interactive prompts (respect `--yes` flag for CI)
- Show helpful error messages with suggested fixes
- Support tab completion where possible
- Keep default behavior safe — destructive options should be opt-in

## Configuration

- Load config from: CLI flags > env vars > config file > defaults
- Config file locations: `./<tool>.config.json`, `~/.config/<tool>/config.json`
- Use dotenv for environment variables in development
- Validate configuration at startup — fail fast with clear messages

## Error Handling

- Catch all errors at the top level — never show raw stack traces to users
- Provide actionable error messages: what went wrong + how to fix it
- Use structured error types with error codes for programmatic handling
- Log full error details to stderr when `--verbose` is set
- Exit with appropriate codes (don't exit 0 on error)

## Packaging & Distribution

- Define `bin` field in `package.json` for Node.js CLIs
- Use `#!/usr/bin/env node` shebang for executable scripts
- Support global install (`npm install -g`) and npx execution
- Test with both global install and npx to verify paths work

## Testing

```ts
import { execaCommand } from "execa";

test("init creates project with default template", async () => {
  const { stdout, exitCode } = await execaCommand("node ./dist/index.js init --json", { cwd: tmpDir });
  expect(exitCode).toBe(0);
  const result = JSON.parse(stdout);
  expect(result.template).toBe("default");
});

test("init fails without --force in non-empty directory", async () => {
  await writeFile(join(tmpDir, "existing.txt"), "content");
  const result = await execaCommand("node ./dist/index.js init", { cwd: tmpDir, reject: false });
  expect(result.exitCode).toBe(1);
  expect(result.stderr).toContain("not empty");
});
```

## DO NOT Use

- `argparse` (Python) for complex CLIs — use `typer` for type-driven argument parsing
- Manual ANSI escape codes — use `chalk` (Node.js) or `rich` (Python)
- `process.exit()` deep in business logic — throw errors and catch at the top level
- Interactive prompts without a `--yes` bypass for CI environments
