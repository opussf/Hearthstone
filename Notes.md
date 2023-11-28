README.md


original
```
#showtooltip
/cleartarget
/bye
/played
/script P=UnitName("PET");if P then SendChatMessage("Come on Toto, er... "..P..", we are going home.","YELL");end
#hs
/use [mod:alt-shift] item:140192; [mod:alt] item:110560; item:6948
/rested auctions
```


/run local n=UnitName("target") or "player" if not InCombatLockdown() then EditMacro(GetMacroIndexByName("PI"),nil,nil,"#showtooltip\n/cast [@mouseover,help,nodead][@"..n.."] Power Infusion\n/cast Power Infusion\n/use 13") print("PI Updated to "..n) end




/run local id=0 while true do id = id+1 local itemID=C_ToyBox.GetToyFromIndex(id) if not itemID or id > 10 then break end print(select(2, C_ToyBox.GetToyInfo(itemID))) end


Brewfest Reveler's Hearthstone   item:166747
Greatfather Winter's Hearthstone item:162973




local function gatherAllToys()

    -- if we have already gathered all toys into allToys, leave
    if #allToys==C_ToyBox.GetNumTotalDisplayedToys() then
        return
    end

    wipe(allToys)

    local oldFilters -- becomes saved toy filters if non-default filters used

    if not C_ToyBoxInfo.IsUsingDefaultFilters() then
        oldFilters = {
            collected = C_ToyBox.GetCollectedShown(),
            uncollected = C_ToyBox.GetUncollectedShown(),
            unusable = C_ToyBox.GetUnusableShown(),
            sources = {},
            expansions = {}
        }
        for i=1,C_PetJournal.GetNumPetSources() do -- blizzard uses this for toys really
            if C_ToyBoxInfo.IsToySourceValid(i) then
                oldFilters.sources[i] = C_ToyBox.IsSourceTypeFilterChecked(i)
            end
        end
        for i=1,GetNumExpansions() do
            oldFilters.expansions[i] = C_ToyBox.IsExpansionTypeFilterChecked(i)
        end

        -- default filters show all toys (collected/uncollected, all sources/expansions)
        C_ToyBoxInfo.SetDefaultFilters()
    end

    -- anything in search is not counted towards default filters; clear just to be safe.
    -- this is only done a second after login where search should have nothing, but it's possible
    -- a user immediately opened the journal and typed something in
    C_ToyBox.SetFilterString("")

    -- now go through and capture the itemID of all toys; worry about data cache later
    for i=1,C_ToyBox.GetNumFilteredToys() do
        local itemID = C_ToyBox.GetToyFromIndex(i)
        if itemID then
            tinsert(allToys,itemID)
        end
    end

    -- if any non-default filters were used, restore them
    if oldFilters then
        C_ToyBox.SetCollectedShown(oldFilters.collected)
        C_ToyBox.SetUncollectedShown(oldFilters.uncollected)
        C_ToyBox.SetUnusableShown(oldFilters.unusable)
        for i=1,C_PetJournal.GetNumPetSources() do
            if C_ToyBoxInfo.IsToySourceValid(i) then
                C_ToyBox.SetSourceTypeFilter(i,oldFilters.sources[i])
            end
        end
        for i=1,GetNumExpansions() do
            C_ToyBox.SetExpansionTypeFilter(i,oldFilters.expansions[i])
        end
    end
end