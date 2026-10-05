-- Command-line hints (like Excel's formula tooltips):
-- while you type a ":" command or a "/" search, a small window above the command line
-- shows the command's template, highlights the field you are typing, and explains it.
-- Toggle with :HintsToggle
local M = {}

vim.g.cmd_hints = vim.g.cmd_hints ~= false

------------------------------------------------------------------------------
-- Help text
------------------------------------------------------------------------------
local RANGE_HELP = {
  "%       whole file",
  ".       current line (the default)",
  "'<,'>   visual selection (select first, then press :)",
  "10,20   lines 10 to 20        .,$   from here to the end",
}

local REGEX_HELP = {
  "\\<word\\>  whole word only     .  any character    .*  anything",
  "\\c        ignore case          ^  line start       $   line end",
  "\\(...\\)   capture a group (use \\1 in the replacement)",
  "Empty = reuse your last search",
}

local SUB = {
  template = { "[range]", "s", "/", "{find}", "/", "{replace}", "/", "[flags]" },
  field_pos = { range = 1, find = 4, replace = 6, flags = 8 },
  help = {
    range = RANGE_HELP,
    find = vim.list_extend({ "Text to find (it's a pattern):" }, REGEX_HELP),
    replace = {
      "New text. Leave empty to delete what was found.",
      "&      the whole match           \\1 \\2  captured groups",
      "\\r     new line                  \\u \\U  uppercase next letter / the rest",
    },
    flags = {
      "g   every match in each line (without it: only the first)",
      "c   confirm each one:  y yes · n no · a all · q quit",
      "i   ignore case        n   just count, don't replace",
      "Example: :%s/v363/v769/gc    ·   u undoes it afterwards",
    },
  },
}

local GLOBAL = {
  template = { "[range]", "g", "/", "{pattern}", "/", "{command}" },
  field_pos = { range = 1, find = 4, command = 6 },
  help = {
    range = { "Default is the whole file" },
    find = vim.list_extend({ "Lines that contain this pattern:" }, REGEX_HELP),
    command = {
      "Runs on every matching line:",
      "d              delete the line       norm A;   add ; at the end",
      "s/a/b/         replace in the line   m$        move it to the end",
      "Use :v/.../ (or :g!) for lines that DON'T match",
    },
  },
}

local SEARCH = {
  "Search: type the text, Enter to jump · then n next / N previous",
  REGEX_HELP[1], REGEX_HELP[2], REGEX_HELP[3],
  "\\v     \"very magic\": ( ) | + ? work without backslashes",
}

local SORT = {
  "[range]sort[!] [i] [n] [u]",
  "!  reverse      i  ignore case      n  by number      u  remove duplicates",
  "Example: select lines (V), then :sort u",
}

local NORMAL = {
  "[range]norm {keys}  — types Normal-mode keys on every line",
  "Examples:  :%norm A;   add ; at the end of every line",
  "           :'<,'>norm I//   comment the selected lines",
}

local START = {
  "Common commands",
  "w  save           q  close window      qa  quit all       e {file}  open",
  "%s/a/b/gc  replace   g/pat/d  delete matching lines   noh  clear highlight",
  "set {option} · sort · norm {keys} · !{shell cmd} · help {topic}   Tab: complete · ↑↓: history",
}

local SET = {
  ":set {option}  on  ·  :set no{option}  off  ·  :set {option}!  toggle  ·  :set {option}?  show",
  "list               show spaces ␠, tabs → and trailing spaces •",
  "number  relativenumber   line numbers          wrap   wrap long lines",
  "expandtab  tabstop=4  shiftwidth=4   indentation (spaces, width)",
  "ignorecase  hlsearch  spell              cursorline  colorcolumn=80",
}

local AFTER_RANGE = {
  "Then a command:  s/…/…/ replace · d delete · y copy · norm {keys} · sort · g/…/…",
}

------------------------------------------------------------------------------
-- Parsing
------------------------------------------------------------------------------
-- Returns range_text, rest
local function split_range(line)
  local i, n = 1, #line
  while i <= n do
    local c = line:sub(i, i)
    if c:match("[%%%.%$%d,;%+%- ]") then
      i = i + 1
    elseif c == "'" and i < n then
      i = i + 2
    else
      break
    end
  end
  return line:sub(1, i - 1), line:sub(i)
end

-- Split on an unescaped delimiter; returns the list of parts so far
local function split_fields(s, delim)
  local parts, cur, i = {}, "", 1
  while i <= #s do
    local c = s:sub(i, i)
    if c == "\\" then
      cur = cur .. s:sub(i, i + 1)
      i = i + 2
    elseif c == delim then
      table.insert(parts, cur)
      cur = ""
      i = i + 1
    else
      cur = cur .. c
      i = i + 1
    end
  end
  table.insert(parts, cur)
  return parts
end

local function is_prefix(word, full, min)
  return #word >= min and full:sub(1, #word) == word
end

-- Build the hint for a structured command (template + help for the current field)
local function structured(spec, field)
  return { template = spec.template, active = spec.field_pos[field], help = spec.help[field] }
end

-- Returns { template=?, active=?, help={...} } or nil
function M.compute(cmdtype, line)
  if cmdtype == "/" or cmdtype == "?" then
    return { help = SEARCH }
  end
  if cmdtype ~= ":" then return nil end

  if line:match("^%s*$") then return { help = START } end

  local range, rest = split_range(line)
  if rest == "" then
    return { help = vim.list_extend(vim.deepcopy(RANGE_HELP), AFTER_RANGE) }
  end

  local name, after = rest:match("^(%a+)(.*)$")
  if not name then
    if rest:sub(1, 1) == "!" then return { help = { "!{command}  runs a shell command (e.g. :!make)" } } end
    return nil
  end

  -- :s / :substitute
  if is_prefix(name, "substitute", 1) and (after == "" or after:match("^[^%w%s\"|]")) then
    if after == "" then return { template = SUB.template, active = 2, help = { "Type / to start: :s/find/replace/flags" } } end
    local parts = split_fields(after:sub(2), after:sub(1, 1))
    local field = ({ "find", "replace", "flags" })[math.min(#parts, 3)]
    return structured(SUB, field)
  end

  -- :g / :v
  local is_global = name == "v" or name == "vglobal" or is_prefix(name, "global", 1)
  if is_global and (after == "" or after:match("^!?[^%w%s\"|]")) then
    local body = after:gsub("^!", "")
    if body == "" then return { template = GLOBAL.template, active = 2, help = { "Type / to start: :g/pattern/command" } } end
    local parts = split_fields(body:sub(2), body:sub(1, 1))
    return structured(GLOBAL, #parts >= 2 and "command" or "find")
  end

  if (name == "se" or name == "set" or name == "setlocal" or name == "setl") then return { help = SET } end
  if is_prefix(name, "sort", 3) then return { help = SORT } end
  if is_prefix(name, "normal", 4) then return { help = NORMAL } end
  return nil
end

------------------------------------------------------------------------------
-- Floating window
------------------------------------------------------------------------------
local ns = vim.api.nvim_create_namespace("cmdhints")
local win, buf

local function close()
  if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  win = nil
end

local function render(hint)
  local lines, marks = {}, {}
  if hint.template then
    local text, col = " ", 1
    for i, part in ipairs(hint.template) do
      if i == hint.active then table.insert(marks, { 0, col, col + #part, "IncSearch" }) end
      text = text .. part
      col = col + #part
    end
    table.insert(lines, text)
    table.insert(marks, { 0, 0, #text, "Title", 10 })
  end
  local first_help = #lines
  for _, l in ipairs(hint.help or {}) do table.insert(lines, " " .. l) end
  for r = first_help, #lines - 1 do
    table.insert(marks, { r, 0, #lines[r + 1], hint.template and "Comment" or (r == 0 and "Title" or "Comment"), 10 })
  end

  buf = (buf and vim.api.nvim_buf_is_valid(buf)) and buf or vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4], priority = m[5] or 200 })
  end

  local width = 0
  for _, l in ipairs(lines) do width = math.max(width, vim.api.nvim_strwidth(l)) end
  width = math.min(width + 1, vim.o.columns - 4)
  local cfg = {
    relative = "editor", anchor = "SW", style = "minimal", border = "rounded",
    row = vim.o.lines - vim.o.cmdheight - 1, col = 0,
    width = width, height = #lines, focusable = false, zindex = 250, noautocmd = true,
  }
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_config(win, cfg)
  else
    win = vim.api.nvim_open_win(buf, false, cfg)
  end
end

local function update()
  if not vim.g.cmd_hints then return close() end
  local ok, hint = pcall(M.compute, vim.fn.getcmdtype(), vim.fn.getcmdline())
  if not ok or not hint then return close() end
  render(hint)
  vim.cmd("redraw")
end

local group = vim.api.nvim_create_augroup("cmdhints", { clear = true })
vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineChanged" }, { group = group, callback = update })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, callback = close })

vim.api.nvim_create_user_command("HintsToggle", function()
  vim.g.cmd_hints = not vim.g.cmd_hints
  vim.notify("Command-line hints " .. (vim.g.cmd_hints and "on" or "off"))
end, { desc = "Show/hide the hints while typing : commands" })

return M
