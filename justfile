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

# Run pi with one or more stacked extensions in the current terminal:
#   just open minimal tool-counter
# If you want a new window instead:
#   PI_VS_CC_SPAWN=1 just open minimal tool-counter
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

    # Default: run in the current terminal.
    if [ "${PI_VS_CC_SPAWN:-0}" != "1" ]; then
        exec bash -lc "$cmd"
    fi

    # Spawn a new terminal window (optional).
    # Example: PI_VS_CC_TERM=konsole PI_VS_CC_SPAWN=1 just open minimal theme-cycler
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

# Spawn a new terminal window explicitly (wrapper around `open`)
spawn +exts:
    PI_VS_CC_SPAWN=1 just open {{exts}}

# Open every extension in its own terminal window (spawn mode)
all-spawn:
    PI_VS_CC_SPAWN=1 just open pi
    PI_VS_CC_SPAWN=1 just open pure-focus 
    PI_VS_CC_SPAWN=1 just open minimal theme-cycler
    PI_VS_CC_SPAWN=1 just open cross-agent minimal
    PI_VS_CC_SPAWN=1 just open purpose-gate minimal
    PI_VS_CC_SPAWN=1 just open tool-counter
    PI_VS_CC_SPAWN=1 just open tool-counter-widget minimal
    PI_VS_CC_SPAWN=1 just open subagent-widget pure-focus theme-cycler
    PI_VS_CC_SPAWN=1 just open tilldone theme-cycler
    PI_VS_CC_SPAWN=1 just open agent-team theme-cycler
    PI_VS_CC_SPAWN=1 just open system-select minimal theme-cycler
    PI_VS_CC_SPAWN=1 just open damage-control minimal theme-cycler
    PI_VS_CC_SPAWN=1 just open agent-chain theme-cycler
    PI_VS_CC_SPAWN=1 just open pi-pi theme-cycler

# Run a single Pi session (current terminal by default)
all:
    just open pi
