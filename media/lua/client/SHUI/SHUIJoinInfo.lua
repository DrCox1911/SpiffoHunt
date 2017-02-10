require "ISUI/ISModalDialog"

SHUIJoinInfo = ISModalDialog:derive("SHUIJoinInfo");
SHUIJoinInfo.instance = {};

function SHUIJoinInfo:initialise()
	--ISModalDialog.initialise(self);
	ISPanel.initialise(self);
	local btnWid = 100
	local btnHgt = 25
	local padBottom = 10
		self.yes = ISButton:new((self:getWidth() / 2) - btnWid - 5, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText('UI_SpiffoHunt_JoinInfo_JoinBlue'), self, self.onBtnClick);
		self.yes.internal = "joinblue";
		self.yes:initialise();
		self.yes:instantiate();
		self.yes.borderColor = {r=1, g=1, b=1, a=0.1};
		self:addChild(self.yes);

		self.no = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText('UI_SpiffoHunt_JoinInfo_JoinRed'), self, self.onBtnClick);
		self.no.internal = "joinred";
		self.no:initialise();
		self.no:instantiate();
		self.no.borderColor = {r=1, g=1, b=1, a=0.1};
		self:addChild(self.no);
	
	self:create();
end

function SHUIJoinInfo:render()
	local y = 74;
end

function SHUIJoinInfo:create()
	local y = 32;
	local label = ISLabel:new(16, y, 20, getText('UI_SpiffoHunt_JoinInfo_Warning'), 1, 1, 1, 0.8, UIFont.Large, true);
	self:addChild(label);
	y=y+48;
	label = ISLabel:new(16, y, 20, getText('UI_SpiffoHunt_JoinInfo_Explanation'), 1, 1, 1, 0.8, UIFont.Medium, true);
	self:addChild(label);
	
	--local button = self:createButton(160, self.height-160, self.onBtnClick, "joinblue", getText('UI_SpiffoHunt_JoinInfo_JoinBlue'));
	--button = self:createButton(self.width-160, self.height-160, self.onBtnClick, "joinred", getText('UI_SpiffoHunt_JoinInfo_JoinRed'));
end

function SHUIJoinInfo:createButton(x, y, _function, _internal, _label)
	local label = nil;
	label = _label;
	local button = ISButton:new(x, y, 100, 25, label, self, _function);
	button:initialise();
	button.internal = _internal;
	button.borderColor = {r=1, g=1, b=1, a=0.1};
	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	self.buttons[_internal] = button;
end

function SHUIJoinInfo:onBtnClick(button, x, y)
	local luanet = LuaNet:getInstance();
	local module = luanet.getModule("SpiffoHunt");
	
	--SpiffoHuntClient.module.send("roundstate", "asking");
	if button.internal == "joinblue" then
		-- joining team blue
		print("joining blue");
		module.sendPlayer(getSpecificPlayer(0), "joiningteam", "UI_SpiffoHunt_RoundInfo_Blue");
		--self:setVisible(false);
	elseif button.internal == "joinred" then
		-- joining team red
		print("joining red");
		module.sendPlayer(getSpecificPlayer(0), "joiningteam", "UI_SpiffoHunt_RoundInfo_Red");
		--self:setVisible(false);
	end
	self:destroy();
end

function SHUIJoinInfo:new(x, y, width, height, text)
	local o = {};
	o = ISModalDialog:new(x, y, width, height, text, true, nil, onBtnClick, 0, nil, nil);
	--o:noBackground();
	--o:setTitle("SpiffoHunt");
	setmetatable(o, self);
    self.__index = self;
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.9};
	o.buttons = {};
   return o;
end