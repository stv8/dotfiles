-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

config.set_environment_variables = {
  PATH = '/opt/homebrew/bin:' .. os.getenv 'PATH',
}

-- config.color_scheme = 'Tokyo Night'
config.color_scheme = 'catppuccin-macchiato'

-- Slightly transparent and blurred background
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30
-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = 'RESIZE|INTEGRATED_BUTTONS'
-- Sets the font for the window frame (tab bar)
config.window_frame = {
  -- Berkeley Mono for me again, though an idea could be to try a
  -- serif font here instead of monospace for a nicer look?
  font = wezterm.font { family = 'JetBrains Mono', weight = 'Bold' },
  font_size = 12,
}
-- config.window_background_image = "/Users/sean/Documents/backgrounds/eva-3.jpg"
config.window_background_image_hsb = {
  -- Darken the background image by reducing it to 1/3rd
  brightness = 0.3,
  -- You can adjust the hue by scaling its value.
  -- a multiplier of 1.0 leaves the value unchanged.
  hue = 1.0,
  -- You can adjust the saturation also.
  saturation = 1.0,
}

config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '1.0cell',
  bottom = '0',
}

config.tab_bar_at_bottom = true

-- disable ligatures
config.font = wezterm.font {
  family = 'JetBrains Mono',
  weight = 'Medium',
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
}

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }

local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  Left = 'h',
  Down = 'j',
  Up = 'k',
  Right = 'l',
  -- reverse lookup
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

config.keys = {
  { key = 'LeftArrow', mods = 'CMD', action = act.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = 'CMD', action = act.ActivateTabRelative(1) },
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  { key = 'LeftArrow', mods = 'OPT', action = act.SendString '\x1bb' },
  -- Make Option-Right equivalent to Alt-f; forward-word
  { key = 'RightArrow', mods = 'OPT', action = act.SendString '\x1bf' },
  -- splitting
  {
    mods = 'LEADER',
    key = '-',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    mods = 'LEADER',
    key = '=',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    mods = 'LEADER',
    key = 'm',
    action = wezterm.action.TogglePaneZoomState,
  },
  -- rotate panes
  {
    mods = 'LEADER',
    key = 'Space',
    action = wezterm.action.RotatePanes 'Clockwise',
  },
  -- show the pane selection mode, but have it swap the active and selected panes
  {
    mods = 'LEADER',
    key = '0',
    action = wezterm.action.PaneSelect {
      mode = 'SwapWithActive',
    },
  },
  {
    key = 'k',
    mods = 'CMD',
    action = act.ClearScrollback 'ScrollbackAndViewport',
  },
  {
    -- create a 1:2 split pane
    key = 't',
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      local new_pane = pane:split { direction = 'Right' }
      new_pane:split { direction = 'Top' }
      new_pane:split { direction = 'Top' }
    end),
  },
  {
    -- Display Tab Navigator
    key = 't',
    mods = 'CMD|SHIFT',
    action = act.ShowTabNavigator,
  },
  {
    key = ',',
    mods = 'SUPER',
    action = wezterm.action.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      args = { 'nvim', wezterm.config_file },
    },
  },
  -- Workspace switching (like tmux sessions)
  {
    key = 's',
    mods = 'LEADER',
    action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
  },
  {
    key = 'n',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:perform_action(
            act.SwitchToWorkspace { name = line },
            pane
          )
        end
      end),
    },
  },
  {
    key = 'w',
    mods = 'LEADER',
    action = act.SwitchToWorkspace,
  },
  {
    key = '[',
    mods = 'LEADER',
    action = act.SwitchWorkspaceRelative(-1),
  },
  {
    key = ']',
    mods = 'LEADER',
    action = act.SwitchWorkspaceRelative(1),
  },
  -- Move current tab left/right
  {
    key = '{',
    mods = 'LEADER',
    action = act.MoveTabRelative(-1),
  },
  {
    key = '}',
    mods = 'LEADER',
    action = act.MoveTabRelative(1),
  },
  -- move between split panes
  split_nav('move', 'h'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),
  -- resize panes
  split_nav('resize', 'h'),
  split_nav('resize', 'j'),
  split_nav('resize', 'k'),
  split_nav('resize', 'l'),
  {
    key = 'c',
    mods = 'CMD',
    action = wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        window:perform_action(wezterm.action.SendKey { key = 'y', mods = 'CMD' }, pane)
      else
        window:perform_action(wezterm.action { CopyTo = 'ClipboardAndPrimarySelection' }, pane)
      end
    end),
  },
}

for i = 1, 8 do
  -- CTRL+ALT + number to move to that position
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL|ALT',
    action = wezterm.action.MoveTab(i - 1),
  })
end

-- Smart tab titles: show process name or directory
local function get_dir_name(pane)
  local cwd = pane.current_working_dir
  if cwd then
    local path = cwd.file_path or ''
    local dir = string.match(path, '([^/]+)/?$') or path
    if dir == os.getenv('USER') then
      return '~'
    end
    return dir
  end
  return nil
end

local function tab_title(tab_info)
  local title = tab_info.tab_title
  local pane = tab_info.active_pane
  local process = pane.foreground_process_name

  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the active pane's process or title
  if process then
    -- Detect Claude Code (path contains /claude/versions/)
    -- Let Claude Code's own pane title (with status icons) pass through
    if string.find(process, '/claude/', 1, true) then
      return pane.title or 'claude'
    end

    -- Extract just the executable name
    process = string.gsub(process, '(.*[/\\])(.*)', '%2')

    -- Skip generic shells/runtimes, show directory instead
    local show_dir_instead = { zsh = true, bash = true, fish = true, node = true }
    if not show_dir_instead[process] then
      return process
    end
  end
  -- For shells spawned by Claude Code, pass through Claude's pane title
  local pane_title = pane.title or ''
  if string.find(pane_title, 'Claude Code', 1, true) then
    return pane_title
  end
  return get_dir_name(pane) or pane_title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab_title(tab)
  -- Truncate if too long
  if #title > max_width - 3 then
    title = string.sub(title, 1, max_width - 5) .. '…'
  end
  return {
    { Text = ' ' .. (tab.tab_index + 1) .. ': ' .. title .. ' ' },
  }
end)

-- Cache for memory usage (avoid running command too frequently)
local mem_cache = { value = '', last_update = 0 }

local function get_memory_usage()
  local now = os.time()
  -- Only update every 15 seconds
  if now - mem_cache.last_update < 15 then
    return mem_cache.value
  end

  local success, stdout = wezterm.run_child_process {
    'bash', '-c', "top -l 1 -s 0 | awk '/PhysMem/ {print $2}'"
  }
  if success then
    mem_cache.value = '󰍛 ' .. stdout:gsub('%s+', '')
    mem_cache.last_update = now
  end
  return mem_cache.value
end

local function segments_for_right_status(window)
  return {
    window:active_workspace(),
    get_memory_usage(),
    wezterm.strftime '%a %b %-d %H:%M',
    wezterm.hostname(),
  }
end

local function is_dark()
  -- wezterm.gui is not always available, depending on what
  -- environment wezterm is operating in. Just return true
  -- if it's not defined.
  if wezterm.gui then
    -- Some systems report appearance like "Dark High Contrast"
    -- so let's just look for the string "Dark" and if we find
    -- it assume appearance is dark.
    return wezterm.gui.get_appearance():find 'Dark'
  end
  return true
end

wezterm.on('update-status', function(window, _)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local segments = segments_for_right_status(window)

  local color_scheme = window:effective_config().resolved_palette
  -- Note the use of wezterm.color.parse here, this returns
  -- a Color object, which comes with functionality for lightening
  -- or darkening the colour (amongst other things).
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground

  -- Each powerline segment is going to be coloured progressively
  -- darker/lighter depending on whether we're on a dark/light colour
  -- scheme. Let's establish the "from" and "to" bounds of our gradient.
  local gradient_to, gradient_from = bg
  if is_dark() then
    gradient_from = gradient_to:lighten(0.2)
  else
    gradient_from = gradient_to:darken(0.2)
  end

  -- Yes, WezTerm supports creating gradients, because why not?! Although
  -- they'd usually be used for setting high fidelity gradients on your terminal's
  -- background, we'll use them here to give us a sample of the powerline segment
  -- colours we need.
  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )

  -- We'll build up the elements to send to wezterm.format in this table.
  local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)

-- Triple-click selects entire command output (semantic zone)
config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = 'Left' } },
    action = act.SelectTextAtMouseCursor 'SemanticZone',
    mods = 'NONE',
  },
}

-- and finally, return the configuration to wezterm
return config
