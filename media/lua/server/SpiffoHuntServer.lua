

require 'CoxisUtil'

SpiffoHuntServer = {};
SpiffoHuntServer.luanet = nil;
SpiffoHuntServer.module = nil;
SpiffoHuntServer.state = "";
SpiffoHuntServer.settings = {};
SpiffoHuntServer.debug = true;


SpiffoHuntServer.printDebug = function(_string)
	if SpiffoHuntServer.debug then
		CoxisUtil.printDebug("SpiffoHuntServer", _string);
	end
end


SpiffoHuntServer.startRound = function(_player, _state)
	SpiffoHuntServer.state = "roundStarted"
	Events.EveryTenMinutes.Add(SpiffoHuntServer.updateRoundTimer);
	SpiffoHuntServer.module.send("startround", SpiffoHuntServer.state)
	SpiffoHuntServer.module.send("updateroundinfo", 0, 0, SpiffoHuntServer.settings["roundlength"]*10);
end

SpiffoHuntServer.stopRound = function(_player, _state)
	SpiffoHuntServer.state = "roundStopped"
	Events.EveryTenMinutes.Remove(SpiffoHuntServer.updateRoundTimer);
	SpiffoHuntServer.module.send("stopround", SpiffoHuntServer.state)
end

SpiffoHuntServer.updateRoundTimer = function()
	if tonumber(SpiffoHuntServer.settings["roundlength"]) > 0 then
		SpiffoHuntServer.settings["roundlength"] = SpiffoHuntServer.settings["roundlength"] - 1;
		SpiffoHuntServer.module.send("updateroundinfo", -1, -1, SpiffoHuntServer.settings["roundlength"]*10);
	elseif tonumber(SpiffoHuntServer.settings["roundlength"]) == 1 then
		--sendWorldMessage("10min");	-- doesn´t work right now!
	elseif tonumber(SpiffoHuntServer.settings["roundlength"]) == 0 then
		SpiffoHuntServer.printDebug("Round ended!");
		Events.EveryTenMinutes.Remove(SpiffoHuntServer.updateRoundTimer);
		SpiffoHuntServer.stopRound(nil, "roundStopped");
	end
end

SpiffoHuntServer.updateRoundInfo = function(_player, _pointsblue, _pointsred, _time)
end

SpiffoHuntServer.roundState = function(_player, _state)
	SpiffoHuntServer.printDebug("Sending roundState");
	if _player and not instanceof(_player, "IsoPlayer") then
		SpiffoHuntServer.printDebug("Not a instance of IsoPlayer");
		return;
	end

	-- SpiffoHuntServer.state = _state;
	-- if SpiffoHuntServer.state == "startround" then
		-- Events.EveryTenMinutes.Add(SpiffoHuntServer.updateRoundTimer);
	-- elseif SpiffoHuntServer.state == "stopround" then
		-- Events.EveryTenMinutes.Remove(SpiffoHuntServer.updateRoundTimer);
	-- end

	--SpiffoHuntServer.module.sendPlayer(_player, "roundstate", SpiffoHuntServer.state);
	SpiffoHuntServer.module.send("roundstate", SpiffoHuntServer.state);
end

SpiffoHuntServer.changeSetting = function(_player, _option, _settings)
	SpiffoHuntServer.printDebug("Received Settings for option: " .. tostring(_option));
	for k,v in pairs(_settings) do
		SpiffoHuntServer.printDebug("k: " .. tostring(k));
		SpiffoHuntServer.printDebug("v: " .. tostring(v));
	end

	if _option == "roundlength" then
		SpiffoHuntServer.printDebug(_settings["data"]);
		SpiffoHuntServer.settings["roundlength"] = _settings["data"];
	elseif _option == "zoneblue" then
		SpiffoHuntServer.printDebug(_settings);
		SpiffoHuntServer.settings["zoneblue"] = _settings;
	end
end

SpiffoHuntServer.joiningTeam = function(_player, _team)

end

SpiffoHuntServer.initNetwork = function()
	SpiffoHuntServer.printDebug("Server Network initialization");
	SpiffoHuntServer.module = SpiffoHuntServer.luanet.getModule("SpiffoHunt", SpiffoHuntServer.debug);

	SpiffoHuntServer.module.addCommandHandler("joiningteam", SpiffoHuntServer.joiningTeam);
	SpiffoHuntServer.module.addCommandHandler("startround", SpiffoHuntServer.startRound);
	SpiffoHuntServer.module.addCommandHandler("stopround", SpiffoHuntServer.stopRound);
	SpiffoHuntServer.module.addCommandHandler("changesetting", SpiffoHuntServer.changeSetting);
	SpiffoHuntServer.module.addCommandHandler("roundstate", SpiffoHuntServer.roundState);
	SpiffoHuntServer.module.addCommandHandler("updateroundinfo", SpiffoHuntServer.updateRoundInfo);

	SpiffoHuntServer.state = "waitForAdmin";
end

SpiffoHuntServer.init = function()
	if isServer() then
		SpiffoHuntServer.printDebug("Server initialization");
		SpiffoHuntServer.luanet = LuaNet:getInstance();
		--if not SpiffoHuntServer.luanet.isRunning() then SpiffoHuntServer.printDebug("LuaNet not running") return; end
		if SpiffoHuntServer.debug then SpiffoHuntServer.luanet.setDebug(true); end
		SpiffoHuntServer.luanet.onInitAdd(SpiffoHuntServer.initNetwork);
	end
end

--Events.OnServerStarted.Add(SpiffoHuntServer.init)
Events.OnGameBoot.Add(SpiffoHuntServer.init)
