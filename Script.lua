local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local mouse = lp:GetMouse()

local S = { fly = false, inf = false, noclip = false, speed = false, jump = false }
local flySpeed, walkSpeed, jumpPower = 60, 50, 100
local target, spectating = nil, false
local bv, bg

local function getChar() return lp.Character end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local gui = Instance.new("ScreenGui")
gui.Name = "ControlPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp:WaitForChild("PlayerGui")

local BG, ACC, OFFC, ONC = Color3.fromRGB(22, 24, 38), Color3.fromRGB(110, 90, 255), Color3.fromRGB(45, 48, 70), Color3.fromRGB(40, 190, 120)

local accents, bgs = {}, {}
local function reg(o, prop) table.insert(accents, {o, prop}) end
local function regBG(o, prop) table.insert(bgs, {o, prop}) end
local function applyAccent(c) ACC = c for _, v in ipairs(accents) do v[1][v[2]] = c end end
local function applyBG(c) BG = c for _, v in ipairs(bgs) do v[1][v[2]] = c end end

local function corner(o, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 10) c.Parent = o end

local function makeDraggable(handle, frame)
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, startPos, startInput = true, frame.Position, i.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - startInput
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local function makeWindow(title, size, pos, parent, dragTarget)
    local f = Instance.new("Frame")
    f.Size, f.Position, f.BackgroundColor3 = size, pos, BG
    f.BorderSizePixel = 0
    f.Parent = parent or gui
    corner(f, 14)
    regBG(f, "BackgroundColor3")
    local st = Instance.new("UIStroke") st.Color = ACC st.Thickness = 2 st.Parent = f
    reg(st, "Color")
    local bar = Instance.new("TextLabel")
    bar.Size = UDim2.new(1, 0, 0, 36)
    bar.BackgroundColor3 = ACC
    bar.Text = title
    bar.Font = Enum.Font.GothamBold
    bar.TextSize = 18
    bar.TextColor3 = Color3.new(1, 1, 1)
    bar.Parent = f
    corner(bar, 14)
    reg(bar, "BackgroundColor3")
    makeDraggable(bar, dragTarget or f)
    return f
end

local function makeButton(parent, text, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = OFFC
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = Color3.new(1, 1, 1)
    b.AutoButtonColor = true
    b.LayoutOrder = order or 0
    b.Parent = parent
    corner(b, 8)
    return b
end

local function setOn(btn, on) btn.BackgroundColor3 = on and ONC or OFFC end

-- الحاوية الرئيسية (تتحرك معها اللوحة وزر الإخفاء)
local holder = Instance.new("Frame")
holder.Size = UDim2.new(0, 250, 0.74, 0)
holder.Position = UDim2.new(0, 10, 0.16, 0)
holder.BackgroundTransparency = 1
holder.Parent = gui
local hc = Instance.new("UISizeConstraint")
hc.MaxSize = Vector2.new(250, 400)
hc.Parent = holder

local main = makeWindow("⚡ لوحة التحكم", UDim2.fromScale(1, 1), UDim2.new(), holder, holder)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -46)
scroll.Position = UDim2.new(0, 8, 0, 42)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = main
local lay = Instance.new("UIListLayout") lay.Padding = UDim.new(0, 6) lay.SortOrder = Enum.SortOrder.LayoutOrder lay.Parent = scroll

local btnFly = makeButton(scroll, "✈️ طيران", 1)
local btnInf = makeButton(scroll, "🦘 قفز لا نهائي", 2)
local btnNoclip = makeButton(scroll, "🧱 اختراق جدران", 3)

local function makeRow(labelText, default, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = scroll
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.32, 0, 1, 0)
    box.BackgroundColor3 = Color3.fromRGB(60, 64, 95)
    box.Text = tostring(default)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 16
    box.TextColor3 = Color3.new(1, 1, 1)
    box.ClearTextOnFocus = false
    box.Parent = row
    corner(box, 8)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.66, 0, 1, 0)
    b.Position = UDim2.new(0.34, 0, 0, 0)
    b.BackgroundColor3 = OFFC
    b.Text = labelText
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Parent = row
    corner(b, 8)
    return box, b
end

local boxFly, _ = makeRow("(سرعة الطيران)", flySpeed, 4)
local boxSpeed, btnSpeed = makeRow("🏃 سرعة", walkSpeed, 5)
local boxJump, btnJump = makeRow("⬆️ قفز", jumpPower, 6)
local btnTargetMenu = makeButton(scroll, "🎯 استهداف", 7)

local function swatchRow(title, colors, order, onPick)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.LayoutOrder = order
    lbl.Parent = scroll
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order + 0.5
    row.Parent = scroll
    local g = Instance.new("UIListLayout")
    g.FillDirection = Enum.FillDirection.Horizontal
    g.Padding = UDim.new(0, 6)
    g.Parent = row
    for _, c in ipairs(colors) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(32, 32)
        b.BackgroundColor3 = c
        b.Text = ""
        b.Parent = row
        corner(b, 16)
        local st = Instance.new("UIStroke") st.Color = Color3.new(1, 1, 1) st.Thickness = 1.5 st.Transparency = 0.5 st.Parent = b
        b.MouseButton1Click:Connect(function() onPick(c) end)
    end
end

swatchRow("🎨 لون الواجهة", {
    Color3.fromRGB(110, 90, 255), Color3.fromRGB(50, 130, 255), Color3.fromRGB(230, 60, 70),
    Color3.fromRGB(40, 190, 120), Color3.fromRGB(255, 150, 40), Color3.fromRGB(255, 90, 170),
}, 8, applyAccent)

swatchRow("🌑 لون الخلفية", {
    Color3.fromRGB(22, 24, 38), Color3.fromRGB(12, 12, 16), Color3.fromRGB(42, 42, 48),
    Color3.fromRGB(20, 36, 50), Color3.fromRGB(38, 20, 28), Color3.fromRGB(20, 38, 30),
}, 10, applyBG)

-- نافذة الاستهداف
local tw = makeWindow("🎯 استهداف", UDim2.new(0, 250, 0.9, 0), UDim2.new(0.5, 0, 0.5, 0))
tw.AnchorPoint = Vector2.new(0.5, 0.5)
tw.Visible = false
local twc = Instance.new("UISizeConstraint")
twc.MaxSize = Vector2.new(250, 480)
twc.MinSize = Vector2.new(250, 340)
twc.Parent = tw

local circle = Instance.new("ImageLabel")
circle.Size = UDim2.fromOffset(90, 90)
circle.Position = UDim2.new(0.5, -45, 0, 44)
circle.BackgroundColor3 = OFFC
circle.Image = ""
circle.Parent = tw
corner(circle, 45)
local cst = Instance.new("UIStroke") cst.Color = ACC cst.Thickness = 3 cst.Parent = circle
reg(cst, "Color")

local nameLbl = Instance.new("TextLabel")
nameLbl.Size = UDim2.new(1, -16, 0, 22)
nameLbl.Position = UDim2.new(0, 8, 0, 140)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = "لا يوجد مستهدف"
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 16
nameLbl.TextColor3 = Color3.new(1, 1, 1)
nameLbl.Parent = tw

local btnSpec = Instance.new("TextButton")
btnSpec.Size = UDim2.new(0.5, -12, 0, 34)
btnSpec.Position = UDim2.new(0, 8, 0, 168)
btnSpec.BackgroundColor3 = OFFC
btnSpec.Text = "👁 مراقبة المستهدف"
btnSpec.Font = Enum.Font.GothamBold
btnSpec.TextSize = 12
btnSpec.TextColor3 = Color3.new(1, 1, 1)
btnSpec.Parent = tw
corner(btnSpec, 8)

local btnTp = Instance.new("TextButton")
btnTp.Size = UDim2.new(0.5, -12, 0, 34)
btnTp.Position = UDim2.new(0.5, 4, 0, 168)
btnTp.BackgroundColor3 = OFFC
btnTp.Text = "📍 تنقل عند المستهدف"
btnTp.Font = Enum.Font.GothamBold
btnTp.TextSize = 12
btnTp.TextColor3 = Color3.new(1, 1, 1)
btnTp.Parent = tw
corner(btnTp, 8)

local btnBack = Instance.new("TextButton")
btnBack.Size = UDim2.new(1, -16, 0, 34)
btnBack.Position = UDim2.new(0, 8, 0, 206)
btnBack.BackgroundColor3 = OFFC
btnBack.Text = "🎒 ركوب الظهر"
btnBack.Font = Enum.Font.GothamBold
btnBack.TextSize = 14
btnBack.TextColor3 = Color3.new(1, 1, 1)
btnBack.Parent = tw
corner(btnBack, 8)

local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -16, 0, 30)
search.Position = UDim2.new(0, 8, 0, 246)
search.BackgroundColor3 = Color3.fromRGB(60, 64, 95)
search.PlaceholderText = "ابحث عن لاعب..."
search.Text = ""
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.TextColor3 = Color3.new(1, 1, 1)
search.PlaceholderColor3 = Color3.fromRGB(170, 170, 190)
search.Parent = tw
corner(search, 8)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -16, 1, -290)
list.Position = UDim2.new(0, 8, 0, 282)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = tw
local ll = Instance.new("UIListLayout") ll.Padding = UDim.new(0, 4) ll.Parent = list

-- زر إخفاء/إظهار اللوحة (فوق الزاوية العليا اليمنى للواجهة)
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(44, 44)
toggle.Position = UDim2.new(1, -30, 0, -30)
toggle.BackgroundColor3 = ACC
toggle.Text = "☰"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 24
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.ZIndex = 10
toggle.Parent = holder
corner(toggle, 22)
reg(toggle, "BackgroundColor3")

local panelVisible, targetWasOpen = true, false
toggle.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    if panelVisible then
        main.Visible = true
        tw.Visible = targetWasOpen
    else
        targetWasOpen = tw.Visible
        main.Visible = false
        tw.Visible = false
    end
    toggle.Text = panelVisible and "☰" or "👁"
end)

-- ركوب الظهر
local riding = false
local function stopRide()
    if not riding then return end
    riding = false
    setOn(btnBack, false)
    local h = getHum()
    if h and not S.fly then h.PlatformStand = false end
end

btnBack.MouseButton1Click:Connect(function()
    if riding then
        stopRide()
        return
    end
    local tc = target and target.Character
    local tr = tc and tc:FindFirstChild("HumanoidRootPart")
    local h = getHum()
    if tr and h and getRoot() then
        riding = true
        setOn(btnBack, true)
        h.PlatformStand = true
    end
end)

-- منطق الاستهداف
local function setTarget(plr)
    target = plr
    if not plr then
        nameLbl.Text = "لا يوجد مستهدف"
        circle.Image = ""
        return
    end
    nameLbl.Text = plr.DisplayName
    circle.Image = ""
    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and target == plr then circle.Image = img end
    end)
end

local function refreshList()
    for _, c in ipairs(list:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local q = string.lower(search.Text)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and (q == "" or string.find(string.lower(p.Name), q, 1, true) or string.find(string.lower(p.DisplayName), q, 1, true)) then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 30)
            b.BackgroundColor3 = OFFC
            b.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.TextColor3 = Color3.new(1, 1, 1)
            b.TextTruncate = Enum.TextTruncate.AtEnd
            b.Parent = list
            corner(b, 6)
            b.MouseButton1Click:Connect(function() setTarget(p) end)
        end
    end
end
search:GetPropertyChangedSignal("Text"):Connect(refreshList)
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(function(p)
    if p == target then
        if spectating then
            spectating = false
            local h = getHum()
            if h then cam.CameraSubject = h end
            setOn(btnSpec, false)
        end
        stopRide()
        setTarget(nil)
    end
    task.defer(refreshList)
end)
refreshList()

btnSpec.MouseButton1Click:Connect(function()
    if spectating then
        spectating = false
        local h = getHum()
        if h then cam.CameraSubject = h end
    else
        local c = target and target.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            spectating = true
            cam.CameraSubject = h
        end
    end
    setOn(btnSpec, spectating)
end)

btnTp.MouseButton1Click:Connect(function()
    local c = target and target.Character
    local tr = c and c:FindFirstChild("HumanoidRootPart")
    local r = getRoot()
    if tr and r then r.CFrame = tr.CFrame * CFrame.new(0, 0, 3) end
end)

btnTargetMenu.MouseButton1Click:Connect(function()
    tw.Visible = not tw.Visible
    setOn(btnTargetMenu, tw.Visible)
end)

-- أداة الاستهداف
local TOOL_NAME = "أداة الاستهداف"
local function playerFromPart(part)
    local m = part and part:FindFirstAncestorOfClass("Model")
    while m do
        local p = Players:GetPlayerFromCharacter(m)
        if p then return p end
        m = m.Parent and m.Parent:FindFirstAncestorOfClass("Model")
    end
end

local function giveTool()
    local bp = lp:WaitForChild("Backpack")
    local c = getChar()
    if bp:FindFirstChild(TOOL_NAME) or (c and c:FindFirstChild(TOOL_NAME)) then return end
    local tool = Instance.new("Tool")
    tool.Name = TOOL_NAME
    tool.ToolTip = "اضغط على لاعب لاستهدافه"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.Activated:Connect(function()
        local p = playerFromPart(mouse.Target)
        if p and p ~= lp then
            setTarget(p)
            if panelVisible then
                tw.Visible = true
                setOn(btnTargetMenu, true)
            end
        end
    end)
    tool.Parent = bp
end

-- الطيران
local function stopFly()
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local h = getHum()
    if h then h.PlatformStand = false end
end

local function startFly()
    local r, h = getRoot(), getHum()
    if not (r and h) then return end
    stopFly()
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.zero
    bv.Parent = r
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 1e4
    bg.CFrame = r.CFrame
    bg.Parent = r
    h.PlatformStand = true
end

btnFly.MouseButton1Click:Connect(function()
    S.fly = not S.fly
    setOn(btnFly, S.fly)
    if S.fly then startFly() else stopFly() end
end)

btnInf.MouseButton1Click:Connect(function() S.inf = not S.inf setOn(btnInf, S.inf) end)
btnNoclip.MouseButton1Click:Connect(function() S.noclip = not S.noclip setOn(btnNoclip, S.noclip) end)

btnSpeed.MouseButton1Click:Connect(function()
    S.speed = not S.speed
    setOn(btnSpeed, S.speed)
    if not S.speed then local h = getHum() if h then h.WalkSpeed = 16 end end
end)
btnJump.MouseButton1Click:Connect(function()
    S.jump = not S.jump
    setOn(btnJump, S.jump)
    if not S.jump then local h = getHum() if h then h.UseJumpPower = true h.JumpPower = 50 end end
end)

local function bindNumber(box, get, set)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then set(math.clamp(n, 1, 500)) end
        box.Text = tostring(get())
    end)
end
bindNumber(boxFly, function() return flySpeed end, function(v) flySpeed = v end)
bindNumber(boxSpeed, function() return walkSpeed end, function(v) walkSpeed = v end)
bindNumber(boxJump, function() return jumpPower end, function(v) jumpPower = v end)

-- الحلقات
UIS.JumpRequest:Connect(function()
    if riding then
        stopRide()
        return
    end
    if S.inf then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if S.noclip or riding then
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local h, r = getHum(), getRoot()
    if not (h and r) then return end

    if S.speed then h.WalkSpeed = walkSpeed end
    if S.jump then h.UseJumpPower = true h.JumpPower = jumpPower end

    if riding then
        local tc = target and target.Character
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if tr and th and th.Health > 0 then
            -- مثل الشنطة: خلف المستهدف وبنفس اتجاهه
            r.CFrame = tr.CFrame * CFrame.new(0, 0.3, 1.1)
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        else
            stopRide()
        end
        return
    end

    if S.fly and bv and bg then
        -- الطيران بعصا المشي: الأمام = اتجاه الكاميرا (مع الميل لفوق/تحت)
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        local flatRight = Vector3.new(right.X, 0, right.Z)
        local dir = h.MoveDirection
        local f, s = 0, 0
        if flatLook.Magnitude > 0.01 then f = dir:Dot(flatLook.Unit) end
        if flatRight.Magnitude > 0.01 then s = dir:Dot(flatRight.Unit) end
        bv.Velocity = (look * f + right * s) * flySpeed
        if flatLook.Magnitude > 0.01 then
            bg.CFrame = CFrame.lookAt(r.Position, r.Position + flatLook)
        end
    end
end)

lp.CharacterAdded:Connect(function()
    bv, bg = nil, nil
    spectating = false
    riding = false
    setOn(btnSpec, false)
    setOn(btnBack, false)
    task.wait(0.5)
    giveTool()
    if S.fly then startFly() end
end)

if lp.Character then task.spawn(giveTool) end
giveTool()
