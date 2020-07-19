-- Open TriggerRemap Config
if System.doesFileExist("ux0:data/TriggerRemap.txt")
then
    cfg = System.openFile("ux0:data/TriggerRemap.txt", FREAD) -- Open cfg file
    System.seekFile(cfg, 0, SET)
    cfgText = System.readFile(cfg, 33)
    System.closeFile(cfg)
end
pad = Controls.read()

-- L2=X:500,Y:350;R2=X:1300,Y:350 Default

-- Colors
white = Color.new(255,255,255)
eBlue = Color.new(125, 255, 196)
eYellow = Color.new(249, 255, 125)
ePurp = Color.new(131, 125, 255)
pRed = Color.new(255, 125, 184)
red = Color.new(255, 0, 0)

-- Fonts
local aBoy = Font.load("app0:fonts/astron boy.ttf")
local aBoyI = Font.load("app0:fonts/astron boy italic.ttf")
local aBoyV = Font.load("app0:fonts/astron boy video.ttf")
local aBoyW = Font.load("app0:fonts/astron boy wonder.ttf")

-- Decide if Config File exists in Correct location
function configLocate()
    local ux0Loc = "ux0:data/TriggerRemap.txt"
    local ur0Loc = "ur0:tai/TriggerRemap.txt"
    local ur0Error = "Config exists in ur0:tai please move to ux0:data"
    local Error = "Config does not exist"
    if System.doesFileExist(ux0Loc) then return ux0Loc
    elseif System.doesFileExist(ur0Loc) then return ur0Error
    else return Error end
end

-- Center Text -- Deprecated
function centerText(axis, fontSize, stringLength)
    if (axis == "x") then location = (960/2) - (fontSize/2) - (stringLength)
    elseif (axis == "y") then location = (544/2) - (fontSize/2)
    else end
    return location
end

-- Get Text Length
function stringLength(startX, startY, endX, R, G, B, fntSize)

    --Define ending Y value parameter for scanning
    local endY = startY + fntSize + 5

    --Create X and Y Arrays for storing all current coord locations
    local aX = {}
    local aY = {}
    local i = 0
    local Co0rdx = 0
    local CoOrdy = 0
    --Scan entire defined pixel range and output values to appropriate locations in aX[] and aY[]
    for CoOrdx = startX, endX, 1
    do
        i = i + 1
        aX[i] = CoOrdx
    end
    local i = 0
    for CoOrdy = startY, endY, 1
    do
        i = i + 1
        aY[i] = CoOrdy
    end
    --Create Array to store pixels occupied with supplied color
    local aT = {}
    aT[1] = {}
    aT[2] = {}
    local j = 1
    --Scan all defined aX, aY values and check for color of pixel, if it's equal to defined R, G, B then push aX, aY cords to aT if not push 0, 0 to aT
    for i = 1, endY - startY, 1
    do
        for i2 = 1, endX - startX, 1
        do
            local pixel_color = Screen.getPixel(aX[i2], aY[i])
            local compR = Color.getR(pixel_color)
            local compG = Color.getG(pixel_color)
            local compB = Color.getB(pixel_color)
            if(compR == R and compG == G and compB == B)
            then
                aT[1][j] = aX[i2]
                aT[2][j] = aY[i]
                j = j + 1
            else
                aT[1][j] = 0
                aT[2][j] = 0
                j = j + 1
            end
        end
    end

    --Sort X table highest to lowest, return highest value
    table.sort(aT[1])
    return aT[1][#aT[1]]
end

-- Get X Values
while true do
    
    Graphics.initBlend()
    Screen.clear()

    Font.setPixelSizes(aBoyW, 72)
    Font.setPixelSizes(aBoyI, 25)
    Font.setPixelSizes(aBoy, 40)

    Font.print(aBoy, 780, 490, "LOADING", white)

    Font.print(aBoyW, 10, 100, "TriggerRemap", Color.new(0, 0, 1))
    XValTitleLocText = stringLength(10, 100, 500, 0, 0, 1, 72)

    Font.setPixelSizes(aBoyI, 25)
    Font.print(aBoyI, 10, 50, "R2/L2 Remap to Rear TouchPad", Color.new(0, 0, 1))
    XValInfoLocText = stringLength(10, 50, 500, 0, 0, 1, 25)

    Font.print(aBoyI, 10, 10, "Config Location: " .. configLocate(), Color.new(0, 0, 1))
    XValConfigLocText = stringLength(10, 10, 500, 0, 0, 1, 25)

    Graphics.termBlend()
    Screen.flip()
    if (whileLoopBreak == 1)
    then
        whileLoopBreak = 0
        break
    end
    whileLoopBreak = 1
end

-- Screen Layout
function drawScreen()
    --Initial Font Sizes
    Font.setPixelSizes(aBoyV, 72)
    Font.setPixelSizes(aBoy, 25)
    Font.setPixelSizes(aBoyW, 72)
    Font.setPixelSizes(aBoyI, 25)
    --Start Drawing Stuff
    Graphics.fillRect(230, 430, 340, 430, eBlue) --Left Remap Button
    Font.print(aBoy, 288, 343, "REMAP", eYellow)
    Font.print(aBoyV, 280, 348, "L2", eYellow)
    Graphics.fillRect(530, 730, 340, 430, eBlue) --Right Remap Button
    Font.print(aBoy, 588, 343, "REMAP", eYellow)
    Font.print(aBoyV, 580, 348, "R2", eYellow)
    Graphics.fillRect(10, 130, 500, 534, eBlue) --Reset Button Rect
    Font.setPixelSizes(aBoy, 30)
    Font.print(aBoyW, (960/2) - (XValTitleLocText/2), 35, "TriggerRemap", ePurp) --Draw Title
    Font.print(aBoyI, (960/2) - (XValInfoLocText/2), 120, "R2/L2 Remap to Rear TouchPad", eBlue) --Draw Info
    Font.print(aBoyI, (960/2) - (XValConfigLocText/2), 145, "Config Location: " .. configLocate(), eBlue) --Draw Config Location
    if System.doesFileExist("ux0:data/TriggerRemap.txt")
    then
        Font.print(aBoy, 33, 496, "Reset", red) --Draw Reset Button Text
    else
        Font.print(aBoy, 31, 496, "Create", ePurp)
    end
    if System.doesFileExist("ux0:data/TriggerRemap.txt")
    then
        local cfg = System.openFile("ux0:data/TriggerRemap.txt", FRDWR)
        local cfgText = System.readFile(cfg, 33)
        local L2X, L2Y, R2X, R2Y = cfgText:match("(%d+),Y:(%d+);R2=X:(%d+),Y:(%d+)")
        System.closeFile(cfg)
        Graphics.fillRect(230, 430, 302, 332, pRed)
        Font.print(aBoyI, 234, 300, "L2:" .. L2X .. "," .. L2Y, eBlue)
        Graphics.fillRect(530, 730, 302, 332, pRed)
        Font.print(aBoyI, 534, 300, "R2:" .. R2X .. "," .. R2Y, eBlue)
    end
end

-- Modify Config
function changeConfig(x, y, trigger)
    local cfg = System.openFile("ux0:data/TriggerRemap.txt", FRDWR)
    local cfgText = System.readFile(cfg, 33)
    local L2X, L2Y, R2X, R2Y = cfgText:match("(%d+),Y:(%d+);R2=X:(%d+),Y:(%d+)")
    if (trigger == "R2")
    then
        cfgChange = ("L2=X:" .. L2X .. ",Y:" .. L2Y .. ";R2=X:" .. x*2 .. ",Y:" .. y*2) 
    elseif (trigger == "L2")
    then
        cfgChange = ("L2=X:" .. x*2 .. ",Y:" .. y*2 .. ";R2=X:" .. R2X .. ",Y:" .. R2Y)
    else
        goto continue
    end
    System.seekFile(cfg, 0, SET)
    System.writeFile(cfg, cfgChange, 33)
    System.closeFile(cfg)
    ::continue::
end

-- Touch Detect
local didTouchFront = {}
didTouchFront.cache = {}
local metatable = {__call = function(table, key, xVal1, yVal1, xVal2, yVal2)
    local x1, y1 = Controls.readTouch()
    --if table.cache[key] ~= nil then table.cache[key] = 0 end
    if(x1 == nil)
    then
        x1 = 0
        y1 = 0
    end

    if (x1 >= xVal1 and y1 >= yVal1 and x1 <= xVal2 and y1 <= yVal2)
    then
        table.cache[key] = 1
    end
    if (table.cache[key] ~= nil)
    then
        if (not(x1Prev >= xVal1 and y1Prev >= yVal1 and x1Prev <= xVal2 and y1Prev <= yVal2) == true)
        then
            if(x1Prev == 0 and x1 == 0 and table.cache[key] ~= 2)
            then
                table.cache[key] = 2
            else
                table.cache[key] = nil
            end
        end
    end
    x1Prev = x1 or 0
    y1Prev = y1 or 0
    return table.cache[key]
end }

-- Trigger Remap Dialog
function triggerRemapDialog(trigger)
    local done = false
    repeat
        local pad = Controls.read()
        Graphics.initBlend()
        Screen.clear()

        Font.setPixelSizes(aBoy, 30)
        Font.print(aBoy, (960/2) - 188, (544/2) - 121, "    Press the Location on the rear \n\n      touchpad where you would\n\nlike to remap the selected trigger to", eBlue)
        Font.print(aBoy, 745, 504, "Press O to Cancel", red)

        ::redo::
        local xr1, yr1 = Controls.readRetroTouch()
        if (xr1 ~= nil)
        then
            local xr1Pressed = xr1
            local yr1Pressed = yr1
            for i = 500, 1, -1
            do
                local xr1, yr1 = Controls.readRetroTouch()
                if (xr1 ~= nil)
                then
                    if ((xr1 <= xr1Pressed + 10 and xr1 >= xr1Pressed - 10) and (yr1 >= yr1Pressed - 10 and yr1 <= yr1Pressed + 10))
                    then
                        Graphics.initBlend()
                        Screen.clear()
                        Font.print(aBoy, 10, 470, "X:" .. xr1 .. "  Y:" .. yr1, ePurp)
                        Graphics.fillCircle(xr1, yr1, 30, eBlue)
                        Font.print(aBoy, 10, 500, "Keep Holding for (" .. math.floor(i/100+0.5) .. ")", pRed)
                        System.wait(10000)
                        Graphics.termBlend()
                        Screen.flip()
                        if (i <= 1) 
                        then
                            changeConfig(xr1, yr1, trigger) 
                            done = true
                            break
                        end
                    elseif (xr1 ~= 0)
                    then
                        goto redo
                    else
                        break
                    end
                end
            end

        end
        if Controls.check(pad, SCE_CTRL_CIRCLE)
        then
            done = true
            break
        end
        Graphics.termBlend()
        Screen.flip()
    until (done == true)
end

-- Config Reset Dialog
function resetDialog(cor)
    local i = false
    repeat
        Graphics.initBlend()
        Screen.clear()

        drawScreen()

        Font.setPixelSizes(aBoyI, 27)
        Graphics.fillRect(12, 128, 502, 532, eYellow)
        Graphics.fillRect(10, 222, 340, 492, pRed)
        local pad = Controls.read()

        if(cor == "reset")
        then
            Font.print(aBoy, 33, 496, "Reset", red)
            Font.print(aBoyI, 18, 330, "\nPress X to Confirm\nConfig File Reset\n\nPress O to Cancel", eBlue)

            if Controls.check(pad, SCE_CTRL_CROSS)
            then
                local cfg = System.openFile("ux0:data/TriggerRemap.txt", FWRITE)
                local cfgText = "L2=X:500,Y:350;R2=X:1300,Y:350"
                System.seekFile(cfg, 0, SET)
                System.writeFile(cfg, cfgText, 33)
                System.closeFile(cfg)

                i = true
            end
        elseif(cor == "create")
        then
            Font.print(aBoy, 31, 496, "Create", ePurp)
            Font.print(aBoyI, 18, 330, "\nPress X to Confirm\nConfig File Creation\n\nPress O to Cancel", eBlue)

            if Controls.check(pad, SCE_CTRL_CROSS)
            then
                local cfg = System.openFile("ux0:data/TriggerRemap.txt", FCREATE)
                local cfgText = "L2=X:500,Y:350;R2=X:1300,Y:350"
                System.seekFile(cfg, 0, SET)
                System.writeFile(cfg, cfgText, 33)
                System.closeFile(cfg)
                XValConfigLocText = 422
                i = true
            end
        end
        if Controls.check(pad, SCE_CTRL_CIRCLE)
        then
            --Don't Reset
            i = true
        end
        Graphics.termBlend()
        Screen.flip()
    until (i == true)
end

while true do

    Graphics.initBlend()
    Screen.clear()

    drawScreen()

    setmetatable(didTouchFront, metatable)

    local L2ButtonTouched = didTouchFront("L2ButtResult", 230, 340, 430, 430)
    if (L2ButtonTouched == 1)
    then
        Graphics.fillRect(240, 420, 350, 420, ePurp)
        Font.setPixelSizes(aBoy, 25)
        Font.print(aBoy, 288, 343, "REMAP", eYellow)
        Font.print(aBoyV, 280, 348, "L2", eYellow)
    elseif (L2ButtonTouched == 2)
    then
        triggerRemapDialog("L2")
    end
    
    local R2ButtonTouched = didTouchFront("R2ButtResult", 530, 340, 730, 430)
    if (R2ButtonTouched == 1)
    then
        Graphics.fillRect(540, 720, 350, 420, ePurp)
        Font.setPixelSizes(aBoy, 25)
        Font.print(aBoy, 588, 343, "REMAP", eYellow)
        Font.print(aBoyV, 580, 348, "R2", eYellow)
    elseif (R2ButtonTouched == 2)
    then
        triggerRemapDialog("R2")
    end
    
    local ResetButtonTouched = didTouchFront("RstButtResult", 10, 500, 130, 534)
    if (ResetButtonTouched == 1)
    then
        if System.doesFileExist("ux0:data/TriggerRemap.txt")
        then
            resetDialog("reset")
        else
            resetDialog("create")
        end
    end

    Graphics.termBlend()
    Screen.flip()
   
end

Font.unload(aBoy)
Font.unload(aBoyI)
Font.unload(aBoyV)
Font.unload(aBoyW)