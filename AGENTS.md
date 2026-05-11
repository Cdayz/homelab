# Repository Guidelines

## Project Structure & Module Organization

`nixos/` contains the host system definition: `hosts/nucbox/` holds the machine entrypoint, while `modules/` is split into `base/`, `network/`, and `services/`. `nomad/jobs/<app>/` stores non-system workloads; each job typically includes `job.hcl`, `configs/`, and `secrets/`. Python automation lives in `scripts/`, and PostgreSQL bootstrap SQL lives in `nomad/jobs/postgres/migrations/`.

## Build, Test, and Development Commands

Use `task` from the repository root for routine work.

- `task sops:decrypt`: decrypt tracked `*.yaml` secrets into local `*.raw.yaml` files.
- `task sops:encrypt`: re-encrypt changed raw secrets before commit or deploy.
- `task nomad:render -- <job>`: render `nomad/jobs/<job>` into `nomad/render/<job>`.
- `task nucbox:nomad:plan -- <job>`: upload a rendered job and run `nomad job plan` remotely.
- `task nucbox:nomad:deploy -- <job>`: deploy a Nomad job to the `nucbox` host.
- `task nucbox:rebuild:test`: run a remote NixOS test rebuild.
- `task nucbox:rebuild`: apply the full NixOS switch on the target host.
- `task postgres:create-migration -- <name>`: create sequential SQL migrations.

## Coding Style & Naming Conventions

Python targets 3.12 and uses typed, standard-library-first scripts with 4-space indentation and `snake_case` names. Keep helper scripts small and explicit, matching patterns in `scripts/render-nomad-job.py`. Preserve existing lowercase naming in paths such as `nomad/jobs/wg-http-proxy/` and Nix module filenames such as `monitoring/default.nix`. No formatter or linter is configured in-tree, so keep edits minimal and consistent with surrounding files.

## Testing Guidelines

There is no dedicated `tests/` directory yet. Validate infrastructure changes with the closest safe task: `task nucbox:rebuild:test` for NixOS changes and `task nucbox:nomad:plan -- <job>` for Nomad jobs. For secret or render logic, run the relevant `uv run scripts/...` command locally and inspect generated output under `nomad/render/` before deploying.

## Commit & Pull Request Guidelines

Recent commits use short, imperative subjects such as `Fix dashboard for caddy` and `Add cni for nomad`. Follow that style: one concise sentence describing the behavior change. Pull requests should state the affected area (`nixos`, `nomad`, `scripts`), list the validation command used, and include screenshots only for UI assets such as Grafana dashboards.

## Security & Configuration Tips

Never commit decrypted `*.raw.yaml` secrets unless that is explicitly intended; the encrypted `*.yaml` files are the source of truth. Re-run `task sops:encrypt` before pushing, and avoid editing generated content under `nomad/render/` directly.
