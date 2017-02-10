require "ISUI/ISCollapsableWindow"

SHUIRoundInfo = ISCollapsableWindow:derive("SHUIRoundInfo");
SHUIRoundInfo.instance = {};

function SHUIRoundInfo:initialise()
	ISCollapsableWindow.initialise(self);
	self:create();
end

function SHUIRoundInfo:render()
	local y = 74;
	self:drawText(getText('UI_SpiffoHunt_RoundInfo_State') .. ": " .. tostring(self.roundstate), 20, y, 1,1,1,1, UIFont.Medium);
	y = y+16;
	self:drawText(getText('UI_SpiffoHunt_RoundInfo_TimeLeft') .. ": " .. tostring(self.roundinfo["time"]), 20, y, 1,1,1,1, UIFont.Medium);
	y = y+32;
	self:drawText(getText('UI_SpiffoHunt_RoundInfo_PointsBlue') .. ": " .. tostring(self.roundinfo["pblue"]), 20, y, 1,1,1,1, UIFont.Medium);
	y = y+16;
	self:drawText(getText('UI_SpiffoHunt_RoundInfo_PointsRed') .. ": " .. tostring(self.roundinfo["pred"]), 20, y, 1,1,1,1, UIFont.Medium);

end

function SHUIRoundInfo:create()
	local y = 16;
	local stringlength = getTextManager():MeasureStringX(UIFont.Large, "SpiffoHunt")/2
	local label = ISLabel:new(self.width/2-stringlength, y, 20, "SpiffoHunt", 1, 1, 1, 0.8, UIFont.Large, true);
	self:addChild(label);
	
	label = ISLabel:new(20, y+32, 20, getText('UI_SpiffoHunt_RoundInfo_Team') .. ": " .. self.team, 1, 1, 1, 0.8, UIFont.Medium, true);
	self:addChild(label);
end

function SHUIRoundInfo:updateRoundState(_roundstate)
	self.roundstate = _roundstate;
end

function SHUIRoundInfo:updateRoundInfo(_pointsBlue, _pointsRed, _time)
	if _pointsBlue ~= -1 then self.roundinfo["pblue"] = _pointsBlue; end
	if _pointsRed ~= -1 then self.roundinfo["pred"] = _pointsRed; end
	if _time ~= -1 then self.roundinfo["time"] = _time; end
end

function SHUIRoundInfo:new(x, y, width, height, player, team, roundstate)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	--o:noBackground();
	o:setTitle(getText('UI_SpiffoHunt_RoundInfo_Headline'));
	setmetatable(o, self);
    self.__index = self;
	--o.char = getSpecificPlayer(player);
	o.player = player;
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.9};
	o.buttons = {};
	o.team = team;
	o.roundinfo = {pblue=0, pred=0, time=0};
	o.roundstate = roundstate;
   return o;
end