HS_SLUG, HS      = ...
HS.commandList["config"] = {
	["func"] = function() HSConfig:Show() end,
	["help"] = {"", "Config"}
}

function HS.MakeTabActive( self )
	local tabsParent = self:GetParent()
	local tabs = {tabsParent:GetChildren()}
	for _, tab in pairs(tabs) do
		local parentKey = tab:GetParentKey()
		if self ~= tab and (parentKey == "tab1" or parentKey == "tab2" or parentKey == "tab3" ) then
			tab:SetSelected(false)
			tab.contents:Hide()
			tab:Enable()
		end
	end
	if self:IsSelected() then
		self.contents:Show()
		self:Disable()
	else
		self.contents:Hide()
	end
end

function HS.TagsEditFocusLost(self)
	local thing = {}
	HS.ListToTable( self:GetText(), thing )
	local oldTags = HS_settings.tags or {}
	HS_settings.tags = {}
	for i,tag in ipairs( thing ) do
		if string.sub(tag,1,1) ~= "#" then -- if it does NOT start with #, add it
			tag = "#"..tag
		end
		HS_settings.tags[tag] = oldTags[tag] or {}
	end
end
function HS.TagsToEdit(self)
	local tags = {}
	for t in pairs( HS_settings.tags ) do table.insert( tags, t ) end
	table.sort( tags )
	self:SetText( table.concat( tags, "\n" ) )
end

