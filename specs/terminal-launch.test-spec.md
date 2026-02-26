---
title: "Test Spec: just open/all terminal behavior"
repo: "pi-vs-claude-code"
updated: "2026-02-26"
scope:
  - "justfile recipes: open, spawn, all, all-spawn"
  - "wrapper: pivs"
  - "expected terminals: current tty by default; new window only when opted in"
---

# Goal

Make `just` recipes usable in a single terminal (including tmux) by default, while keeping an opt-in path for spawning new windows.

# Problem Scale (Systematic Thinking)

**Vertical**: execution is a dependent chain:
1) assert computed command wiring
2) assert current-terminal behavior
3) assert opt-in spawn behavior
4) assert wrapper parity (`pivs`)
5) regression-check other recipes

# Preconditions

- Repo: `~/.pi/.pi/pi-vs-claude-code`
- `just` installed (`just --version`)
- `pi` installed (`pi --version`)
- GUI env for spawn tests: `DISPLAY` or `WAYLAND_DISPLAY` set
- Optional: `kitty` installed for Linux spawn default

# Node A — Wiring (Objective)

**Input:** justfile source

**Validation method:** objective (`just -n`)

**Steps:**
- `cd ~/.pi/.pi/pi-vs-claude-code`
- `just -n open agent-chain theme-cycler`

**Pass criteria:**
- Script shows `cmd="cd '.../pi-vs-claude-code' && pi ..."`
- Default path contains `exec bash -lc "$cmd"`
- Spawn path only triggers when `PI_VS_CC_SPAWN=1`

**Fail criteria:**
- Any unconditional `kitty --detach` / `konsole --separate` on the default path

# Node B — Current Terminal Default (Manual, in normal shell)

**Validation method:** subjective + light objective

**Steps:**
- `cd ~/.pi/.pi/pi-vs-claude-code`
- Run: `just open agent-chain theme-cycler`

**Pass criteria:**
- `pi` TUI opens in the *same* terminal (no new window)
- Exiting `pi` returns you to the same shell prompt

**Notes:**
- Verify slash commands exist inside `pi`: `/chain-list`, `/chain`, `/theme`.

# Node C — tmux Behavior (Manual)

**Validation method:** subjective

**Steps:**
- `tmux new -s pivscc` (or use an existing session)
- In a pane: `cd ~/.pi/.pi/pi-vs-claude-code && just open minimal theme-cycler`

**Pass criteria:**
- `pi` opens in the same tmux pane
- Exiting `pi` returns to the pane prompt (pane remains usable)

# Node D — Spawn New Window Opt-In (Manual, GUI required)

**Validation method:** subjective

**Steps:**
- `cd ~/.pi/.pi/pi-vs-claude-code`
- Run: `PI_VS_CC_SPAWN=1 just open minimal theme-cycler`

**Pass criteria:**
- A new terminal window opens (kitty by default on Linux if available)
- The new window runs `pi` in the repo dir with the requested extensions

**Additional checks:**
- Override terminal: `PI_VS_CC_SPAWN=1 PI_VS_CC_TERM=konsole just open minimal theme-cycler`

# Node E — all vs all-spawn semantics (Objective + Manual)

**Validation method:** objective first

**Steps:**
- `cd ~/.pi/.pi/pi-vs-claude-code`
- `just -n all`
- `just -n all-spawn`

**Pass criteria:**
- `all` runs a single command (intended “one session” workflow)
- `all-spawn` issues multiple `PI_VS_CC_SPAWN=1 just open ...` lines

# Node F — Wrapper Parity (`pivs`) (Objective)

**Validation method:** objective

**Steps:**
- `pivs --list`
- `pivs -n open minimal theme-cycler` (or `pivs cmd minimal theme-cycler`)

**Pass criteria:**
- `pivs` resolves the repo `justfile` and behaves the same as running `just` inside the repo

# Regression Checks

- `just ext-agent-chain`, `just ext-system-select`, `just ext-agent-team` still launch `pi` correctly when run directly.
- `spawn` recipe exists: `just spawn minimal theme-cycler` opens a new window.

# Exit Criteria

All nodes A–F pass, plus no regressions observed.

