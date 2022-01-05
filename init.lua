--RacePunk made by ChristianGroeber
--Version 0.1
--A simple mod to bring racing (back) to Cyberpunk 2077

registerForEvent('onInit', function()
    MyPins = {};
    ElapsedDelta = 0;
    Debug = true;
    Race = nil;
    print('RacePunk initialized');
end)

registerForEvent('onUpdate', function(timeDelta)
    if Race then
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
        --ElapsedDelta = ElapsedDelta + timeDelta
        --if ElapsedDelta >= 0.5 then
        --    ElapsedDelta = 0;
        --end
    end
end)

registerHotkey('find_race', 'Find a new Race', function()
    GetRace();
end)

registerHotkey('accept_race', 'Accept a Race', function()
    Race.Accepted = true;
end)

registerHotkey('cancel_race', 'Cancel the current Race', function()
    UnsetMappins();
end)

function GetRace() --Step 1
    Race = NewRace();
    Race.Start.pin = PlaceMapPinFromTable(Race.Start);
    table.insert(MyPins, Race.Start.pin);
end

function StartRace() --Step 2
    UnsetMappin(Race.Start.pin);
    Race.End.pin = PlaceMapPinFromTable(Race.End);
    table.insert(MyPins, Race.End.pin);
    print("The Race has started");
end

function EndRace() --Step 3
    print('You won the Race');
    UnsetMappins();
end

function UnsetMappin(pin)
    Game.GetMappinSystem():UnregisterMappin(pin);
    local PinIndex = IndexOf(pin);
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
        Reward = 0,
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

function CheckRaceFinished()
    print('checking');
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
