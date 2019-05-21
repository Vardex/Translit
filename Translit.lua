local f = CreateFrame("Frame")

local options = {}

local config = CreateFrame("Frame")
config.name = "Translit"

local configOpenRunOnce = false

local LibTranslit = LibStub("LibTranslit-1.0")

local function Chat(self, event, msg, author, ...)
  msg = LibTranslit:Transliterate(msg, options.mark)
  author = LibTranslit:Transliterate(author, options.mark)
  return false, msg, author, ...
end

local function ChatHeader(self, arg1, arg2, arg3)
  if lastHookChatFrame1EditBoxHeader == arg2 then
    return
  else
    if arg3 then
      name = LibTranslit:Transliterate(arg3, options.mark)
      lastHookChatFrame1EditBoxHeader = name
      self:SetFormattedText(arg1, arg2, name)
    else
      name = LibTranslit:Transliterate(arg2, options.mark)
      lastHookChatFrame1EditBoxHeader = name
      self:SetFormattedText(arg1, name)
    end
  end
end

local function SetupChat()
  local lastHookChatFrame1EditBoxHeader = nil
  hooksecurefunc(ChatFrame1EditBoxHeader, "SetFormattedText", ChatHeader)

  ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_HORDE", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_ALLIANCE", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_NEUTRAL", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE", Chat)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_WHISPER", Chat)
end

local function Tooltip(self)
    for i=1, self:NumLines() do
      local text = _G["GameTooltipTextLeft"..i]
      text:SetText(((LibTranslit:Transliterate(text:GetText(), options.mark) or "")))
    end
end

local function SetupTooltip()
  local lastHookGameTooltip = nil
  hooksecurefunc(GameTooltip, "Show", Tooltip)
end

local function SetupConfig(c)
	if configOpenRunOnce then
		return
	end

	configOpenRunOnce = true
	config.title = config:CreateFontString("TranslitConfigTitle", "ARTWORK", "GameFontNormal")
	config.title:SetFont(GameFontNormal:GetFont(), 16, "OUTLINE")
	config.title:SetPoint("TOPLEFT", config, 10, -10)
	config.title:SetText(config.name)

  config.markBoxTitle = config:CreateFontString("TranslitMarkBoxTitle", "ARTWORK", "GameFontNormal")
	config.markBoxTitle:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
	config.markBoxTitle:SetPoint("TOPLEFT", config, 10, -50)
	config.markBoxTitle:SetText("|cffffffff" .. "Transliteration Mark: " .. "|r")

	config.markBox = CreateFrame("EditBox", "TranslitMarkBox", config, "InputBoxTemplate")
	config.markBox:SetPoint("TOPLEFT", config, 120, -46)
	config.markBox:SetSize(20, 20)
	config.markBox:SetAutoFocus(false)
	config.markBox:SetMultiLine(false)
	config.markBox:SetText(options.mark)
	config.markBox:SetCursorPosition(0)
	config.markBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  
	config.chatButton = CreateFrame("CheckButton", "TranslitChatButton", config, "InterfaceOptionsCheckButtonTemplate")
	config.chatButton:SetPoint("TOPLEFT", config, 10, -80)
	config.chatButton:SetChecked(options.chat)
	config.chatButton:SetHitRectInsets(0, -200, 0, 0)
	config.chatButtonTitle = config:CreateFontString("TranslitChatButtonTitle", "ARTWORK", "GameFontNormal")
	config.chatButtonTitle:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
	config.chatButtonTitle:SetPoint("LEFT", config.chatButton, 30, 0)
	config.chatButtonTitle:SetText("|cffffffff Translit Chat|r")

	config.tooltipButton = CreateFrame("CheckButton", "TranslitTooltipButton", config, "InterfaceOptionsCheckButtonTemplate")
	config.tooltipButton:SetPoint("TOPLEFT", config, 10, -110)
	config.tooltipButton:SetChecked(options.tooltip)
	config.tooltipButton:SetHitRectInsets(0, -200, 0, 0)
	config.tooltipButtonTitle = config:CreateFontString("TranslitTooltipButtonTitle", "ARTWORK", "GameFontNormal")
	config.tooltipButtonTitle:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
	config.tooltipButtonTitle:SetPoint("LEFT", config.tooltipButton, 30, 0)
	config.tooltipButtonTitle:SetText("|cffffffff Translit Tooltip|r")	
  
  config.okay = function(self)
    Translit.mark = config.markBox:GetText()
    Translit.chat = config.chatButton:GetChecked()
    Translit.tooltip  = config.tooltipButton:GetChecked()
    
    --ReloadUI()
    options = Translit
  end
  
  config.cancel = function(self)
    config.markBox:SetText(options.mark)
		config.chatButton:SetChecked(options.chat)	
		config.tooltipButton:SetChecked(options.tooltip)
	end

  print(config)
	InterfaceOptions_AddCategory(config)

end

function f:PLAYER_LOGIN()
  SetupConfig()
  
  if options.chat then
    SetupChat()
  end

  if options.tooltip then
    SetupTooltip()
  end
end

function f:ADDON_LOADED(addon)
  if addon == "Translit" then
    f:UnregisterEvent("ADDON_LOADED")

    local defaults = {
      mark = "!",
			chat = true,
			tooltip = true
    }
    
    Translit = Translit or {}

    for k,v in pairs(defaults) do
			if Translit[k] == nil then
				Translit[k] = v
			end
    end
    
    options = Translit

    SLASH_TRANSLIT1 = "/translit"
		SlashCmdList.TRANSLIT = function(msg)
      InterfaceOptionsFrame_Show()
      InterfaceOptionsFrame_OpenToCategory(config)
    end
    
    f:RegisterEvent("PLAYER_LOGIN")
  end
end

f:SetScript("OnEvent", function(self, event, ...)
  self[event](self, ...)
end)

f:RegisterEvent("ADDON_LOADED")