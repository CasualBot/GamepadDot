-- GamepadDot: enable/disable the gamepad center dot (Blizzard's GamepadReticle) and optionally draw a custom one.
local db, ui
local function say(...) print("|cff66ccffGamepadDot|r", ...) end

local custom = CreateFrame("Frame", nil, UIParent)
custom:SetPoint("CENTER")
custom:SetFrameStrata("TOOLTIP")
local tex = custom:CreateTexture(nil, "OVERLAY")
tex:SetAllPoints()
tex:SetTexture("Interface\Buttons\WHITE8X8")

local hooked
local function reticle() return _G.GamepadReticle end

local function apply()
  local r = reticle()
  if r then
    if not hooked then
      hooked = true
      -- Blizzard re-shows/re-fades the dot as input changes; keep it hidden while disabled.
      local function enforce() if db and db.hide and r:GetAlpha() ~= 0 then r:SetAlpha(0) end end
      hooksecurefunc(r, "Show", enforce)
      hooksecurefunc(r, "SetAlpha", enforce)
    end
    r:SetAlpha(db.hide and 0 or 1)
  end
  custom:SetSize(db.size, db.size)
  tex:SetVertexColor(unpack(db.color))
  custom:SetShown(db.custom)
end

local function buildUI()
  ui = CreateFrame("Frame", "GamepadDotUI", UIParent, "BasicFrameTemplateWithInset")
  ui:SetSize(280, 190); ui:SetPoint("CENTER"); ui:SetMovable(true); ui:EnableMouse(true)
  ui:RegisterForDrag("LeftButton"); ui:SetScript("OnDragStart", ui.StartMoving); ui:SetScript("OnDragStop", ui.StopMovingOrSizing)
  ui:SetFrameStrata("DIALOG"); ui:Hide()
  tinsert(UISpecialFrames, "GamepadDotUI")
  local title = ui:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", 0, -6); title:SetText("GamepadDot")

  local function check(label, y, key)
    local cb = CreateFrame("CheckButton", nil, ui, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 16, y); cb.text:SetText(label)
    cb:SetScript("OnClick", function(self) db[key] = self:GetChecked() and true or false; apply() end)
    return cb
  end
  local cbHide = check("Hide gamepad dot", -30, "hide")
  local cbCustom = check("Show custom dot", -56, "custom")

  local size = CreateFrame("Slider", "GamepadDotSize", ui, "OptionsSliderTemplate")
  size:SetPoint("TOP", 0, -105); size:SetWidth(220); size:SetMinMaxValues(2, 30); size:SetValueStep(1)
  if size.SetObeyStepOnDrag then size:SetObeyStepOnDrag(true) end
  GamepadDotSizeLow:SetText("2"); GamepadDotSizeHigh:SetText("30")
  size:SetScript("OnValueChanged", function(_, v) v = floor(v + 0.5); GamepadDotSizeText:SetText("Size: " .. v); if db then db.size = v; apply() end end)

  local swatch = CreateFrame("Button", nil, ui)
  swatch:SetSize(24, 24); swatch:SetPoint("TOPLEFT", 20, -135)
  local sw = swatch:CreateTexture(nil, "ARTWORK"); sw:SetAllPoints(); sw:SetTexture("Interface\Buttons\WHITE8X8")
  local swl = ui:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); swl:SetPoint("LEFT", swatch, "RIGHT", 8, 0); swl:SetText("Custom dot color")
  local function setColor(r, g, b) db.color = { r, g, b }; sw:SetVertexColor(r, g, b); apply() end
  swatch:SetScript("OnClick", function()
    local r, g, b = unpack(db.color)
    local function pick() setColor(ColorPickerFrame:GetColorRGB()) end
    if ColorPickerFrame.SetupColorPickerAndShow then
      ColorPickerFrame:SetupColorPickerAndShow({ r = r, g = g, b = b, swatchFunc = pick, cancelFunc = function() setColor(r, g, b) end })
    else
      ColorPickerFrame:SetColorRGB(r, g, b); ColorPickerFrame.func = pick
      ColorPickerFrame.cancelFunc = function() setColor(r, g, b) end; ColorPickerFrame:Hide(); ColorPickerFrame:Show()
    end
  end)

  ui:SetScript("OnShow", function()
    cbHide:SetChecked(db.hide); cbCustom:SetChecked(db.custom)
    size:SetValue(db.size); sw:SetVertexColor(unpack(db.color))
  end)
end

SLASH_GAMEPADDOT1, SLASH_GAMEPADDOT2 = "/gdot", "/gamepaddot"
SlashCmdList.GAMEPADDOT = function(msg)
  if not db then return say("not initialised yet") end
  local cmd, a, b, c = strsplit(" ", msg)
  if cmd == "" then
    if not ui then buildUI() end; ui:SetShown(not ui:IsShown()); return
  elseif cmd == "on" or cmd == "show" then db.hide = false; say("dot enabled")
  elseif cmd == "off" or cmd == "hide" then db.hide = true; say("dot disabled")
  elseif cmd == "custom" then db.custom = not db.custom
  elseif cmd == "size" and tonumber(a) then db.size = tonumber(a)
  elseif cmd == "color" and tonumber(c) then db.color = { tonumber(a), tonumber(b), tonumber(c) }
  else
    return say("/gdot (window) | show|on | hide|off | custom | size N | color r g b (0-1)")
  end
  apply()
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("ADDON_LOADED") -- GamepadReticle may be created by a load-on-demand Blizzard addon
ev:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    GamepadDotDB = GamepadDotDB or {}
    db = GamepadDotDB
    if db.hide == nil then db.hide = true end
    db.size = db.size or 6
    db.color = db.color or { 1, 1, 1 }
    db.frames = nil
    say("loaded. /gdot for help")
    -- reticle may appear a moment after login
    C_Timer.NewTicker(1, function(t) if reticle() then t:Cancel() end; apply() end, 15)
  end
  if db then apply() end
end)
