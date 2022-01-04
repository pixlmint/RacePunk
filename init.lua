function placeMapPin(x,y,z,w) -- from CET Snippets discord
	local mappinData = MappinData.new()
	mappinData.mappinType = TweakDBID.new('Mappins.DefaultStaticMappin')
	mappinData.variant = gamedataMappinVariant.CustomPositionVariant 
	-- more types: https://github.com/WolvenKit/CyberCAT/blob/main/CyberCAT.Core/Enums/Dumped%20Enums/gamedataMappinVariant.cs
	mappinData.visibleThroughWalls = true   

	return Game.GetMappinSystem():RegisterMappin(mappinData, ToVector4{x=x, y=y, z=z, w=w} ) -- returns ID
end

registerForEvent('onInit', function()
    Reset();
    elapsedDelta = 0;
end)

registerForEvent('onUpdate', function(timeDelta)
    elapsedDelta = elapsedDelta + timeDelta
    if elapsedDelta >= 0.5 then
        elapsedDelta = 0;
    end
end)
function Reset()
    Race = NewRace();
end

function NewRace()
    return {
        Start = {x=0,y=0,z=0,w=0},
        End = {x=0,y=0,z=0,w=0},
        Reward = 0,
        Started = false,
    }
end

registerHotkey('my_hotkey', 'My Hotkey', function()
    placeMapPin(-457.066, 940.031, 64.940, 1);
    print(GetPlayerPosition());
end)

function PlayerIsInPosition(playerPosition, checkPosition)
	if(math.abs(checkPosition.x - playerPosition.x) < 10 and math.abs(checkPosition.y - playerPosition.y) < 10 and math.abs(checkPosition.z - playerPosition.z) < 3)then
		return true
	else
		return false
	end
end

function GetPlayerPosition()
	local p = Game.GetPlayer()
	if(p ~= nil) then
		return p:GetWorldPosition()
	else
		return nil
	end
end

function CheckRaceFinished()
    print('checking');
end