HS_SLUG, HS      = ...
HS.commandList["config"] = {
	["func"] = function() HSConfig:Show() end,
	["help"] = {"", "Config"}
}
HS.displayList = {}

function HS.UIInit()
	HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
	HS.ModifierDropDownBuild( HSConfig_ModifierDropDownMenu )
	HS.BuildBars()
end

function HS.TagDropDownBuild( self )
	UIDropDownMenu_Initialize( self, HS.TagDropDownPopulate )
	UIDropDownMenu_JustifyText( self, "LEFT" )
end
function HS.TagDropDownPopulate( self, level, menuList )
	local tagList = {}

	for hash in pairs( HS_settings.tags ) do
		table.insert( tagList, hash )
	end
	table.sort( tagList )
	for _, tag in ipairs( tagList ) do
		info = UIDropDownMenu_CreateInfo()
		info.text = tag
		info.notCheckable = true
		-- info.arg1 = tag
		info.func = HS.SetTagForEdit
		UIDropDownMenu_AddButton( info, level )
	end
	UIDropDownMenu_SetText( self, tagList[1] )
	HS.editTag = tagList[1]
end
function HS.SetTagForEdit( info )
	-- takes the info table
	print( "SetTagForEdit( "..info.value.." )" )
	-- UIDropDownMenu_SetText( )
	HS.editTag = info.value
	UIDropDownMenu_SetText( HSConfig_TagDropDownMenu, info.value )
	HSConfig_TagEditBox:SetText( info.value )
	HS.UpdateUI()
end

function HS.ModifierDropDownBuild( self )
	UIDropDownMenu_Initialize( self, HS.ModifierDropDownInit )
	UIDropDownMenu_JustifyText( self, "LEFT" )
end
function HS.ModifierDropDownInit( self, level, menuList )
	local modList = { "normal" }
	for _, mod in ipairs( HS.modOrder ) do
		table.insert( modList, mod )
	end
	for _, mod in ipairs( modList ) do
		info = UIDropDownMenu_CreateInfo()
		info.text = mod
		info.notCheckable = true
		info.func = HS.SetModForEdit
		UIDropDownMenu_AddButton( info, level )
	end
	UIDropDownMenu_SetText( self, "normal" )
end
function HS.SetModForEdit( info )
	print( "SetModForEdit( "..info.value.." )" )
	-- UIDropDownMenu_SetText( )
	UIDropDownMenu_SetText( HSConfig_ModifierDropDownMenu, info.value )
	HS.UpdateUI()
end
-------
function HS.TagButtonOnClick( self, action )
	print( "TagButtonOnClick( ", self, ", ", action, " )" )
	if action == "add" then
		local newTag = HSConfig_TagEditBox:GetText()
		if string.len( newTag ) > 0 then
			if string.sub( newTag, 1, 1 ) ~= "#" then
				newTag = "#"..newTag
			end
			if not HS_settings.tags[newTag] then
				print( "add: ", newTag )
				HS_settings.tags[newTag] = {}
				HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
			end
		end
	elseif action == "edit" then
		local selectedTag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
		local newTag = HSConfig_TagEditBox:GetText()
		if string.len( newTag ) > 0 then
			if string.sub( newTag, 1, 1 ) ~= "#" then
				newTag = "#"..newTag
			end
			if not HS_settings.tags[newTag] then
				print( "rename: ", selectedTag, "=>", newTag )
				HS_settings.tags[newTag] = HS_settings.tags[selectedTag]
				HS_settings.tags[selectedTag] = nil
				HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
				HS.editTag = newTag
				UIDropDownMenu_SetText( HSConfig_TagDropDownMenu, info.value )
				HSConfig_TagEditBox:SetText( info.value )
			end
		end
	elseif action == "del" then
		local selectedTag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
		if selectedTag then
			print( "delete:", selectedTag )
			HS_settings.tags[selectedTag] = nil
			HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
		end
	end
end

---------
function HS.BuildBars()
	print( "HS.BuildBars" )
	if not HS.bars then
		HS.bars = {}
	end
	showNumBars = 9
	local count = #HS.bars
	for idx = count+1, showNumBars do
		HS.bars[idx] = {}
		local item = CreateFrame( "Frame", "HS_ItemBar"..idx, HSConfig_ToyList, "HSToy_template" )
		HS.bars[idx].bar = item
		if idx == 1 then
			item:SetPoint( "TOPLEFT", "HSConfig_ToyList", "TOPLEFT", 5, -5 )
		else
			item:SetPoint( "TOPLEFT", HS.bars[idx-1].bar, "BOTTOMLEFT", 0, 0 )
		end

		local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(110560)
		-- print( item:GetName() )
		name = name or "Place holder"
		_G[item:GetName().."ToyName"]:SetText( name )
		_G[item:GetName().."Icon"]:SetTexture( icon )
		item:Show()
	end
end
--------
function HS.UpdateUI()
	if HSConfig:IsVisible() and HS_settings.tags then
		local tag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
		local mod = UIDropDownMenu_GetText( HSConfig_ModifierDropDownMenu )
		local count = ( HS_settings.tags[tag][mod] and #HS_settings.tags[tag][mod] or 0 )
		HSConfig_ToyListVSlider:SetMinMaxValues( 0, max( 0, count-9 ) )
		print( "count:"..count )
		if count > 0 then
			local offset = math.floor( HSConfig_ToyListVSlider:GetValue() )
			print( "offset:"..offset )
			local name, icon, barName
			for i = 1, 9 do
				local idx = i + offset
				if idx <= count then
					name, _, _, _, _, _, _, _, _, icon = GetItemInfo(HS_settings.tags[tag][mod][idx])
					barName = HS.bars[i].bar:GetName()
					_G[barName.."ToyName"]:SetText( name )
					_G[barName.."Icon"]:SetTexture( icon )
					HS.bars[i].bar.itemID = HS_settings.tags[tag][mod][idx]
					HS.bars[i].bar.itemIdx = idx
					HS.bars[i].bar:Show()
				else
					HS.bars[i].bar:Hide()
				end
			end
		elseif( HS.bars and count == 0 ) then
			for i = 1, 9 do
				HS.bars[i].bar:Hide()
			end
		end
	end
end
function HS.UIMouseWheel( delta )
	HSConfig_ToyListVSlider:SetValue(
		HSConfig_ToyListVSlider:GetValue() - delta
	)
end
function HS.UIOnReceiveDrag( self )
	print( "HS.UIOnReceiveDrag( ", self, " )" )
	local type, itemID, itemLink = GetCursorInfo()
	print( type, itemID, itemLink )
	if type == "item" then
		local tag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
		local mod = UIDropDownMenu_GetText( HSConfig_ModifierDropDownMenu )
		if HS_settings.tags[tag][mod] then
			table.insert( HS_settings.tags[tag][mod], itemID )
		else
			HS_settings.tags[tag][mod] = {itemID}
		end
	end
	ClearCursor()
	HS.UpdateUI()
end
function HS.UIOnMouseUp( self, button )
	print( "HS.UIOnMouseUp( ", self, ", ", button, " )" )
	local type, itemID, itemLink = GetCursorInfo()
	print( type, itemID, itemLink )
end
function HS.DelToyButtonOnClick( self )
	print( "HS.BarOnMouseDown( ", self, " )" )
	local tag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
	local mod = UIDropDownMenu_GetText( HSConfig_ModifierDropDownMenu )
	local idx = self:GetParent().itemIdx

	table.remove( HS_settings.tags[tag][mod], idx )
	if #HS_settings.tags[tag][mod] == 0 then
		HS_settings.tags[tag][mod] = nil
	end
	HS.UpdateUI()
end


-- UIDropDownMenu_SetText( RestedUIFrame.DropDownMenu, Rested.reportName )

-- function HS.MakeTabActive( self )
-- 	local tabsParent = self:GetParent()
-- 	local tabs = {tabsParent:GetChildren()}
-- 	for _, tab in pairs(tabs) do
-- 		local parentKey = tab:GetParentKey()
-- 		if self ~= tab and (parentKey == "tab1" or parentKey == "tab2" or parentKey == "tab3" ) then
-- 			tab:SetSelected(false)
-- 			tab.contents:Hide()
-- 			tab:Enable()
-- 		end
-- 	end
-- 	if self:IsSelected() then
-- 		self.contents:Show()
-- 		self:Disable()
-- 	else
-- 		self.contents:Hide()
-- 	end
-- end

-- function HS.TagsEditFocusLost(self)
-- 	local thing = {}
-- 	HS.ListToTable( self:GetText(), thing )
-- 	local oldTags = HS_settings.tags or {}
-- 	HS_settings.tags = {}
-- 	for i,tag in ipairs( thing ) do
-- 		if string.sub(tag,1,1) ~= "#" then -- if it does NOT start with #, add it
-- 			tag = "#"..tag
-- 		end
-- 		HS_settings.tags[tag] = oldTags[tag] or {}
-- 	end
-- end
-- function HS.TagsToEdit(self)
-- 	local tags = {}
-- 	for t in pairs( HS_settings.tags ) do table.insert( tags, t ) end
-- 	table.sort( tags )
-- 	self:SetText( table.concat( tags, "\n" ) )
-- end

-- function Rested.UIDropDownOnClick( self, cmd )
-- 	--print( "Rested.UIDropDownOnClick( "..cmd.." )" )
-- 	Rested.commandList[cmd].func()
-- end
-- function Rested.UIDropDownInitialize( self, level, menuList )
-- 	-- This is called when the drop down is initialized, when it needs to build the choice box
-- 	-- level and menuList are ignored here
-- 	-- based on Rested.dropDownMenuTable["Full"] = "full"
-- 	-- the Key is what to show, the value is what rested command to call
-- 	-- using Rested.commandList["full"] = {["func"] = function() end }
-- 	--local info = UIDropDownMenu_CreateInfo()
-- 	local sortedKeys, i = {}, 1
-- 	for text, _ in pairs( Rested.dropDownMenuTable ) do
-- 		sortedKeys[i] = text
-- 		i = i + 1
-- 	end
-- 	table.sort( sortedKeys, function( a, b ) return string.lower(a) < string.lower(b) end )
-- 	for _, text in ipairs( sortedKeys ) do
-- 		cmd = Rested.dropDownMenuTable[text]
-- 		info = UIDropDownMenu_CreateInfo()
-- 		info.text = text
-- 		info.notCheckable = true
-- 		info.arg1 = cmd
-- 		info.func = Rested.UIDropDownOnClick

-- 		UIDropDownMenu_AddButton( info, level )
-- 	end
-- end
-- function Rested.UIDropDownOnLoad( self )
-- 	UIDropDownMenu_Initialize( RestedUIFrame.DropDownMenu, Rested.UIDropDownInitialize ) -- displayMode, level, menuList
-- 	UIDropDownMenu_JustifyText( RestedUIFrame.DropDownMenu, "LEFT" )
-- end