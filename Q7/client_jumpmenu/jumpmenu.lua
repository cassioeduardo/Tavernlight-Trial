-- Setup local variables, even though I set it to be "sandboxed" it's just good practice to never have global variables be crated in this environment.
local jumpMenu
local jumpButton

local event

local moveDirection = 1

-- Setup everything.
function init()
    g_keyboard.bindKeyDown('Ctrl+J', toggle) -- Set the keybind to open the window.
    
    jumpMenu = g_ui.displayUI('jumpmenu') -- Load the menu data.
    jumpMenu:hide()

    jumpButton = jumpMenu:getChildById('jumpButton') -- Find the button.
end

-- Cleanup everything.
function terminate()
    g_keyboard.unbindKeyDown('Ctrl+J')

    jumpMenu:destroy()
    jumpButton:destroy()

    removeEvent(event)
end

function show()
    -- Check if it is ingame.
    if not g_game.isOnline() then
        return
    end

    -- Show the window and set focus.
    jumpMenu:show()
    jumpMenu:raise()
    jumpMenu:focus()

    -- Center the button every time the window is shown.
    local jumpMenuPaddingRect = jumpMenu:getPaddingRect()

    jumpButton:setPosition({x = jumpMenuPaddingRect.x + jumpMenuPaddingRect.width/2, y = jumpMenuPaddingRect.y + jumpMenuPaddingRect.height/2})

    -- Create the event that moves the button and keeps it inside the window's bounds.
    event = cycleEvent(function()
        local jumpMenuPaddingRect = jumpMenu:getPaddingRect()
        local jumpButtonRect = jumpButton:getRect()

        -- Bound check.
        if jumpButtonRect.x <= jumpMenuPaddingRect.x or jumpButtonRect.x + jumpButtonRect.width >= jumpMenuPaddingRect.x + jumpMenuPaddingRect.width then
            moveDirection = moveDirection*-1 -- Flip direction when out of bounds.
        end

        jumpButton:setPosition({x = jumpButtonRect.x + moveDirection, y = jumpButtonRect.y}) -- Move the button.
    end, 1000/60)
end

function hide()
    jumpMenu:hide()

    removeEvent(event)
end

function toggle()
    if jumpMenu:isVisible() then
        hide()
    else
        show()
    end
end

-- Funcion that gets called "onClick".
function jump()
    local jumpMenuHeight = jumpMenu:getHeight()
    local jumpButtonPosition = jumpButton:getPosition()

    jumpButton:setPosition({x = jumpButtonPosition.x, y = jumpButtonPosition.y + math.random(-50, 50)}) -- Make the button jump up/down.
end