--RacePunk made by ChristianGroeber
--Version 0.1
--A simple mod to bring racing (back) to Cyberpunk 2077

registerForEvent('onInit', function()
    Reset();
    ElapsedDelta = 0;
    Debug = true;
    PlaceMapPinFromTable(Race.Start);
    print('RacePunk initialized');
end)

registerForEvent('onUpdate', function(timeDelta)
    if (not Race.Started) then
        Race.Started = PlayerIsInPosition(Race.Start);
        if (Race.Started) then
            print("The Race has started");
            PlaceMapPinFromTable(Race.End);
        end
    elseif (Race.Started) then
        Race.Won = PlayerIsInPosition(Race.End);
        if Race.Won then
            print('You won the Race');
            Reset();
        end
    end
    ElapsedDelta = ElapsedDelta + timeDelta
    if ElapsedDelta >= 0.5 then
        ElapsedDelta = 0;
    end
end)

registerHotkey('find_race', 'Find a new Race', function()
    Reset(); --TODO: Instead of just resetting, actually find a race that is nearby
end)

registerHotkey('accept_race', 'Accept a Race', function()
    Race.Accepted = true;
end)

registerHotkey('cancel_race', 'Cancel the current Race', function()
    Reset();
end)

registerHotkey('my_hotkey', 'Test', function()
    placeMapPin(-457.066, 940.031, 64.940, 1);
    print(GetPlayerPosition());
end)

function Reset() --Reset the mod
    Race = NewRace();
end

function NewRace()
    return {
        Start = {x = -1235.5713,y = 1536.0328,z = 22.620506,w = 1},
        End = {x = -1249.5834,y = 1457.5667,z = 20.801819,w = 1},
        Reward = 0,
        Started = false,
        Accepted = false,
        Won = false,
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
