# Neovim Cheat Sheet

Shortcuts for this configuration, plus the native Vim commands worth learning.

- `Space` is the **leader** key. `Space f g` means: press Space, then `f`, then `g` (one after another, not together).
- Press `Space` and wait a moment: a menu shows every option. Inside the explorer, press `?` for its own keys.
- Typing a `:` command or a `/` search shows a hint window with the template and what goes in each field.
- Lost? Press `Esc` to get back to Normal mode.

---

## Modes

| Key | Mode / action |
|-----|---------------|
| `i` / `a` | Insert before / after the cursor |
| `o` / `O` | New line below / above and insert |
| `v` / `V` | Select characters / whole lines (Visual mode) |
| `Esc` | Back to Normal mode |
| `:` | Command line (`Esc` cancels) |

## Files

| Keys | Action |
|------|--------|
| `Ctrl+S` | Save (any mode) |
| `:w` / `:wa` | Save / save all |
| `:q` / `:qa` | Close window / quit (asks if something is unsaved) |
| `:qa!` | Quit without saving |
| `:e path/file` | Open a file (`Tab` completes paths) |
| `%` / `%:h` | In `:` commands: the current file / its folder |

## Moving around

| Keys | Action |
|------|--------|
| `gg` / `G` | Start / end of file |
| `:120` | Go to line 120 |
| `w` / `b` | Next / previous word |
| `0` / `$` | Start / end of line |
| `%` | Jump to the matching bracket |
| `Ctrl+D` / `Ctrl+U` | Half page down / up |
| `Ctrl+O` / `Ctrl+I` | Back / forward to where you were |

## Editing

| Keys | Action |
|------|--------|
| `u` / `Ctrl+R` | Undo / redo |
| `dd` / `yy` / `p` | Cut line / copy line / paste |
| `Ctrl+C` / `Ctrl+X` | Copy / cut the selection |
| `Shift+Arrows` | Select by character / line |
| `Ctrl+Shift+←/→` | Select by word |
| `Ctrl+/` | Comment line or selection |
| `Alt+↑/↓` | Move line or selection |
| `Shift+Alt+↑/↓` | Duplicate line or selection |
| `yyp` | Duplicate line (native) |
| `Tab` / `Shift+Tab` | Indent / outdent the selection |
| `ciw` | Change the word under the cursor |

## Search and replace

| Keys | Action |
|------|--------|
| `Ctrl+F` or `/text` | Find in the current file, `Enter` to jump |
| `?text` | Find upwards |
| `n` / `N` | Next / previous match |
| `*` / `#` | Next / previous match of the word under the cursor |
| `Esc` | Clear the highlight |
| `:%s/old/new/g` | Replace everywhere in the file |
| `:%s/old/new/gc` | Replace, confirming each one (`y` yes, `n` no, `a` all, `q` quit) |
| `:%s/old/new/gci` | Same, ignoring upper/lower case |
| `:'<,'>s/old/new/g` | Replace only in the selection (select, then press `:`) |
| `:g/text/d` | Delete every line that contains `text` |
| `:v/text/d` | Delete every line that does NOT contain `text` |

Patterns: `\<word\>` whole word · `.` any character · `.*` anything · `\c` ignore case · `^` / `$` line start / end.

## Find in the project

| Keys | Action |
|------|--------|
| `Ctrl+P` or `Space f f` | Find a file by name (letters in order are enough: `vmsusdut`) |
| `Space f g` | Search text in all files |
| `Space f w` | Search the word under the cursor in all files |
| `Space f r` | Recent files |
| `Space f b` | Open tabs |
| `Space f d` | Problems (errors, warnings) |
| `Space p` | Command palette (all commands, fuzzy search) |

Inside the finder: `↑/↓` move, `Enter` open, `Esc` close.

## Explorer

| Keys | Action |
|------|--------|
| `Ctrl+B` | Show / hide the explorer |
| `Alt+E` | Jump to the explorer (also from a terminal) |
| `Enter` | Open file / expand folder |
| `a` | New file (end with `/` for a folder) |
| `r` / `d` | Rename / delete |
| `c` / `m` | Copy / move |
| `f` | Filter by exact name · `/` fuzzy filter · `Ctrl+X` clear filter |
| `z` | Collapse all |
| `.` / `Backspace` | Make this folder the root / go up one level |
| `H` | Show / hide hidden files |
| `←` / `→`, `Shift+Wheel` | Scroll sideways for long names · `Home` back to the left |
| `L` | Legend of the git icons |
| `T` | New terminal tab in this folder |
| `Ctrl+W` / `Space w` + arrow or `h/j/k/l` | Open the file in a new split on that side |
| `?` | All explorer keys |

## Splits and tabs

Each split has its own row of tabs.

| Keys | Action |
|------|--------|
| `Ctrl+W` / `Space w` + arrow or `h/j/k/l` | Move to the window on that side |
| `Ctrl+H/J/K/L` | Move between windows (also from a terminal) |
| `Space \` / `Space -` | Split the current file right / down |
| `Alt+←/→` | Previous / next tab in this window |
| `Space x`, `:CloseTab`, click `×`, middle click | Close the tab (the last tab closes the split) |
| `Space w c` or `:close` | Close the whole split |

## Terminal

| Keys | Action |
|------|--------|
| `` Ctrl+` `` or `Ctrl+\` | Show / hide the terminal panel |
| `Alt+N` | New terminal tab |
| `Alt+1` … `Alt+9` | Go to terminal tab 1–9 (also from inside a terminal) |
| Click a tab / `+` | Switch / new tab |
| `Space t r` or `:TermRename name` | Rename the terminal tab |
| `Space t x` or `exit` | Close the terminal tab |
| `Esc Esc` | Leave terminal mode (to scroll or copy); `i` to type again |

Hiding the panel doesn't stop what's running. Quitting nvim does.

## Code (C, C++, Python)

| Keys | Action |
|------|--------|
| `F12` or `gd` | Go to definition |
| `Shift+F12` or `gr` | Find references |
| `K` | Documentation |
| `F2` | Rename symbol everywhere |
| `Space c a` or `Ctrl+.` | Quick fix |
| `Alt+O` | Switch header / source |
| `Shift+Alt+F` | Format document |
| `F8` / `Shift+F8` | Next / previous problem · `Space e` show it in full |
| `Tab` | Accept a suggestion · `Ctrl+Space` open suggestions |

C/C++ needs a `compile_commands.json` (CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`).

## Git

| Keys | Action |
|------|--------|
| `Space g l` | Branch and commit graph (`Enter` on a commit shows it, `gq` closes) |
| `Space g d` | Uncommitted changes, side by side |
| `Space g h` / `Space g H` | History of this file / of the project |
| `Space g q` | Close the diff view |
| `]h` / `[h` | Next / previous change in the file |
| `Space g p` / `Space g r` | Preview / discard the change under the cursor |
| `:DiffviewOpen origin/main -- %` | Compare this file with another branch (`git fetch` first) |

Inside any diff: `]c` / `[c` next / previous difference · `do` take the other side · `dp` send this side · `:diffoff!` leave.

## Sessions

| Command | Opens |
|---------|-------|
| `nvim` | The last folder you worked in, with its tabs |
| `nvim .` / `nvim folder` | That folder, with its tabs |
| `nvim file` | Only that file (saved tabs are left alone) |

`Space q l` pick another folder's session · `Space q d` don't save this session.

## Keeping this config up to date

| Command | Action |
|---------|--------|
| `:UpdateConfig` | Download the latest version, then restart nvim |
| `:Lazy` | Plugins (install, update) |
| `:Mason` | Language servers and formatters |
| `:LspInfo` | Is the language server attached? |
| `:HintsToggle` | Turn the command-line hints on / off |
| `:checkhealth` | General diagnosis |

## When something goes wrong

- Keys do something odd → `Esc` and try again in Normal mode.
- Stuck in the `:` line → `Esc`.
- Pasting into nvim: use the terminal's paste (`Ctrl+Shift+V` in Windows Terminal). In the classic console: `:set mouse=`, right-click to paste, then `:set mouse=a`.
- Opened an extra window by accident → `:close` inside it.
