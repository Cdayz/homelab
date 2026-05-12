# Repository Guidelines

## Project Structure & Module Organization

- `nixos/` contains the host system configuration. The main entrypoint is `nixos/hosts/nucbox/configuration.nix`, and shared modules live under `nixos/modules/`.
- `nixos/modules/` is currently split into `base/`, `network/`, `services/`, and `storage/`. Keep new modules in the existing category when possible instead of growing `configuration.nix`.
- `nomad/jobs/<job>/` contains source job definitions. Most jobs use `job.hcl` plus optional `configs/`, `secrets/`, and `volumes/` directories.
- `nomad/render/<job>/` is generated output from the render script. Treat it as build output: inspect it when validating a change, but do not hand-edit it.
- `nomad/jobs/postgres/migrations/` stores sequential SQL migrations for the PostgreSQL job.
- `scripts/` contains small Python utilities for rendering jobs, encrypting and decrypting secrets, and reading secret payloads.

## Working Conventions

- Use `task` from the repository root for standard workflows rather than invoking ad hoc shell commands.
- Prefer changing source inputs under `nixos/`, `nomad/jobs/`, or `scripts/`; regenerate derived output instead of editing generated files.
- When touching Nomad jobs, preserve the existing layout and naming conventions. Job directories and module files use lowercase names.
- Keep changes narrow. This repository has infrastructure code, generated artifacts, and encrypted secrets close together, so unnecessary churn makes review and rollback harder.

## Build, Test, and Development Commands

- `task sops:decrypt`: decrypt tracked secret `*.yaml` files into local `*.raw.yaml` working copies.
- `task sops:encrypt`: re-encrypt changed raw secret files before commit, rebuild, or deploy.
- `task nomad:render -- <job>`: render `nomad/jobs/<job>` into `nomad/render/<job>`.
- `task nucbox:nomad:plan -- <job>`: render, upload, and run `nomad job plan` remotely on `nucbox`.
- `task nucbox:nomad:deploy -- <job>`: render and deploy a Nomad job to `nucbox`.
- `task nucbox:nomad:stop -- <job>`: stop a deployed Nomad job remotely.
- `task nucbox:rebuild:test`: run a remote NixOS test rebuild on `nucbox`.
- `task nucbox:rebuild`: apply the full NixOS switch on `nucbox`.
- `task postgres:create-migration -- <name>`: create the next sequential SQL migration under `nomad/jobs/postgres/migrations/`.
- `task nucbox:postgres:apply-migrations -- [up|down|version]`: apply PostgreSQL migrations against the remote instance through the configured SSH tunnel.

## Coding Style & Naming Conventions

- Python targets 3.12. Prefer typed, standard-library-first scripts with straightforward control flow and 4-space indentation.
- Match the style in `scripts/render-nomad-job.py`: explicit functions, small helpers, and minimal abstractions.
- Use `snake_case` for Python names and preserve the repository's lowercase path naming such as `nomad/jobs/wg-http-proxy/` and `nixos/modules/services/monitoring/default.nix`.
- No formatter or linter is configured in-tree. Keep formatting consistent with surrounding files and avoid opportunistic rewrites.
- Nix and HCL files should stay declarative and compact. Follow nearby patterns for attribute ordering, indentation, and comments.

## Testing Guidelines

- There is no dedicated automated test suite yet, so validate changes with the closest safe task.
- For `nixos/` changes, prefer `task nucbox:rebuild:test` before suggesting or making a full rebuild.
- For Nomad job changes, run `task nomad:render -- <job>` locally and then `task nucbox:nomad:plan -- <job>` before deploy.
- For secret-handling or rendering logic in `scripts/`, run the relevant `uv run scripts/...` entrypoint and inspect the generated output under `nomad/render/`.
- If you cannot run the relevant validation command, state that clearly in your final handoff.

## Commit & Pull Request Guidelines

- Use short, imperative commit subjects such as `Fix dashboard for caddy` or `Add cni for nomad`.
- Keep each commit focused on one behavior change or one infrastructure area.
- Pull requests should mention the affected area (`nixos`, `nomad`, `scripts`), summarize operational impact, and list the validation command used.
- Include screenshots only for UI-facing assets such as Grafana dashboards or other rendered visual changes.

## Security & Generated Files

- Never commit decrypted `*.raw.yaml` secrets unless that is explicitly intended. The encrypted `*.yaml` files are the source of truth.
- Re-run `task sops:encrypt` after editing raw secrets and before pushing or deploying.
- `task nomad:render` and the deploy tasks may copy secret content into `nomad/render/`. Inspect those outputs carefully and avoid committing rendered secrets unless the repository already expects them.
- Do not hand-edit files under `nomad/render/`; regenerate them from the matching job source instead.
