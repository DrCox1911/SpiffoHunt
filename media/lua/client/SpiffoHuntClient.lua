--[[
#########################################################################################################
#	@mod:		 - A PvP gamemode similiar to Capture the Flag											#
#	@author: 	Dr_Cox11911																				#
#	@notes:		Many thanks to TurboTuTone and all the other modders out there							#
#	@notes:		For usage instructions check forum link below											#
#	@link: 																								#
#########################################################################################################
--]]

require 'CoxisUtil'

SpiffoHuntClient = {};
SpiffoHuntClient.module = nil;
SpiffoHuntClient.luanet = nil;
SpiffoHuntClient.state = nil;
SpiffoHuntClient.adminMenu = nil;
SpiffoHuntClient.roundInfo = nil;
SpiffoHuntClient.debug = true;



local ISWalkToTimedAction_update_old = ISWalkToTimedAction.update;
function ISWalkToTimedAction:update(...)    
	if instanceof(self.character, "IsoPlayer") and self.character:isBlockMovement() then
		self:forceStop();
		return;    
	end
	return ISWalkToTimedAction_update_old(self, ...);
end

SpiffoHuntClient.freezePlayer = function()
	local player = getPlayer();
	if player then
		player:setBlockMovement(true);
		player:setPath(nil);
	else
		SpiffoHuntClient.printDebug("Error retrieving player");
	end
end

SpiffoHuntClient.unfreezePlayer = function()
	local player = getPlayer();
	if player then
		getPlayer():setBlockMovement(false);
	else
		SpiffoHuntClient.printDebug("Error retrieving player");
	end
end

SpiffoHuntClient.printDebug = function(_string)
	if SpiffoHuntClient.debug then
		CoxisUtil.printDebug("SpiffoHuntClient", _string);
	end
end

SpiffoHuntClient.roundState = function(_player, _state)
	if _player and not instanceof(_player, "IsoPlayer") then
		SpiffoHuntClient.printDebug("Not a instance of IsoPlayer");
		return;
	end
	SpiffoHuntClient.state = _state;
	SpiffoHuntClient.printDebug(_state);
	local message = "";
	if SpiffoHuntClient.state == "waitForAdmin" then
		SpiffoHuntClient.freezePlayer();
		message = getText('UI_SpiffoHunt_state_waitForAdmin');
	--elseif SpiffoHuntClient.state == "roundStarted" then
		--message = getText('UI_SpiffoHunt_state_roundStarted');
	end
	SpiffoHuntClient.roundInfo:updateRoundState(SpiffoHuntClient.state);
end

SpiffoHuntClient.startRound = function(_player, _state)
	SpiffoHuntClient.unfreezePlayer();
	SpiffoHuntClient.roundState(_player, _state);
end

SpiffoHuntClient.stopRound = function(_player, _state)
	SpiffoHuntClient.freezePlayer();
	SpiffoHuntClient.roundState(_player, _state);
end

SpiffoHuntClient.changeSetting = function(_player, _option, _settings)

end

SpiffoHuntClient.askState = function()
	SpiffoHuntClient.printDebug("Asking for state to know what to do");
	SpiffoHuntClient.module.send("roundstate", "asking");
end

SpiffoHuntClient.joiningTeam = function(_player, _team)
	--SpiffoHuntClient.printDebug(_player);
	--SpiffoHuntClient.printDebug(_team);
	
	--SpiffoHuntClient.printDebug("Player " .. tostring(getUsername(_player)) .. " joining team " .. tostring(_team));
	SpiffoHuntClient.roundInfo = SHUIRoundInfo:new(60, 0, 320, 180, getSpecificPlayer(0), getText(_team), SpiffoHuntClient.state);
	SpiffoHuntClient.roundInfo:initialise();
	SpiffoHuntClient.roundInfo:addToUIManager();
	SpiffoHuntClient.roundInfo:setVisible(true);
	SpiffoHuntClient.askState();
end

SpiffoHuntClient.updateRoundInfo = function(_player, _pointsblue, _pointsred, _time)
	SpiffoHuntClient.printDebug(_player);
	SpiffoHuntClient.printDebug(_pointsblue);
	SpiffoHuntClient.printDebug(_pointsred);
	SpiffoHuntClient.printDebug(_time);
	SpiffoHuntClient.roundInfo:updateRoundInfo(_pointsblue, _pointsred, _time);
end

SpiffoHuntClient.initNetwork = function()
	SpiffoHuntClient.printDebug("Client Network initialization");
	SpiffoHuntClient.module = SpiffoHuntClient.luanet.getModule("SpiffoHunt", SpiffoHuntClient.debug)
	
	SpiffoHuntClient.module.addCommandHandler("joiningteam", SpiffoHuntClient.joiningTeam);
	SpiffoHuntClient.module.addCommandHandler("startround", SpiffoHuntClient.startRound);
	SpiffoHuntClient.module.addCommandHandler("stopround", SpiffoHuntClient.stopRound);
	SpiffoHuntClient.module.addCommandHandler("changesetting", SpiffoHuntClient.changeSetting);
	SpiffoHuntClient.module.addCommandHandler("roundstate", SpiffoHuntClient.roundState);
	SpiffoHuntClient.module.addCommandHandler("updateroundinfo", SpiffoHuntClient.updateRoundInfo);
	--SpiffoHuntClient.askState();
	
end

-- **************************************************************************************
-- handling key presses here
-- **************************************************************************************
SpiffoHuntClient.onKeyPressed = function(_key)
		if _key == Keyboard.KEY_P then
			if getSpecificPlayer(0) and not getSpecificPlayer(0):isDead() then
					--luautils.okModal(getText('UI_SpiffoHuntClient_NoSettings'), true, 100, 100, 0, 0)
				--SpiffoHuntClient.askState();
				SpiffoHuntClient.printDebug(getAccessLevel());
				if getAccessLevel() == "admin" then
					if SpiffoHuntClient.adminMenu == nil then
						local x = getPlayerScreenLeft(0)
						local y = getPlayerScreenTop(0)
					
						SpiffoHuntClient.adminMenu = SHUIAdminMenu:new(x+100, y+100, 400, 600, getSpecificPlayer(0));
						SpiffoHuntClient.adminMenu:initialise();
						SpiffoHuntClient.adminMenu:addToUIManager();
						SpiffoHuntClient.adminMenu:setVisible(true);
						
					elseif SpiffoHuntClient.adminMenu ~= nil then
						SpiffoHuntClient.adminMenu:setVisible(not SpiffoHuntClient.adminMenu:getIsVisible());
					else
						SpiffoHuntClient.printDebug("Problem with the admin menu!");
					end
				end
			end
		-- elseif _key == Keyboard.KEY_P then
			-- if SpiffoHuntClient.roundInfo == nil then
				-- SpiffoHuntClient.roundInfo = SHUIRoundInfo:new(50, 32, 320, 180, getSpecificPlayer(0), getText('UI_SpiffoHunt_RoundInfo_Blue'), SpiffoHuntClient.state);
				-- SpiffoHuntClient.roundInfo:initialise();
				-- SpiffoHuntClient.roundInfo:addToUIManager();
				-- SpiffoHuntClient.roundInfo:setVisible(true);
			-- end
		end
end

SpiffoHuntClient.init = function()
	if isClient() then
		SpiffoHuntClient.printDebug("Client initialization");
		SpiffoHuntClient.luanet = LuaNet:getInstance();
		if SpiffoHuntClient.debug then SpiffoHuntClient.luanet.setDebug(true); end
		SpiffoHuntClient.luanet.onInitAdd(SpiffoHuntClient.initNetwork);
		Events.OnKeyPressed.Add(SpiffoHuntClient.onKeyPressed);
	end
end

SpiffoHuntClient.showInfo = function()
	local core = getCore();
	local width = core:getScreenWidth()-32;
	local height = core:getScreenHeight()-32;
	local posX = core:getScreenWidth() * 0.5 - width * 0.5;
    local posY = core:getScreenHeight() * 0.5 - height * 0.5;
	local joininfo = SHUIJoinInfo:new(posX, posY, width, height, "");
	joininfo:initialise();
	joininfo:addToUIManager();
	joininfo:setVisible(true);
end

SpiffoHuntClient.start = function()
	if isClient() then
		SpiffoHuntClient.freezePlayer();
		
		--CoxisUtil.okModal("This is a special gamemode and does not represent the normal playstile of PZ!", true, 20, 20, 0, 0, SpiffoHuntClient.askState);
	end
end

Events.OnConnected.Add(SpiffoHuntClient.init)
Events.OnGameStart.Add(SpiffoHuntClient.start)
Events.OnCreateUI.Add(SpiffoHuntClient.showInfo)