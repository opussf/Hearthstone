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


ExportUtil.ConvertToBase64( dataEntries )

dataEntries = {
    { value,
      bitWidth
       }
}




dataEntries = {
    { value=0, bitWidth=3 }, -- index
    { value=11, bitWidth=8 }, -- count
    { value=166747, bitWidth=20 },
    { value=172179, bitWidth=20 },
    { value=162973, bitWidth=20 },
    { value=165802, bitWidth=20 },
    { value=165670, bitWidth=20 },
    { value=193588, bitWidth=20 },
    { value=64488, bitWidth=20 },
    { value=209035, bitWidth=20 },
    { value=212337, bitWidth=20 },
    { value=208704, bitWidth=20 },
    { value=236687, bitWidth=20 },
    { value=1, bitWidth=3 }, -- index
    { value=0, bitWidth=8 },
    { value=2, bitWidth=3 }, -- index
    { value=0, bitWidth=8 },
    { value=3, bitWidth=3 }, -- index
    { value=1, bitWidth=8 },
    { value=140192, bitWidth=20 },
    { value=4, bitWidth=3 }, -- index
    { value=0, bitWidth=8 },
    { value=5, bitWidth=3 }, -- index
    { value=0, bitWidth=8 },
    { value=6, bitWidth=3 }, -- index
    { value=1, bitWidth=8 },
    { value=230850, bitWidth=20 },
    { value=7, bitWidth=3 }, -- index
    { value=1, bitWidth=8 },
    { value=110560, bitWidth=20 },
}


di = ImportDataStreamMixin
di:Init( "string" )
di:ExtractValue( 3 )
di:ExtractValue( 8 )
di:ExtractValue( 20 )


bit = {}
function bit.lshift( x, by )
    return x * 2 ^ by
end
function bit.rshift( x, by )
    return math.floor( x / 2 ^ by )
end
function bit.bor( a, b )  -- bitwise or
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end
function bit.band( a, b ) -- bitwise and
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end
function bit.bnot( n )  -- bitwise not
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

ExportUtil = {};

BitsPerChar = 6;

function MakeBase64ConversionTable()
    local base64ConversionTable = {};
    base64ConversionTable[0] = 'A';
    for num = 1, 25 do
        table.insert(base64ConversionTable, string.char(65 + num));
    end

    for num = 0, 25 do
        table.insert(base64ConversionTable, string.char(97 + num));
    end

    for num = 0, 9 do
        table.insert(base64ConversionTable, tostring(num));
    end

    table.insert(base64ConversionTable, '+');
    table.insert(base64ConversionTable, '/');
    return base64ConversionTable;
end

NumberToBase64CharConversionTable = MakeBase64ConversionTable();
Base64CharToNumberConversionTable = tInvert(MakeBase64ConversionTable());


function ExportUtil.ConvertToBase64(dataEntries)
    local exportString = "";
    local currentValue = 0;
    local currentReservedBits = 0;
    local totalBits = 0;
    for i, dataEntry in ipairs(dataEntries) do
        local remainingValue = dataEntry.value;
        local remainingRequiredBits = dataEntry.bitWidth;
        -- TODO: bit.lshift doesnt work with > 32 bits.  Maybe use maxValue = 2^X instead?
        local maxValue = bit.lshift(1, remainingRequiredBits);
        if remainingValue >= maxValue then
            error(("Data entry has higher value than storable in bitWidth. (%d in %d bits)"):format(remainingValue, remainingRequiredBits));
            return "";
        end

        totalBits = totalBits + remainingRequiredBits;
        while remainingRequiredBits > 0 do
            local spaceInCurrentValue = (BitsPerChar - currentReservedBits);
            local maxStorableValue = bit.lshift(1, spaceInCurrentValue);
            local remainder = remainingValue % maxStorableValue;
            remainingValue = bit.rshift(remainingValue, spaceInCurrentValue);
            currentValue = currentValue + bit.lshift(remainder, currentReservedBits);

            if spaceInCurrentValue > remainingRequiredBits then
                currentReservedBits = (currentReservedBits + remainingRequiredBits) % BitsPerChar;
                remainingRequiredBits = 0;
            else
                exportString = exportString..NumberToBase64CharConversionTable[currentValue];
                currentValue = 0;
                currentReservedBits = 0;
                remainingRequiredBits = remainingRequiredBits - spaceInCurrentValue;
            end
        end
    end

    if currentReservedBits > 0 then
        exportString = exportString..NumberToBase64CharConversionTable[currentValue];
    end

    return exportString;
end
function ExportUtil.ConvertFromBase64(exportString)
    local dataValues = {};
    for i = 1, #exportString do
        table.insert(dataValues, Base64CharToNumberConversionTable[string.sub(exportString, i, i)]);
    end

    return dataValues;
end


ExportUtil.ConvertFromBase64( "YhtWUmEUpT+EVPUM5QhG6F03HWEmJueGgeZekzJAIAWAgOiQAKAOAhLceAg/aA" )


---
Link format:
|cFF00FF00|Hmyaddon:someData|h[MyAddon: Info]|h|r

Handle:
-- Save the original SetItemRef
local orig_SetItemRef = SetItemRef

function SetItemRef(link, text, button, chatFrame)
    local linkType, payload = link:match("^(%a+):(.+)$")
    if linkType == "myaddon" then
        -- Handle your custom link
        print("You clicked a MyAddon link! Payload:", payload)
        -- You can open a custom frame or show info here
        return
    end
    -- Call the original for all other links
    orig_SetItemRef(link, text, button, chatFrame)
end


Tooltip:
local function showTooltip(self, linkData)
    local linkType = string.split(":", linkData)
    if linkType == "myaddon" then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText("Your custom info here")
        GameTooltip:Show()
    end
end

local function hideTooltip()
    GameTooltip:Hide()
end

for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame"..i]
    if frame then
        frame:HookScript("OnHyperlinkEnter", showTooltip)
        frame:HookScript("OnHyperlinkLeave", hideTooltip)
    end
end








