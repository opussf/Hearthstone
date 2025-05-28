HS_SLUG, HS      = ...
HS.commandList["config"] = {
	["func"] = function() HSThingy:Show() end,
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