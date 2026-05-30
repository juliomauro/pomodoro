#!/bin/bash
# pomodoro.sh — Pomodoro timer for macOS and Linux
# Author: Julio Mauro <julio.mauro@gmail.com>
#
# Usage: ./pomodoro.sh [-w WORK_MIN] [-b BREAK_MIN] [-s SESSIONS]
#   -w  Work duration in minutes   (default: 25)
#   -b  Break duration in minutes  (default: 5)
#   -s  Number of sessions before long break (default: 4)
#   -l  Long break duration in minutes (default: 15)

# ── Colors ────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Defaults ──────────────────────────────────────────────────
WORK_MIN=25
BREAK_MIN=5
LONG_BREAK_MIN=15
SESSIONS_BEFORE_LONG=4

# ── Parse arguments ───────────────────────────────────────────
while getopts "w:b:l:s:h" opt; do
  case "$opt" in
    w) WORK_MIN="$OPTARG" ;;
    b) BREAK_MIN="$OPTARG" ;;
    l) LONG_BREAK_MIN="$OPTARG" ;;
    s) SESSIONS_BEFORE_LONG="$OPTARG" ;;
    h)
      echo -e "${BOLD}Usage:${RESET} $0 [-w work_min] [-b break_min] [-l long_break_min] [-s sessions]"
      echo -e "  ${CYAN}-w${RESET}  Work duration in minutes         (default: 25)"
      echo -e "  ${CYAN}-b${RESET}  Short break duration in minutes  (default: 5)"
      echo -e "  ${CYAN}-l${RESET}  Long break duration in minutes   (default: 15)"
      echo -e "  ${CYAN}-s${RESET}  Sessions before long break       (default: 4)"
      exit 0
      ;;
    ?) exit 1 ;;
  esac
done

WORK_SEC=$((WORK_MIN * 60))
BREAK_SEC=$((BREAK_MIN * 60))
LONG_BREAK_SEC=$((LONG_BREAK_MIN * 60))

# ── Detect OS ─────────────────────────────────────────────────
OS=$(uname -s)

notify() {
  local title="$1"
  local msg="$2"
  case "$OS" in
    Darwin) osascript -e "display notification \"$msg\" with title \"$title\"" 2>/dev/null ;;
    Linux)  notify-send "$title" "$msg" --icon=dialog-information 2>/dev/null ;;
  esac
}

play_sound() {
  local file="$1"
  local dir
  dir="$(cd "$(dirname "$0")" && pwd)/sound"
  if [ ! -f "$dir/$file" ]; then return; fi
  case "$OS" in
    Darwin) afplay "$dir/$file" &>/dev/null & ;;
    Linux)  play "$dir/$file" &>/dev/null 2>&1 & ;;
  esac
}

# ── Countdown display ─────────────────────────────────────────
countdown() {
  local seconds="$1"
  local label="$2"
  local color="$3"
  while [ "$seconds" -gt 0 ]; do
    local mins=$(( seconds / 60 ))
    local secs=$(( seconds % 60 ))
    printf "\r  ${color}%-20s${RESET}  ${BOLD}%02d:%02d${RESET}  " "$label" "$mins" "$secs"
    sleep 1
    seconds=$(( seconds - 1 ))
  done
  printf "\r  %-20s  ${BOLD}%02d:%02d${RESET}  \n" "$label" 0 0
}

# ── Cleanup on Ctrl+C ─────────────────────────────────────────
session=0
total_work=0

cleanup() {
  echo -e "\n\n${YELLOW}Pomodoro interrupted.${RESET}"
  echo -e "  Sessions completed : ${BOLD}$session${RESET}"
  echo -e "  Total focus time   : ${BOLD}$(( total_work / 60 )) min${RESET}"
  echo -e "  Log                : ${CYAN}/tmp/pomodoro.log${RESET}\n"
  exit 0
}
trap cleanup SIGINT SIGTERM

# ── Header ────────────────────────────────────────────────────
clear
echo -e "${BOLD}${CYAN}"
echo "  ╔═══════════════════════════════╗"
echo "  ║        🍅  POMODORO           ║"
echo "  ╚═══════════════════════════════╝"
echo -e "${RESET}"
echo -e "  Work    ${BOLD}${WORK_MIN} min${RESET}  ·  Break ${BOLD}${BREAK_MIN} min${RESET}  ·  Long break ${BOLD}${LONG_BREAK_MIN} min${RESET} (every ${BOLD}${SESSIONS_BEFORE_LONG}${RESET} sessions)"
echo -e "  Press ${BOLD}Ctrl+C${RESET} to stop\n"

LOG="/tmp/pomodoro.log"
echo "=== Pomodoro started $(date) ===" >> "$LOG"

# ── Main loop ─────────────────────────────────────────────────
while true; do
  session=$(( session + 1 ))
  total_work=$(( total_work + WORK_SEC ))

  echo -e "\n  ${GREEN}${BOLD}Session $session${RESET} — Focus"
  notify "🍅 Pomodoro — Session $session" "Focus on your task for ${WORK_MIN} minutes."
  echo "work session=$session start=$(date)" >> "$LOG"

  countdown "$WORK_SEC" "Session $session — Focus" "$GREEN"
  play_sound "work.mp3"

  # Long break every N sessions
  if (( session % SESSIONS_BEFORE_LONG == 0 )); then
    echo -e "\n  ${YELLOW}${BOLD}Long break!${RESET} ${LONG_BREAK_MIN} min — you earned it."
    notify "☕ Long Break" "Great work! Take ${LONG_BREAK_MIN} minutes."
    echo "long_break session=$session start=$(date)" >> "$LOG"
    countdown "$LONG_BREAK_SEC" "Long break" "$YELLOW"
    play_sound "break.mp3"
  else
    echo -e "\n  ${CYAN}${BOLD}Short break.${RESET} ${BREAK_MIN} min."
    notify "⏸ Short Break" "Take ${BREAK_MIN} minutes."
    echo "short_break session=$session start=$(date)" >> "$LOG"
    countdown "$BREAK_SEC" "Short break" "$CYAN"
    play_sound "break.mp3"
  fi
done
