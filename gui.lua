-- [[ Requires ]] --
local component = require("component")
local computer = require("computer")
local event = require("event")
local thread = require("thread")

local gpu = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

local GUI = {}

-- [[ Colors ]] --
GUI.colors = {
    ["white"] = 0xFFFFFF,
    ["orange"] = 0xFFA500,
    ["magenta"] = 0xFF00FF,
    ["lightblue"] = 0xADD8E6,
    ["yellow"] = 0xFFFF00,
    ["lime"] = 0x32cd32,
    ["pink"] = 0xFFC0CB,
    ["gray"] = 0x808080,
    ["silver"] = 0xC0C0C0,
    ["cyan"] = 0x00FFFF,
    ["purple"] = 0x800080,
    ["blue"] = 0x0000F,
    ["brown"] = 0x964B00,
    ["green"] = 0x008000,
    ["red"] = 0xFF0000,
    ["black"] = 0x000000
}

-- [[ Elements settings ]] --

GUI.Screen = {}  -- Screen settings
GUI.Canvas = {}  -- Canvases settings
GUI.Buttons = {} -- Buttons settings
GUI.Texts = {}   -- Texts settings
GUI.Widgets = {} -- Widgets settings

GUI.Screen.width = screenWidth
GUI.Screen.height = screenHeight
GUI.Screen.x = 1
GUI.Screen.y = 1
GUI.Screen.background = GUI.colors.black
GUI.Screen.foreground = GUI.colors.white

GUI.Canvas.Workspace = {}
GUI.Canvas.Navbar = {}

GUI.Canvas.Workspace.height = screenHeight - 1
GUI.Canvas.Workspace.width = screenWidth
GUI.Canvas.Workspace.x = 1
GUI.Canvas.Workspace.y = 2
GUI.Canvas.Workspace.background = GUI.colors.white
GUI.Canvas.Workspace.foreground = GUI.colors.black

GUI.Canvas.Navbar.height = 1
GUI.Canvas.Navbar.width = screenWidth
GUI.Canvas.Navbar.x = 1
GUI.Canvas.Navbar.y = 1
GUI.Canvas.Navbar.background = GUI.colors.gray
GUI.Canvas.Navbar.foreground = GUI.colors.black

GUI.Buttons.Shutdown = {}
GUI.Buttons.Shutdown.x = 1
GUI.Buttons.Shutdown.y = 1
GUI.Buttons.Shutdown.width = 2
GUI.Buttons.Shutdown.height = 1
GUI.Buttons.Shutdown.active = true
GUI.Buttons.Shutdown.label = " "
GUI.Buttons.Shutdown.background = GUI.colors.red
GUI.Buttons.Shutdown.foreground = GUI.colors.black
GUI.Buttons.Shutdown.onClick = function()
    GUI.Methods.drawText("Goodbye")
    os.sleep(1)
    computer.beep()
    os.execute("clear")
    os.exit()
    -- computer.shutdown(false)
end

GUI.Texts.Goodbye = {}
GUI.Texts.Goodbye.Content = "See ya later"
GUI.Texts.Goodbye.x = 74
GUI.Texts.Goodbye.y = 25
GUI.Texts.Goodbye.background = GUI.colors.black
GUI.Texts.Goodbye.foreground = GUI.colors.white
GUI.Texts.Goodbye.isFullscreen = true

GUI.Widgets.TextList = {}
-- Parent canvas
GUI.Widgets.TextList.Parent = {}
GUI.Widgets.TextList.Parent.minX = GUI.Canvas.Workspace.x
GUI.Widgets.TextList.Parent.minY = GUI.Canvas.Workspace.y
GUI.Widgets.TextList.Parent.maxX = GUI.Canvas.Workspace.width
GUI.Widgets.TextList.Parent.maxY = GUI.Canvas.Workspace.height
GUI.Widgets.TextList.Content = {}
for i = 1, 100 do
    GUI.Widgets.TextList.Content[i] = tostring(i)
end
GUI.Widgets.TextList.x = 4
GUI.Widgets.TextList.y = 2
GUI.Widgets.TextList.background = GUI.colors.white
GUI.Widgets.TextList.foreground = GUI.colors.black
GUI.Widgets.TextList.ScrollSettings = {}
GUI.Widgets.TextList.ScrollSettings.minI = 1
GUI.Widgets.TextList.ScrollSettings.maxI = GUI.Widgets.TextList.Parent.maxY - 2
GUI.Widgets.TextList.ScrollSettings.scrollOffset = 0
GUI.Widgets.TextList.ScrollSettings.scrollPointerOffset = 3

-- [[ Functions ]] --

GUI.Methods = {}

GUI.Methods.drawCanvases = function()
    for _, canvas in pairs(GUI.Canvas) do
        gpu.setBackground(canvas.background)
        gpu.fill(canvas.x, canvas.y, canvas.width, canvas.height, " ")
    end
end

GUI.Methods.drawButtons = function()
    for _, button in pairs(GUI.Buttons) do
        gpu.setBackground(button.background)
        gpu.fill(button.x, button.y, button.width, button.height, button.label)
    end
end

GUI.Methods.drawText = function(textName)
    local text = GUI.Texts[textName]
    local screen = GUI.Screen

    gpu.setBackground(text.background)
    gpu.setForeground(text.foreground)

    if text.isFullscreen then
        gpu.fill(screen.x, screen.y, screen.width, screen.height, " ")
    end
    gpu.set(text.x, text.y, text.Content)
end

GUI.Methods.drawWidget = function(widgetName, scrollDirection)
    local widget = GUI.Widgets[widgetName]
    local scroll = widget.ScrollSettings

    local minI = scroll.minI
    local maxI = scroll.maxI

    -- Invert the scroll direction for right scrolling
    scrollDirection = -scrollDirection
    local currentOffset = scroll.scrollOffset
    local resultOffset = currentOffset + scrollDirection

    if (minI + resultOffset < 1) or (maxI + resultOffset > 100) then
        minI = minI + currentOffset
        maxI = maxI + currentOffset
        scroll.scrollOffset = currentOffset
    else
        minI = minI + resultOffset
        maxI = maxI + resultOffset
        scroll.scrollOffset = resultOffset
    end

    gpu.setBackground(widget.background)
    gpu.setForeground(widget.foreground)

    local posY = widget.y
    for i = minI, maxI do
        gpu.set(widget.x, posY + 1, tostring(widget.Content[i]))
        posY = posY + 1
    end

  if scroll.scrollOffset % 3 == 0 and scrollDirection > 0 then
    scroll.scrollPointerOffset = scroll.scrollPointerOffset + 1
  end

  if scroll.scrollOffset % 3 == 0 and scrollDirection < 0 then
    scroll.scrollPointerOffset = scroll.scrollPointerOffset - 1
  end 

  gpu.setBackground(GUI.colors.silver)
  gpu.fill(2, 3, 1, screenHeight - 3, " ")
  gpu.setBackground(GUI.colors.black)
  gpu.fill(2, scroll.scrollPointerOffset, 1, 3, " ")

end


GUI.Methods.logEvent = function(name)
    local x, y = 80, 1
    gpu.setBackground(GUI.colors.gray)
    gpu.setForeground(GUI.colors.black)
    gpu.fill(x, y, screenWidth, 1, " ")
    gpu.set(x, y, name)
end

GUI.Methods.callDraws = function()
    local methods = GUI.Methods
    methods.drawCanvases()
    methods.drawButtons()
    methods.drawWidget("TextList", 0)
end

GUI.Methods.clearScreen = function()
    local screen = GUI.Screen

    gpu.setBackground(screen.background)
    gpu.setForeground(screen.foreground)
    gpu.fill(screen.x, screen.y, screen.width, screen.height, " ")
end

GUI.Methods.callDraws()

while true do
    local methods = GUI.Methods
    local scroll, _, _, _, direction = event.pull(0.000000001, "scroll")
    if scroll == "scroll" then
        methods.drawWidget("TextList", direction)
    end

    --local touch, _, x, y = event.pull(0.000000001, "touch")
    --[[
    if touch == "touch" then
        for _, button in pairs(GUI.Buttons) do
            local isTouched = x >= button.x
                and x < button.x + button.width + 2
                and y >= button.y
                and y < button.y + button.height
                and button.active
            if isTouched then
                button.onClick()
            end
        end
    end
    --]]
    
    methods.clearScreen()
    methods.callDraws()
end