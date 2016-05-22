	-------------------------------------------------------------------------------	
	local flagCarriers = {}
	local blipTexture = [[Interface\addons\enemyFrames\globals\resources\blips\blip]]
	local minimapTableBlips 	= {{'BattlefieldMinimapParty', 17, MAX_PARTY_MEMBERS}, {'BattlefieldMinimapRaid', 17, MAX_RAID_MEMBERS}}
	local worldMapTableBlips 	= {{'WorldMapRaid', 19, MAX_RAID_MEMBERS}, {'WorldMapParty', 19, MAX_PARTY_MEMBERS}}
	-------------------------------------------------------------------------------
	local icon, name, color
	local skinBlip = function(f, blip, size)
		icon = _G[blip:GetName()..'Icon']
		if not blip.unit then return end
		name = blip.name or UnitName(blip.unit)
		
		blip:SetHeight(size)	blip:SetWidth(size)
		if flagCarriers[f] == name then
			blip:SetHeight(size+3)	blip:SetWidth(size+3)
			icon:SetTexture('Interface\\WorldStateFrame\\'..f..'Flag')
			icon:SetVertexColor(1, 1, 1)
		else				
			if GetNumRaidMembers() > 0 then
				local _, _, subgroup = GetRaidRosterInfo(string.sub(blip.unit, 5))
				icon:SetTexture(blipTexture..subgroup)
			else
				icon:SetTexture(blipTexture)
			end

			local _, class  = UnitClass(blip.unit)
			color = RAID_CLASS_COLORS[class]
			if color then
				icon:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end
	-------------------------------------------------------------------------------
	local updateBlips = function(tableBlips)
		local f = UnitFactionGroup'player' == 'Alliance' and 'Horde' or 'Alliance'
		for i = 1, 2 do
			for j = 1, tableBlips[i][3] do		
				skinBlip(f, _G[tableBlips[i][1]..j], tableBlips[i][2])
			end
		end
	end
	-------------------------------------------------------------------------------
	local addOnShow = function(tableBlips)
		for i = 1, 2 do
			for j = 1, tableBlips[i][3] do
				local mapBlip = _G[tableBlips[i][1]..j]
				mapBlip.size = tableBlips[i][2]
				mapBlip:SetScript('OnShow', function()
						local f = UnitFactionGroup'player' == 'Alliance' and 'Horde' or 'Alliance'
						skinBlip(f, this, this.size)
				end)
			end
		end
	end
	addOnShow(worldMapTableBlips)
	-------------------------------------------------------------------------------
	PVPMAPsetFC = function(fc)
		flagCarriers = fc
		updateBlips(worldMapTableBlips)
		if isAddOnLoaded'Blizzard_BattlefieldMinimap' then 
			updateBlips(minimapTableBlips)
		end		
	end
	-------------------------------------------------------------------------------
	local eventHandler = function()
		if event == 'ZONE_CHANGED_NEW_AREA' then
			flagCarriers = {}
		elseif event == 'ADDON_LOADED' then
			if arg1 == 'Blizzard_BattlefieldMinimap' then
				addOnShow(minimapTableBlips)
			end
		else
			updateBlips(worldMapTableBlips)
			if isAddOnLoaded'Blizzard_BattlefieldMinimap' then 
				updateBlips(minimapTableBlips)
			end	
		end
	end
	-------------------------------------------------------------------------------
	local f = CreateFrame('Frame', nil, WorldMapFrame)
	f:RegisterEvent'ADDON_LOADED'
	f:RegisterEvent'RAID_ROSTER_UPDATE'
	f:RegisterEvent'ZONE_CHANGED_NEW_AREA'
	f:SetScript('OnEvent', eventHandler)
	-------------------------------------------------------------------------------
