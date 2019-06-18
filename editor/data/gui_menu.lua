GuiMenu = {}

function GuiShowMenu(x, y)

	local SubMenuOpen = loveframes.Create("menu")
	SubMenuOpen:AddOption("Open " .. Config_GuiWindows[ 1 ].Name, false, function() GuiLoadConfig( 1 ) end)
	SubMenuOpen:AddOption("Open " .. Config_GuiWindows[ 2 ].Name, false, function() GuiLoadConfig( 2 ) end)

	local Menu = loveframes.Create("menu")
	Menu:AddOption("Save(f5)", false, function() GuiSaveData() end)
	Menu:AddOption("Export(f7)", false, function() ExportAllWindows() end)
	--Menu:AddOption("Export open_mail", false, function()	ExportAllWindows( { BaseFile = Config_GuiWindows[ 2 ].Patch } ) end)
	if GuiGetCurrentWndConfigIndex() > 0 then
		Menu:AddOption("Export " .. Config_GuiWindows[ GuiGetCurrentWndConfigIndex() ].Name, false, function()	ExportAllWindows( { BaseFile = Config_GuiWindows[ GuiGetCurrentWndConfigIndex() ].Patch } ) end)
	end
	Menu:AddDivider()
	Menu:AddSubMenu("Open...", false, SubMenuOpen )
	Menu:AddOption("Open last session as current", false, function() GuiLoadConfig() end)

	Menu:AddDivider()
	Menu:AddOption("test", false, function()
		Log( TexNameToGamePatch( "resources/post_merge_1.tga" ) )
	end)
	Menu:SetPos(x, y)
	loveframes.hoverobject.menu = Menu	
end