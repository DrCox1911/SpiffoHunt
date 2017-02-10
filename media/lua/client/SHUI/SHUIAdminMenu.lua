--require "ISUI/ISPanelJoypad"
require "ISUI/ISCollapsableWindow"
require "ISUI/ISComboBox"

SHUIAdminMenu = ISCollapsableWindow:derive("SHUIAdminMenu");
SHUIAdminMenu.instance = {}

function SHUIAdminMenu:initialise()
	ISCollapsableWindow.initialise(self);
	self:create();
end

function SHUIAdminMenu:render()
	local y = 42;
	ISCollapsableWindow.render(self);

	-- if JoypadState.players[self.playerId+1] then
		-- self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
		-- self:drawRectBorder(1, 1, self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
	-- end
end

function SHUIAdminMenu:create()
	local y = 20;

	-- local label = ISLabel:new(16, y, 20, getText('UI_SpiffoHunt_AdminMenu_Headline'), 1, 1, 1, 0.8, UIFont.Small, true);
	-- self:addChild(label);

	local button = self:createButton(16, y+50, self.onBtnClick, "startround", getText('UI_SpiffoHunt_AdminMenu_StartRound'));
	button = self:createButton(16, y+100, self.onBtnClick, "stopround", getText('UI_SpiffoHunt_AdminMenu_StopRound'));
	button = self:createButton(16, y+200, self.onBtnClick, "zoneblue", getText('UI_SpiffoHunt_AdminMenu_ZoneBlue'));
	button = self:createButton(16, y+250, self.onBtnClick, "zonered", getText('UI_SpiffoHunt_AdminMenu_ZoneRed'));

	local combobox = ISComboBox:new(160, y+50, 96, 20, combobox, self.onComboboxChange, "roundlength", nil);
	combobox:addOptionWithData("30min", 3);
	combobox:addOptionWithData("60min", 6);
	combobox:addOptionWithData("90min", 9);
	combobox:addOptionWithData("120min", 12);
	combobox:addOptionWithData("150min", 15);
	combobox:addOptionWithData("180min", 18);
	self:addChild(combobox);
	local luanet = LuaNet:getInstance();
	local module = luanet.getModule("SpiffoHunt");
	module.send("changesetting", "roundlength", combobox.options[combobox.selected]);

end

function SHUIAdminMenu:onComboboxChange(_target, _internal)
	local luanet = LuaNet:getInstance();
	local module = luanet.getModule("SpiffoHunt");
	print("CBData...:::")
	print("_target: " .. tostring(_target));
	print("_internal: " .. tostring(_internal));
	print("ComboChange: " .. tostring(_target.options[_target.selected].data));
	if _internal == "roundlength" then
		module.send("changesetting", _internal, _target.options[_target.selected]);
	end
end

function SHUIAdminMenu:onBtnClick(button, x, y)
	local luanet = LuaNet:getInstance();
	local module = luanet.getModule("SpiffoHunt");

	if button.internal == "startround" then
		module.send("startround", "setting");
	elseif button.internal == "stopround" then
		module.send("stopround", "setting");
	elseif button.internal == "zoneblue" then
		local player = getPlayer();
		local sq = player:getSquare();
		local cell = sq:getCell();
		local zone = getTexture("media/textures/bluezone.png");
		print(tostring(zone));
		module.send("changesetting", "zoneblue", sq);
	end
end

function SHUIAdminMenu:createButton(x, y, _function, _internal, _label)
	local label = nil;
	label = _label;--
	local button = ISButton:new(x, y, 100, 25, label, self, _function);
	button:initialise();
	button.internal = _internal;
	button.borderColor = {r=1, g=1, b=1, a=0.1};
	--button.playerId = playerId;
	--button.char = player;
	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	--table.insert(self.buttons, button);
	self.buttons[_internal] = button;
end

function SHUIAdminMenu:new(x, y, width, height, player)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	--o:noBackground();
	o:setTitle(getText('UI_SpiffoHunt_AdminMenu_Headline'));
	setmetatable(o, self);
    self.__index = self;
	--o.char = getSpecificPlayer(player);
	o.player = player;
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.9};
	o.buttons = {};
	o.combobox = {};
   return o;
end
