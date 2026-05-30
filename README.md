# pomodoro.sh

A terminal Pomodoro timer for macOS and Linux — no dependencies beyond the shell.

---

## Features

- Works on **macOS** and **Linux** out of the box
- Native desktop notifications (`osascript` on macOS, `notify-send` on Linux)
- Native audio playback (`afplay` on macOS, `play`/sox on Linux)
- Countdown timer displayed in the terminal
- Automatic **long break** every N sessions
- Configurable work/break durations via flags
- Session counter and total focus time on exit
- Log file at `/tmp/pomodoro.log`
- Graceful exit on `Ctrl+C` with session summary

---

## Usage

```bash
./pomodoro.sh [-w WORK_MIN] [-b BREAK_MIN] [-l LONG_BREAK_MIN] [-s SESSIONS]
```

| Flag | Description | Default |
|---|---|---|
| `-w` | Work duration (minutes) | 25 |
| `-b` | Short break duration (minutes) | 5 |
| `-l` | Long break duration (minutes) | 15 |
| `-s` | Sessions before long break | 4 |

**Examples:**

```bash
# Default Pomodoro (25/5)
./pomodoro.sh

# Custom: 50 min work, 10 min break, long break every 3 sessions
./pomodoro.sh -w 50 -b 10 -s 3

# Help
./pomodoro.sh -h
```

---

## Session flow

```
Session 1 → Focus 25min → Short break 5min
Session 2 → Focus 25min → Short break 5min
Session 3 → Focus 25min → Short break 5min
Session 4 → Focus 25min → Long break  15min  ← repeats
```

---

## Requirements

**macOS:** nothing to install — uses `osascript` and `afplay` (built-in).

**Linux:** optional packages for notifications and audio:
```bash
# Debian/Ubuntu
sudo apt install libnotify-bin sox

# Arch
sudo pacman -S libnotify sox
```

The timer runs without them — notifications and audio are silently skipped if unavailable.

---

## Author

Julio Mauro · [github.com/juliomauro](https://github.com/juliomauro)
