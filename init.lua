--RacePunk made by ChristianGroeber
--Version 0.1
--A simple mod to bring racing (back) to Cyberpunk 2077

local GameHUD = require('Modules/GameHUD.lua');

local HUDMessage_Current = ""
local HUDMessage_Last = 0

registerForEvent('onInit', function()
    MyPins = {};
    ElapsedDelta = 0;
    Debug = true;
    Race = nil;
    MeasuringRace = nil;
    print('RacePunk initialized');
end)

registerForEvent('onUpdate', function(timeDelta)
    if (Race) then
        if (not Race.Started) then
            Race.Started = PlayerIsInPosition(Race.Start);
            if (Race.Started) then
                StartRace();
            end
        elseif (Race.Started) then
            Race.Finished = PlayerIsInPosition(Race.End);
            if Race.Finished then
                EndRace();
            end
        end
    end
    if (MeasuringRace) then
        MeasuringRace.Time = MeasuringRace.Time + timeDelta;
    end
end)

registerHotkey('find_race', 'Find a new Race', function()
    GetRace();
end)

registerHotkey('cancel_race', 'Cancel the current Race', function()
    UnsetMappins();
    Race = nil;
    HUDMessage('Successfully cancelled the race');
end)

registerHotkey('dev_set_start', 'Set this as the start point for a race', function()
    MeasuringRace = {
        Start = GetPlayerPosition(),
        End = nil,
        Time = 0,
    }
end)

registerHotkey('dev_set_end', 'The race is finished here', function()
    MeasuringRace.End = GetPlayerPosition();
    print('START: ' .. CoordsToString(MeasuringRace.Start) .. "\nEnd: " .. CoordsToString(MeasuringRace.End) .. "\nTIME: " .. MeasuringRace.Time);
end)

registerHotkey('dev_cancel_recording', 'Cancel recording a new race', function()
    MeasuringRace = nil;
end)

function GetRace() --Step 1
    Race = NewRace();
    Race.Start.pin = PlaceMapPinFromTable(Race.Start);
    table.insert(MyPins, Race.Start.pin);
    HUDMessage('Found a Race, go there to start');
end

function StartRace() --Step 2
    HUDMessage("The Race has started");
    Race.Started = true;
    Race.End.pin = PlaceMapPinFromTable(Race.End);
    table.insert(MyPins, Race.End.pin);
    UnsetMappin(Race.Start.pin);
end

function EndRace() --Step 3
    print('Race Ended');
    HUDMessage('You won the Race');
    UnsetMappin(Race.End.pin);
	Game.AddToInventory("Items.money", Race.Reward);
    Race = nil;
end

function UnsetMappin(pin)
    Game.GetMappinSystem():UnregisterMappin(pin);
    local PinIndex = IndexOf(MyPins, pin);
    if (PinIndex ~= nil) then
        MyPins[PinIndex] = nil;
    end
end

function UnsetMappins()
    for key, pin in pairs(MyPins) do
        UnsetMappin(pin);
    end
    MyPins = {};
end

function IndexOf(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end
    return nil
end

function NewRace()
    return {
        Start = {x = -1235.5713,y = 1536.0328,z = 22.620506,w = 1, pin = nil},
        End = {x = -1249.5834,y = 1457.5667,z = 20.801819,w = 1, pin = nil},
        Reward = 1,
        Accepted = false,
        Started = false,
        Finished = false,
    }
end

function PlayerIsInPosition(checkPosition)
    local playerPosition = GetPlayerPosition();
	if (math.abs(checkPosition.x - playerPosition.x) < 10 and math.abs(checkPosition.y - playerPosition.y) < 10 and math.abs(checkPosition.z - playerPosition.z) < 3) then
		return true
	else
		return false
	end
end

function GetPlayerPosition()
	local p = Game.GetPlayer()
	if (p ~= nil) then
		return p:GetWorldPosition()
	else
		return nil
	end
end

function PlaceMapPinFromTable(tbl)
    return PlaceMapPin(tbl.x, tbl.y, tbl.z, tbl.w);
end

function PlaceMapPin(x, y, z, w) -- from CET Snippets discord
	local mappinData = MappinData.new()
	mappinData.mappinType = TweakDBID.new('Mappins.DefaultStaticMappin')
	mappinData.variant = gamedataMappinVariant.CustomPositionVariant
	-- more types: https://github.com/WolvenKit/CyberCAT/blob/main/CyberCAT.Core/Enums/Dumped%20Enums/gamedataMappinVariant.cs
	mappinData.visibleThroughWalls = true

	return Game.GetMappinSystem():RegisterMappin(mappinData, ToVector4{x=x, y=y, z=z, w=w} ) -- returns ID
end

function HUDMessage(msg) --from 'Hidden Packages' mod
	if os:clock() - HUDMessage_Last <= 1 then
		HUDMessage_Current = msg .. "\n" .. HUDMessage_Current
	else
		HUDMessage_Current = msg
	end

	GameHUD.ShowMessage(HUDMessage_Current)
	HUDMessage_Last = os:clock()
end

function CoordsToString(pos)
    return 'x=' .. pos.x .. ', y=' .. pos.y .. ',z=' .. pos.z .. ',w=' .. pos.w;
end