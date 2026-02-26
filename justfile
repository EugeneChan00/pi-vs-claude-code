set dotenv-load := true

default:
    @just --list

# g1

# 1. default pi
pi:
    pi

# 2. Pure focus pi: strip footer and status line entirely
ext-pure-focus:
    pi -e extensions/pure-focus.ts

# 3. Minimal pi: model name + 10-block context meter
ext-minimal:
    pi -e extensions/minimal.ts -e extensions/theme-cycler.ts

# 4. Cross-agent pi: load commands from .claude/, .gemini/, .codex/ dirs
ext-cross-agent:
    pi -e extensions/cross-agent.ts -e extensions/minimal.ts

# 5. Purpose gate pi: declare intent before working, persistent widget, focus the system prompt on the ONE PURPOSE for this agent
ext-purpose-gate:
    pi -e extensions/purpose-gate.ts -e extensions/minimal.ts

# 6. Customized footer pi: Tool counter, model, branch, cwd, cost, etc.
ext-tool-counter:
    pi -e extensions/tool-counter.ts

# 7. Tool counter widget: tool call counts in a below-editor widget
ext-tool-counter-widget:
    pi -e extensions/tool-counter-widget.ts -e extensions/minimal.ts

# 8. Subagent widget: /sub <task> with live streaming progress
ext-subagent-widget:
    pi -e extensions/subagent-widget.ts -e extensions/pure-focus.ts -e extensions/theme-cycler.ts

# 9. TillDone: task-driven discipline — define tasks before working
ext-tilldone:
    pi -e extensions/tilldone.ts -e extensions/theme-cycler.ts

#g2

# 10. Agent team: dispatcher orchestrator with team select and grid dashboard
ext-agent-team:
    pi -e extensions/agent-team.ts -e extensions/theme-cycler.ts

# 11. System select: /system to pick an agent persona as system prompt
ext-system-select:
    pi -e extensions/system-select.ts -e extensions/minimal.ts -e extensions/theme-cycler.ts

# 12. Launch with Damage-Control safety auditing
ext-damage-control:
    pi -e extensions/damage-control.ts -e extensions/minimal.ts -e extensions/theme-cycler.ts

# 13. Agent chain: sequential pipeline orchestrator
ext-agent-chain:
    pi -e extensions/agent-chain.ts -e extensions/theme-cycler.ts

#g3

# 14. Pi Pi: meta-agent that builds Pi agents with parallel expert research
ext-pi-pi:
    pi -e extensions/pi-pi.ts -e extensions/theme-cycler.ts

#ext

# 15. Session Replay: scrollable timeline overlay of session history (legit)
ext-session-replay:
    pi -e extensions/session-replay.ts -e extensions/minimal.ts

# 16. Theme cycler: Ctrl+X forward, Ctrl+Q backward, /theme picker
ext-theme-cycler:
    pi -e extensions/theme-cycler.ts -e extensions/minimal.ts

# utils

# Open pi with one or more stacked extensions in a new terminal: just open minimal tool-counter
open +exts:
    #!/usr/bin/env bash
    set -euo pipefail
    args=""
    for ext in {{exts}}; do
        if [ "$ext" = "pi" ]; then
            continue
        fi
        args="$args -e extensions/$ext.ts"
    done
    cmd="cd '{{justfile_directory()}}' && pi$args"
    # If there's no GUI session, run in the current terminal.
    if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
        exec bash -lc "$cmd"
    fi

    # Optional override: force a specific terminal launcher.
    # Example: PI_VS_CC_TERM=konsole just open minimal theme-cycler
    case "${PI_VS_CC_TERM:-}" in
        kitty)
            if command -v kitty >/dev/null 2>&1; then
                kitty --detach bash -lc "$cmd" >/dev/null 2>&1 || true
                exit 0
            fi
            ;;
        konsole)
            if command -v konsole >/dev/null 2>&1; then
                konsole --separate --hold -e bash -lc "$cmd" >/dev/null 2>&1 &
                exit 0
            fi
            ;;
        gnome-terminal)
            if command -v gnome-terminal >/dev/null 2>&1; then
                gnome-terminal -- bash -lc "$cmd" >/dev/null 2>&1 &
                exit 0
            fi
            ;;
        xterm)
            if command -v xterm >/dev/null 2>&1; then
                xterm -e bash -lc "$cmd" >/dev/null 2>&1 &
                exit 0
            fi
            ;;
    esac

    # Kitty (default on Linux)
    if command -v kitty >/dev/null 2>&1; then
        kitty --detach bash -lc "$cmd" >/dev/null 2>&1 || true
        exit 0
    fi

    # KDE Konsole
    if command -v konsole >/dev/null 2>&1; then
        konsole --separate --hold -e bash -lc "$cmd" >/dev/null 2>&1 &
        exit 0
    fi

    # GNOME Terminal
    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal -- bash -lc "$cmd" >/dev/null 2>&1 &
        exit 0
    fi

    # xterm fallback
    if command -v xterm >/dev/null 2>&1; then
        xterm -e bash -lc "$cmd" >/dev/null 2>&1 &
        exit 0
    fi

    # macOS Terminal.app
    if command -v osascript >/dev/null 2>&1; then
        escaped="${cmd//\\/\\\\}"
        escaped="${escaped//\"/\\\"}"
        osascript -e "tell application \"Terminal\" to do script \"$escaped\""
        exit 0
    fi

    echo "No supported terminal launcher found; running in current terminal."
    exec bash -lc "$cmd"

cmd +exts:
    #!/usr/bin/env bash
    set -euo pipefail
    args=""
    for ext in {{exts}}; do
        if [ "$ext" = "pi" ]; then
            continue
        fi
        args="$args -e extensions/$ext.ts"
    done
    echo "cd '{{justfile_directory()}}' && pi$args"

# Open every extension in its own terminal window
all:
    just open pi
    just open pure-focus 
    just open minimal theme-cycler
    just open cross-agent minimal
    just open purpose-gate minimal
    just open tool-counter
    just open tool-counter-widget minimal
    just open subagent-widget pure-focus theme-cycler
    just open tilldone theme-cycler
    just open agent-team theme-cycler
    just open system-select minimal theme-cycler
    just open damage-control minimal theme-cycler
    just open agent-chain theme-cycler
    just open pi-pi theme-cycler
