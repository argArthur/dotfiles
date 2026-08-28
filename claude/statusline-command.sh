#!/bin/bash
# Statusline: model + effort, current project/directory, git branch + dirty state, context used %.
# Colors borrowed from ~/.config/fish/functions/fish_prompt.fish
# (cyan = location, rose-pine-moon red = repo/project, iris = git branch, rose = dirty marker,
# gold/yellow/red = status thresholds), separators use rose-pine-moon muted.

input=$(cat)

# Rolling animation: config lives in statusline-animation.conf so it can be
# tuned without touching this script. Defaults below cover a missing file.
ANIM_ENABLED=false
ANIM_NAME=xwing_deathstar
ANIM_WIDTH=50
ANIM_FRAME_MS=250
ANIM_SHIP_TICKS_PER_CELL=4
ANIM_SHOT_DELAY_MS=1000
ANIM_LASER_TICKS_PER_CELL=1
ANIM_EXPLOSION_FRAMES=16
ANIM_MARGIN_PCT=20
ANIM_FLEE_SPEED_PCT=200
ANIM_PAUSE_FRAMES=10
ANIM_SHIP=$'\uf0fb'
ANIM_TARGET=$'\U000f08d8'
# nf-fa icons cycled (by tick) for the laser's traveling sprite —
# see the render loop below. Given as \u escapes, not pasted literal
# characters, for the same corruption-resistance reason as ANIM_SHIP/
# ANIM_TARGET above.
ANIM_LASER_CHARS=($'\uf48b' $'\uf469')
ANIM_LASER_LEN=${#ANIM_LASER_CHARS[@]}
ANIM_LASER_SPRITE_MS=170
# Explosion sprite sequence, played in order during the explosion phase,
# ANIM_EXPLOSION_FRAME_TICKS ticks per frame. Same \u/\U-escape convention.
ANIM_EXPLOSION_CHARS=($'\uf1d1' $'\U0001f4a5' $'\uf1e9' $'\U000f08da')
ANIM_EXPLOSION_LEN=${#ANIM_EXPLOSION_CHARS[@]}
ANIM_EXPLOSION_FRAME_TICKS=4
ANIM_BG_CHARS='     · ·  *   '
# Colors, given as $'...' (real escape bytes at assignment time) rather
# than the plain-quoted style used above for cyan/yellow/etc — those only
# work because every use of them runs through an actual printf call, which
# is what turns their literal "\033" text into a real byte. These
# animation cells are built with plain string concatenation instead, so
# they need to already be real bytes going in.
ANIM_SHIP_COLOR=$'\033[97m'
ANIM_LASER_COLOR=$'\033[91m'
ANIM_TARGET_COLOR=$'\033[37m'
anim_conf="$(dirname "${BASH_SOURCE[0]}")/statusline-animation.conf"
[ -f "$anim_conf" ] && source "$anim_conf"

cyan='\033[36m'
yellow='\033[33m'
red='\033[31m'
rp_gold='\033[38;2;246;193;119m'
rp_red='\033[38;2;235;111;146m'
rp_iris='\033[38;2;196;167;231m'
rp_rose='\033[38;2;234;154;151m'
muted='\033[38;2;110;106;134m'
normal='\033[0m'
sep=$(printf "${muted} · ${normal}")

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
effort=$(echo "$input" | jq -r '.effort.level // empty')
repo_name=$(echo "$input" | jq -r '.workspace.repo.name // empty')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Project name if in a repo, else project/current directory basename.
if [ -n "$repo_name" ]; then
    project="$repo_name"
elif [ -n "$project_dir" ] && [ "$project_dir" != "null" ]; then
    project=$(basename "$project_dir")
else
    project=$(basename "$current_dir")
fi

model_str="$model"
if [ -n "$effort" ]; then
    model_str="$model_str ($effort)"
fi

branch_str=""
branch=$(git -C "$current_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
    dirty_marker=""
    if [ -n "$(git -C "$current_dir" status --porcelain 2>/dev/null)" ]; then
        dirty_marker=$(printf "${rp_rose}*${normal}")
    fi
    branch_str=$(printf "${rp_iris}%s${normal}%s" "$branch" "$dirty_marker")
fi

ctx_str=""
if [ -n "$used_pct" ]; then
    pct_int=$(printf '%.0f' "$used_pct")
    ctx_color="$rp_gold"
    if [ "$pct_int" -ge 80 ]; then
        ctx_color="$red"
    elif [ "$pct_int" -ge 50 ]; then
        ctx_color="$yellow"
    fi
    ctx_str=$(printf "${muted}Context: ${ctx_color}%s%%${normal}" "$pct_int")
fi

# Renders one frame of the "xwing_deathstar" animation: the ship crawls in
# and sits at the start of the track for ANIM_SHOT_DELAY_MS before firing.
# The laser then races ahead of it, independently and much faster
# (ANIM_LASER_TICKS_PER_CELL ticks/cell), toward the death star. When the
# laser lands, the death star explodes (ANIM_EXPLOSION_FRAMES). Only then
# does the ship — wherever it happens to be, since it's far behind the
# laser — switch to its fastest getaway speed (ANIM_FLEE_SPEED_PCT, a
# percentage of 1 cell/tick, so >100 means faster than the ship ever
# otherwise moves) and cross a starfield margin (ANIM_MARGIN_PCT of
# ANIM_WIDTH) off-screen, before a blank pause (ANIM_PAUSE_FRAMES) and the
# next pass.
render_anim_xwing_deathstar() {
    local width=$((ANIM_WIDTH > 1 ? ANIM_WIDTH : 1))
    if [ -n "$ANIM_MAX_WIDTH_AVAIL" ]; then
        # The printed animation is width + 1 (target) + margin_cells columns,
        # and margin_cells = width * ANIM_MARGIN_PCT / 100 — so total columns
        # used ≈ width * (100 + ANIM_MARGIN_PCT) / 100 + 1. Solve for the
        # largest width that still fits in what's actually left on the line.
        # A negative/zero budget (prefix alone doesn't fit) still clamps to
        # the smallest possible animation (1) rather than falling back to
        # the full configured width — the opposite of what's needed here.
        local avail=$ANIM_MAX_WIDTH_AVAIL
        (( avail < 0 )) && avail=0
        local width_cap=$(( (avail - 1) * 100 / (100 + ANIM_MARGIN_PCT) ))
        (( width_cap < 1 )) && width_cap=1
        (( width > width_cap )) && width=$width_cap
    fi
    local ship_tpc=$((ANIM_SHIP_TICKS_PER_CELL > 0 ? ANIM_SHIP_TICKS_PER_CELL : 1))
    local laser_tpc=$((ANIM_LASER_TICKS_PER_CELL > 0 ? ANIM_LASER_TICKS_PER_CELL : 1))
    local flee_speed_pct=$((ANIM_FLEE_SPEED_PCT > 0 ? ANIM_FLEE_SPEED_PCT : 100))
    local margin_cells=$(( width * ANIM_MARGIN_PCT / 100 ))
    (( margin_cells < 1 )) && margin_cells=1
    local bg_len=${#ANIM_BG_CHARS}
    (( bg_len < 1 )) && bg_len=1

    # The ship sits at the start of the track, not yet firing, for this long
    # — expressed in ms (not ticks) so it stays "~1 second" regardless of
    # ANIM_FRAME_MS tuning.
    local delay_ticks=$(( ANIM_SHOT_DELAY_MS / ANIM_FRAME_MS ))
    (( delay_ticks < 0 )) && delay_ticks=0
    # Combat lasts until the laser crosses the whole track and hits.
    local combat_ticks=$((width * laser_tpc / 2))
    local explosion_ticks=$ANIM_EXPLOSION_FRAMES
    # Where the (much slower) ship has gotten to by the moment of impact —
    # that's where it freezes for the explosion, then flees from.
    local ship_pos_at_hit=$(( combat_ticks / ship_tpc ))
    (( ship_pos_at_hit > width - 1 )) && ship_pos_at_hit=$((width - 1))
    # Cells left to cross (remaining track + the margin) at flee_speed_pct/100
    # cells per tick, rounded up so the ship fully clears the margin.
    local flee_span=$(( (width - ship_pos_at_hit) + margin_cells ))
    local flee_ticks=$(( (flee_span * 100 + flee_speed_pct - 1) / flee_speed_pct ))
    local total_ticks=$((delay_ticks + combat_ticks + explosion_ticks + flee_ticks + ANIM_PAUSE_FRAMES))

    local now_ms=$(( $(date +%s%N) / 1000000 ))
    local tick=$(( now_ms / ANIM_FRAME_MS ))
    local phase_tick=$(( tick % total_ticks ))

    local reset=$'\033[0m'
    local ship_pos=-1
    local laser_pos=-1
    local target_cell="${ANIM_TARGET_COLOR}${ANIM_TARGET}${reset}"

    if (( phase_tick < delay_ticks )); then
        # Waiting to fire — the ship is parked at the start of the track.
        ship_pos=0
    elif (( phase_tick < delay_ticks + combat_ticks )); then
        local combat_tick=$((phase_tick - delay_ticks))
        ship_pos=$(( combat_tick / ship_tpc ))
        (( ship_pos > width - 1 )) && ship_pos=$((width - 1))
        laser_pos=$(( (combat_tick * 2) / laser_tpc ))
        (( laser_pos > width - 1 )) && laser_pos=$((width - 1))
    elif (( phase_tick < delay_ticks + combat_ticks + explosion_ticks )); then
        ship_pos=$ship_pos_at_hit
        local into_explosion=$((phase_tick - delay_ticks - combat_ticks))
        local idx=$(( (into_explosion / ANIM_EXPLOSION_FRAME_TICKS) % ANIM_EXPLOSION_LEN ))
        target_cell="${ANIM_EXPLOSION_CHARS[idx]}"
    else
        target_cell=' '
        local after=$((phase_tick - delay_ticks - combat_ticks - explosion_ticks))
        if (( after < flee_ticks )); then
            ship_pos=$(( ship_pos_at_hit + (after * flee_speed_pct) / 100 ))
        fi
    fi

    # Deterministic per-(tick, cell) pseudo-random pick into ANIM_BG_CHARS,
    # so empty cells (main track and the margin alike) twinkle between stars
    # and blank space over time.
    local t=$(( tick % 104729 ))

    local max_extent=$((width + margin_cells))
    local out="" i hash cell
    for ((i = 0; i < max_extent; i++)); do
        if (( i == laser_pos && i < width )); then
            # Cycled off now_ms directly (not phase_tick/ANIM_FRAME_MS): the
            # statusline is only ever actually polled every ~1s, and a small
            # cycle length sampled at exact multiples of ANIM_FRAME_MS can
            # alias onto the same frame forever (e.g. 250ms ticks land on the
            # same parity every 1000ms poll, since 1000/250=4 is even). A
            # sprite period that isn't a clean divisor of 1000 avoids that.
            local idx=$(( (now_ms / ANIM_LASER_SPRITE_MS) % ANIM_LASER_LEN ))
            cell="${ANIM_LASER_COLOR}${ANIM_LASER_CHARS[idx]}${reset}"
        elif (( i == ship_pos )); then
            cell="${ANIM_SHIP_COLOR}${ANIM_SHIP}${reset}"
        else
            hash=$(( (t * 31 + i * 131) % bg_len ))
            cell="${ANIM_BG_CHARS:hash:1}"
        fi
        out="${out}${cell}"
        (( i == width - 1 )) && out="${out}${target_cell}"
    done

    printf '%s' "$out"
}

# Dispatcher: add new ANIM_NAME cases here as new animations are built.
render_animation() {
    case "$ANIM_NAME" in
        xwing_deathstar) render_anim_xwing_deathstar ;;
        *) ;;
    esac
}

out=$(printf "${cyan}%s${normal}" "$model_str")
out="$out${sep}$(printf "${rp_red}%s${normal}" "$project")"
if [ -n "$branch_str" ]; then
    out="$out${sep}$branch_str"
fi
if [ -n "$ctx_str" ]; then
    out="$out${sep}$ctx_str"
fi

anim_str=""
if [ "$ANIM_ENABLED" = "true" ]; then
    # Claude Code sets COLUMNS/LINES to the real terminal size before running
    # this script (tput/stty can't see it here — the script's output is
    # captured, not connected to a tty). Cap the animation to whatever's
    # actually left on the line after the segments already built above, so
    # it can't run off the edge of the terminal or force a wrap.
    if [ -n "$COLUMNS" ]; then
        prefix_visible=$(printf '%s%s' "$out" "$sep" | sed 's/\x1b\[[0-9;]*m//g')
        ANIM_MAX_WIDTH_AVAIL=$((COLUMNS - ${#prefix_visible}))
    fi
    anim_str=$(render_animation)
fi
if [ -n "$anim_str" ]; then
    out="$out${sep}$anim_str"
fi

printf '%s' "$out"
