local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==============================================
-- DEFAULTS (o Config sobrescreve)
--==============================================
local DEFAULT_CONFIG = {
    Title = "UI Library",
    ScriptName = "CustomUILibrary",
    IconImage = "https://plain-enam-prod-public.komododecks.com/202609/25/Ll3LoZyPiyuIrr6s4hw5/image.png",
    Width = 520,
    Height = 300,

    Theme = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary  = Color3.fromRGB(35, 35, 42),
        Tertiary   = Color3.fromRGB(45, 45, 55),
        Accent     = Color3.fromRGB(220, 50, 50),
        Text       = Color3.fromRGB(240, 240, 245),
        SubText    = Color3.fromRGB(160, 160, 170),
        Stroke     = Color3.fromRGB(60, 60, 70),
    },

    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

local function carregarIcone(url)
    local ok, resultado = pcall(function()
        local dados = game:HttpGet(url)
        writefile("ui_icon.png", dados)
        return getcustomasset("ui_icon.png")
    end)
    if ok then
        return resultado
    else
        return nil
    end
end

DEFAULT_CONFIG.IconImage = carregarIcone(DEFAULT_CONFIG.IconImage)

--==============================================
-- UTILITÁRIOS
--==============================================
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function stroke(parent, color, thickness)
    return new("UIStroke", { Color = color, Thickness = thickness or 1, Parent = parent })
end

local function padding(parent, all)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, all), PaddingBottom = UDim.new(0, all),
        PaddingLeft = UDim.new(0, all), PaddingRight = UDim.new(0, all),
        Parent = parent,
    })
end

local function tween(obj, time, props)
    TweenService:Create(obj,
        TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props):Play()
end

local function merge(base, override)
    local out = {}
    for k, v in pairs(base) do
        if type(v) == "table" then
            local t = {}
            for k2, v2 in pairs(v) do t[k2] = v2 end
            out[k] = t
        else
            out[k] = v
        end
    end
    for k, v in pairs(override or {}) do
        if type(v) == "table" and type(out[k]) == "table" then
            for k2, v2 in pairs(v) do out[k][k2] = v2 end
        else
            out[k] = v
        end
    end
    return out
end

--==============================================
-- AUTO-FLAG (gera nome único a partir do texto)
--==============================================
local function toFlag(text)
    if not text then return nil end
    return text:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
end

--==============================================
-- BUILDER
--==============================================
local function Build(userConfig)
    local CONFIG = merge(DEFAULT_CONFIG, userConfig or {})
    local THEME = CONFIG.Theme

    local Flags = {}

    local ScreenGui = new("ScreenGui", {
        Name = CONFIG.ScriptName,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = playerGui,
    })

    -- Botão flutuante
    local ToggleButton = new("ImageButton", {
        Parent = ScreenGui,
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        BackgroundColor3 = THEME.Accent,
        BorderSizePixel = 0,
        Image = CONFIG.IconImage,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
        ZIndex = 100,
    })
    corner(ToggleButton, 12); padding(ToggleButton, 8)
    stroke(ToggleButton, THEME.Accent, 1.5)

    -- Janela
    local Main = new("Frame", {
        Parent = ScreenGui,
        Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height),
        Position = UDim2.new(0.5, -CONFIG.Width/2, 0.5, -CONFIG.Height/2),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 5,
    })
    corner(Main, 10); stroke(Main, THEME.Stroke, 1)

    -- Topbar
    local Topbar = new("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = THEME.Secondary,
        BorderSizePixel = 0,
    })
    corner(Topbar, 10)

    new("TextLabel", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.fromOffset(16, 0),
        Font = CONFIG.FontBold,
        Text = CONFIG.Title,
        TextColor3 = THEME.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

local CloseBtn = new("TextButton", {
        Parent = Topbar,
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(1, -30, 0, 4),
        BackgroundColor3 = THEME.Tertiary,
        BorderSizePixel = 0,
        Font = CONFIG.FontBold,
        Text = "✕",
        TextColor3 = THEME.Text,
        TextSize = 13,
        AutoButtonColor = false,
    })
    corner(CloseBtn, 6)

    -- Sidebar
    local Sidebar = new("ScrollingFrame", {
        Parent = Main,
        Size = UDim2.new(0, 130, 1, -32),
        Position = UDim2.fromOffset(0, 32),
        BackgroundColor3 = THEME.Secondary,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = THEME.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    padding(Sidebar, 6)
    new("UIListLayout", { Parent = Sidebar, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

    local Container = new("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -130, 1, -32),
        Position = UDim2.fromOffset(130, 32),
        BackgroundTransparency = 1,
    })

    --==============================================
    -- Toggle
    --==============================================
    local Open = true
    local function toggleUI()
    Open = not Open
    local targetSize = Open and UDim2.fromOffset(CONFIG.Width, CONFIG.Height) or UDim2.fromOffset(0, 0)
    local targetPos = Open
        and UDim2.new(0.5, -CONFIG.Width/2, 0.5, -CONFIG.Height/2)
        or UDim2.new(0.5, 0, 0.5, 0)

    if Open then
        -- Abrindo: mostra antes de animar
        Main.Visible = true
        tween(Main, 0.25, { Size = targetSize, Position = targetPos })
    else
        -- Fechando: anima e SÓ DEPOIS esconde
        tween(Main, 0.25, { Size = targetSize, Position = targetPos })
        task.delay(0.26, function()
            if not Open then
                Main.Visible = false
            end
        end)
    end

    tween(ToggleButton, 0.2, {
        BackgroundColor3 = Open and THEME.Accent or THEME.Secondary
    })
end
    CloseBtn.MouseButton1Click:Connect(toggleUI)

    -- Drag botão flutuante
    do
        local dragging, dragStart, startPos, moved
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging, moved = true, false
                dragStart = input.Position
                startPos = ToggleButton.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then moved = true end
                ToggleButton.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if dragging and not moved then toggleUI() end
                dragging = false
            end
        end)
    end

    -- Drag janela
    do
        local dragging, dragStart, startPos
        Topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    --==============================================
    -- AUTO SAVE / LOAD
    --==============================================
    local function saveFile(filename)
        if type(writefile) ~= "function" then
            warn("[UI] writefile indisponível (não é executor?)")
            return false
        end
        local data = {}
        for flag, entry in pairs(Flags) do
            data[flag] = entry.state
        end
        local ok, encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(data)
        end)
        if not ok then return false end
        return pcall(writefile, filename, encoded)
    end

    local function loadFile(filename)
        if type(isfile) ~= "function" or type(readfile) ~= "function" then
            warn("[UI] isfile/readfile indisponíveis (não é executor?)")
            return false
        end
        if not isfile(filename) then return false end
        local ok, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(filename))
        end)
        if not ok or type(decoded) ~= "table" then return false end
        for flag, value in pairs(decoded) do
            local entry = Flags[flag]
            if entry and entry.setter then
                pcall(entry.setter, value)
            end
        end
        return true
    end

    --==============================================
    -- Abas
    --==============================================
    local Tabs = {}

    local function CreateTab(name)
        local button = new("TextButton", {
            Parent = Sidebar,
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = THEME.Tertiary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Font = CONFIG.Font,
            Text = "  " .. name,
            TextColor3 = THEME.SubText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
        })
        corner(button, 6)

        local page = new("ScrollingFrame", {
            Parent = Container,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = THEME.Accent,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        })
        padding(page, 10)
        new("UIListLayout", { Parent = page, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

        button.MouseButton1Click:Connect(function()
            for _, t in ipairs(Tabs) do
                t.page.Visible = false
                tween(t.button, 0.15, { BackgroundTransparency = 1, TextColor3 = THEME.SubText })
            end
            page.Visible = true
            tween(button, 0.15, { BackgroundTransparency = 0, TextColor3 = THEME.Text })
        end)

        if #Tabs == 0 then
            page.Visible = true
            button.BackgroundTransparency = 0
            button.TextColor3 = THEME.Text
        end

        table.insert(Tabs, { button = button, page = page })

        local API = {}

        function API.AddSection(title)
            local section = new("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1 })
            new("TextLabel", {
                Parent = section, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
                Font = CONFIG.FontBold, Text = string.upper(title),
                TextColor3 = THEME.Accent, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
        end

        function API.AddChannel(title)
            local frame = new("Frame", {
                Parent = page, Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = THEME.Secondary, BorderSizePixel = 0,
            })
            corner(frame, 6)
            new("Frame", {
                Parent = frame, Size = UDim2.new(0, 3, 1, -10),
                Position = UDim2.new(0, 6, 0, 5),
                BackgroundColor3 = THEME.Accent, BorderSizePixel = 0,
            })
            new("TextLabel", {
                Parent = frame, BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(16, 0),
                Font = CONFIG.FontBold, Text = title, TextColor3 = THEME.Text,
                TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            })
        end

        function API.AddParagraph(title, desc)
            local frame = new("Frame", {
                Parent = page, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = THEME.Secondary, BorderSizePixel = 0,
            })
            corner(frame, 6); padding(frame, 10)
            new("UIListLayout", { Parent = frame, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
            if title and title ~= "" then
                new("TextLabel", {
                    Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
                    Font = CONFIG.FontBold, Text = title, TextColor3 = THEME.Text,
                    TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
                })
            end
            new("TextLabel", {
                Parent = frame, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Font = CONFIG.Font, Text = desc or "", TextColor3 = THEME.SubText,
                TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            })
        end

        function API.AddButton(text, callback)
            local btn = new("TextButton", {
                Parent = page, Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = THEME.Accent, BorderSizePixel = 0,
                Font = CONFIG.FontBold, Text = text,
                TextColor3 = Color3.new(1, 1, 1), TextSize = 13,
                AutoButtonColor = false,
            })
            corner(btn, 6)
            btn.MouseEnter:Connect(function()
                tween(btn, 0.15, { BackgroundColor3 = THEME.Accent:Lerp(Color3.new(1,1,1), 0.15) })
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, 0.15, { BackgroundColor3 = THEME.Accent })
            end)
            btn.MouseButton1Click:Connect(function()
                if callback then task.spawn(callback) end
            end)
            return btn
        end
        function API.AddToggle(text, default, callback)
            local state = default or false
            local frame = new("Frame", {
                Parent = page, Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = THEME.Secondary, BorderSizePixel = 0,
            })
            corner(frame, 6); padding(frame, 8)
            new("TextLabel", {
                Parent = frame, BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 1, 0), Font = CONFIG.Font,
                Text = text, TextColor3 = THEME.Text, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            local switch = new("TextButton", {
                Parent = frame, Size = UDim2.fromOffset(40, 20),
                Position = UDim2.new(1, -40, 0.5, -10),
                BackgroundColor3 = state and THEME.Accent or THEME.Tertiary,
                BorderSizePixel = 0, Text = "", AutoButtonColor = false,
            })
            corner(switch, 10)
            local knob = new("Frame", {
                Parent = switch, Size = UDim2.fromOffset(14, 14),
                Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3),
                BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            })
            corner(knob, 7)

            local flag = toFlag(text)
            local function applyState(v, fireCallback)
                state = v
                if flag and Flags[flag] then Flags[flag].state = state end
                tween(switch, 0.15, {
                    BackgroundColor3 = state and THEME.Accent or THEME.Tertiary
                })
                tween(knob, 0.15, {
                    Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3)
                })
                if fireCallback and callback then callback(state) end
            end

            switch.MouseButton1Click:Connect(function()
                applyState(not state, true)
                if Build._autoSave then Build._autoSave() end
            end)

            if flag then
                Flags[flag] = {
                    state = state,
                    setter = function(v) applyState(v, true) end,
                }
            end
        end


        function API.AddInput(text, placeholder, callback)
            local frame = new("Frame", {
                Parent = page, Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = THEME.Secondary, BorderSizePixel = 0,
            })
            corner(frame, 6); padding(frame, 8)
            new("UIListLayout", { Parent = frame, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
            new("TextLabel", {
                Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
                Font = CONFIG.FontBold, Text = text, TextColor3 = THEME.Text,
                TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            })
            local box = new("TextBox", {
                Parent = frame, Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = THEME.Tertiary, BorderSizePixel = 0,
                Font = CONFIG.Font, PlaceholderText = placeholder or "Digite...",
                PlaceholderColor3 = THEME.SubText, Text = "",
                TextColor3 = THEME.Text, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
            })
            corner(box, 6); padding(box, 6)
            box.FocusLost:Connect(function()
                if callback then callback(box.Text) end
            end)
            return box
        end
        function API.AddSlider(text, min, max, default, callback)
            min, max = min or 0, max or 100
            local value = default or min
            local frame = new("Frame", {
                Parent = page, Size = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = THEME.Secondary, BorderSizePixel = 0,
            })
            corner(frame, 6); padding(frame, 8)
            new("UIListLayout", { Parent = frame, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
            local header = new("Frame", { Parent = frame, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1 })
            new("TextLabel", {
                Parent = header, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0),
                Font = CONFIG.FontBold, Text = text, TextColor3 = THEME.Text,
                TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            })
            local valueLbl = new("TextLabel", {
                Parent = header, BackgroundTransparency = 1, Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0.6, 0, 0, 0), Font = CONFIG.Font,
                Text = tostring(value), TextColor3 = THEME.Accent,
                TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
            })
            local bar = new("Frame", {
                Parent = frame, Size = UDim2.new(1, 0, 0, 8),
                BackgroundColor3 = THEME.Tertiary, BorderSizePixel = 0,
            })
            corner(bar, 4)
            local fill = new("Frame", {
                Parent = bar, Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = THEME.Accent, BorderSizePixel = 0,
            })
            corner(fill, 4)

            local flag = toFlag(text)
            local function applyValue(v, fireCallback)
                value = math.clamp(math.floor(v + 0.5), min, max)
                if flag and Flags[flag] then Flags[flag].state = value end
                local rel = (value - min) / (max - min)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                valueLbl.Text = tostring(value)
                if fireCallback and callback then callback(value) end
            end

            local dragging = false
            local function update(x)
                local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                applyValue(min + (max - min) * rel, true)
            end
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; update(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    if Build._autoSave then Build._autoSave() end
                end
            end)

            if flag then
                Flags[flag] = {
                    state = value,
                    setter = function(v) applyValue(v, true) end,
                }
            end
        end
        function API.AddDropdown(text, options, default, callback)
            options = options or {}
            local selected = default or options[1]
            local open = false
            local frame = new("Frame", {
                Parent = page, Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = THEME.Secondary, BorderSizePixel = 0,
                ClipsDescendants = false, ZIndex = 2,
            })
            corner(frame, 6); padding(frame, 8)
            new("UIListLayout", { Parent = frame, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
            new("TextLabel", {
                Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
                Font = CONFIG.FontBold, Text = text, TextColor3 = THEME.Text,
                TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
            })
            local selector = new("TextButton", {
                Parent = frame, Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = THEME.Tertiary, BorderSizePixel = 0,
                Font = CONFIG.Font, Text = "  " .. tostring(selected),
                TextColor3 = THEME.Text, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false, ZIndex = 2,
            })
            corner(selector, 6)
            new("TextLabel", {
                Parent = selector, BackgroundTransparency = 1,
                Size = UDim2.fromOffset(20, 26), Position = UDim2.new(1, -24, 0, 0),
                Font = CONFIG.FontBold, Text = "▼",
                TextColor3 = THEME.Accent, TextSize = 10,
            })
            local list = new("Frame", {
                Parent = frame, Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = THEME.Background, BorderSizePixel = 0,
                Visible = false, ZIndex = 10, ClipsDescendants = true,
            })
            corner(list, 6); stroke(list, THEME.Stroke); padding(list, 4)
            new("UIListLayout", { Parent = list, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })

            local flag = toFlag(text)
            local function applySelection(opt, fireCallback)
                selected = opt
                if flag and Flags[flag] then Flags[flag].state = selected end
                selector.Text = "  " .. tostring(selected)
                if fireCallback and callback then callback(selected) end
            end

            for _, opt in ipairs(options) do
                local item = new("TextButton", {
                    Parent = list, Size = UDim2.new(1, 0, 0, 24),
                    BackgroundColor3 = THEME.Secondary,
                    BackgroundTransparency = opt == selected and 0 or 1,
                    BorderSizePixel = 0, Font = CONFIG.Font,
                    Text = "  " .. tostring(opt), TextColor3 = THEME.Text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false, ZIndex = 11,
                })
                corner(item, 4)
                item.MouseEnter:Connect(function()
                    tween(item, 0.1, { BackgroundTransparency = 0 })
                end)
                item.MouseLeave:Connect(function()
                    if opt ~= selected then
                        tween(item, 0.1, { BackgroundTransparency = 1 })
                    end
                end)
                item.MouseButton1Click:Connect(function()
                    applySelection(opt, true)
                    open = false
                    tween(list, 0.15, { Size = UDim2.new(1, 0, 0, 0) })
                    task.delay(0.15, function() list.Visible = false end)
                    frame.Size = UDim2.new(1, 0, 0, 52)
                    if Build._autoSave then Build._autoSave() end
                end)
            end

            selector.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    list.Visible = true
                    local target = math.min(#options * 26 + 8, 150)
                    tween(list, 0.2, { Size = UDim2.new(1, 0, 0, target) })
                    frame.Size = UDim2.new(1, 0, 0, 52 + target)
                else
                    tween(list, 0.15, { Size = UDim2.new(1, 0, 0, 0) })
                    task.delay(0.15, function() list.Visible = false end)
                    frame.Size = UDim2.new(1, 0, 0, 52)
                end
            end)

            if flag then
                Flags[flag] = {
                    state = selected,
                    setter = function(v) applySelection(v, true) end,
                }
            end
        end


        return API
    end

    local Instance_ = {
        CreateTab = CreateTab,
        Toggle = toggleUI,
        ScreenGui = ScreenGui,
        Main = Main,
        ToggleButton = ToggleButton,
        Flags = Flags,
        SaveConfig = saveFile,
        LoadConfig = loadFile,
    }

    -- Hook interno de auto-save (usado pelos componentes)
    Build._autoSave = function()
        if Instance_.AutoSave then
            saveFile(Instance_.AutoSaveFile or "uiconfig.json")
        end
    end

    return Instance_
end

return Build