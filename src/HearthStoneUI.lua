HS_SLUG, HS      = ...
HS.commandList["config"] = {
	["func"] = function() HSConfig:Show() end,
	["help"] = {"", "Config"}
}

function HS.UIInit()
	HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
	HS.ModifierDropDownBuild( HSConfig_ModifierDropDownMenu )
end



function HS.TagDropDownBuild( self )
	print( "TagDropDownOnShow" )
	print( self )
	for k,v in pairs(self) do
		print(k,v)
	end
	UIDropDownMenu_Initialize( self, HS.TagDropDownPopulate )
	UIDropDownMenu_JustifyText( self, "LEFT" )
end
function HS.TagDropDownPopulate( self, level, menuList )
	print( self, level, menuList )
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
end
function HS.SetTagForEdit( info )
	-- takes the info table
	print( "SetTagForEdit" )
	print( info )
	for k,v in pairs( info ) do
		print(k,v)
	end
	print( "SetTagForEdit( "..info.value.." )" )
	-- UIDropDownMenu_SetText( )
	HS.editTag = info.value
	UIDropDownMenu_SetText( HSConfig_TagDropDownMenu, info.value )
	HSConfig_TagEditBox:SetText( info.value )
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
end
function HS.SetModForEdit( info )
	print( "SetModForEdit" )
	print( info )
	for k,v in pairs( info ) do
		print(k,v)
	end
	print( "SetModForEdit( "..info.value.." )" )
	-- UIDropDownMenu_SetText( )
	UIDropDownMenu_SetText( HSConfig_ModifierDropDownMenu, info.value )
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
	end
	print( HS.editTag )

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