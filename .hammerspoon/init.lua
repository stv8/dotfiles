hs.hotkey.bind({ 'cmd', 'alt', 'ctrl' }, 'W', function()
  hs.alert.show 'Hello World!'
end)

hs.loadSpoon 'AClock'
hs.hotkey.bind({ 'cmd', 'alt', 'ctrl' }, 'C', function()
  spoon.AClock:toggleShow()
end)

function bindHotkey(appName, key)
  hs.hotkey.bind({ 'Alt' }, key, function()
    local app = hs.application.find(appName)
    if app then
      if app:isFrontmost() then
        app:hide()
      else
        local nowspace = hs.spaces.focusedSpace()
        local screen = hs.screen.mainScreen()
        local app_window = app:mainWindow()
        hs.spaces.moveWindowToSpace(app_window, nowspace)
        local max = screen:fullFrame()
        local f = app_window:frame()
        f.x = max.x
        f.y = max.y
        f.w = max.w
        f.h = max.h
        hs.timer.doAfter(0.2, function()
          app_window:setFrame(f)
        end)
        app_window:focus()
      end
    end
  end)
end

bindHotkey('Wezterm', '`')
bindHotkey('Obsidian', 'o')
bindHotkey('Slack', 's')
bindHotkey('Chrome', 'c')

hs.hotkey.bind({}, 'F2', function()
  wez = hs.application.find 'Wezterm'
  if wez then
    if wez:isFrontmost() then
      wez:hide()
    else
      wez:activate()
    end
  end
end)
