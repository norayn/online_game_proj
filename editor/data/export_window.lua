local tab, tab2, tab2 = "\t", "\t\t", "\t\t\t"



local ExportFileDefault = "data/working_folder/ExWnd.lua"
local ImportFileDefault = "data/working_folder/InWnd.lua"

local ExpFile, err = {}, {}

function ExportAllWindows( Data )
	
	local ExportFile = ExportFileDefault
	local ImportFile = ImportFileDefault

	if Data ~= nil then 
		ImportFile = Data.BaseFile
		if Data.ExportFile == nil then
			ExportFile = ImportFile
		else
			ExportFile = Data.ExportFile
		end
	end
	Log( ImportFile )
	Log( ExportFile )

	local StartGuiInd, EndGuiInd, GuiData = 0, 0, {}
	local Ind, Str = 0, ""
	
	for Str in cr_file_lines( string.gsub( ImportFile, '/', '\\' ) ) do
		Ind = Ind + 1
		GuiData[ Ind ] = Str
		if string.find( Str, "--//MARK GUI BEGIN//" ) then StartGuiInd = Ind end
		if string.find( Str, "--//MARK GUI END//" ) then EndGuiInd = Ind end
	end	

	local WndTree = {}
	GuiGetRootWnd():GetChildsTree( WndTree, 0 ) 

	ExpFile,err = io.open( string.gsub( ExportFile, '/', '\\' ),"w"  )

	for I = 1, StartGuiInd do
		WrLine( GuiData[ I ] )
	end

	for I = 1, #WndTree do
		local Wnd = WndTree[ I ][ 1 ]
		
		if Wnd.Type == GUI_TYPE_WINDOW then
			ExportWindow( Wnd )
		elseif Wnd.Type == GUI_TYPE_SPRITE then
			ExportSprite( Wnd )
		elseif Wnd.Type == GUI_TYPE_BUTTON then
			ExportButton( Wnd )
		elseif Wnd.Type == GUI_TYPE_TEXT then
			ExportText( Wnd )
		end
	end

	for I = EndGuiInd, #GuiData do
		WrLine( GuiData[ I ] )
	end

	ExpFile:close()
end


function WrLine( text )
	ExpFile:write( text .. "\n" )	
end


function GetXY( Var )
	return 	"{ " .. Var[ 1 ] .. ", " .. Var[ 2 ] .. " }"
end


function GetVec4( Var )
	return 	"{ " .. Var[ 1 ] .. ", " .. Var[ 2 ] .. ", " .. Var[ 3 ] .. ", " .. Var[ 4 ] .. " }"
end


function GetRGBA( Var )
	return 	GetVec4( Var )
end


function TexNameToGamePatch( Name )
	local NoNeed = string.len( "resources/" )
	local TexName = string.sub( Name, NoNeed + 1, -5 )
	for I = 1, #Config_TexFiles do		
		if TexName == Config_TexFiles[ I ] then			
			local S,E = string.find( Config_TexFilesFulPath[ I ], "gui" )
			return string.sub( Config_TexFilesFulPath[ I ], S )			
		end
	end
	return "no game tex " .. Name
end

function ExportWindow( Wnd )
	WrLine( tab .. Wnd.Name .. " = CreateWindow( nil, {" )
	WrLine( tab2 .. "Pos" .. tab .. "= " .. GetXY( Wnd.Pos ) .. "," )
	WrLine( tab2 .. "Size" .. tab .. "= " .. GetXY( Wnd.Size ) .. "," )
	if Wnd.TexName ~= "" then
		WrLine( tab2 .. "Texture" .. tab .. "= " .. '"' .. TexNameToGamePatch( Wnd.TexName ) .. '"' .. "," )
		WrLine( tab2 .. "SubTex" .. tab .. "= " .. '"' .. Wnd.SubTexName .. '"' .. "," )
	end
	WrLine( tab .. "})" )
	WrLine( tab )					
end


function ExportSprite( Wnd )
	local RootWnd = GuiGetRootWnd()
	local ParentWndName = RootWnd.Name
	WrLine( tab .. ParentWndName .. "." .. Wnd.Name .. " = Window:CreateSprite( " .. RootWnd.Name .. ", {" )
	WrLine( tab2 .. "Pos" .. tab .. "= " .. GetXY( Wnd.Pos ) .. "," )
	WrLine( tab2 .. "Size" .. tab .. "= " .. GetXY( Wnd.Size ) .. "," )
	WrLine( tab2 .. "Texture" .. tab .. "= " .. '"' .. TexNameToGamePatch( Wnd.TexName ) .. '"' .. "," )
	WrLine( tab2 .. "SubTex" .. tab .. "= " .. '"' .. Wnd.SubTexName .. '"' .. "," )
	WrLine( tab .. "})" )
	WrLine( tab )							
end


function ExportButton( Wnd )
	local RootWnd = GuiGetRootWnd()
	local ParentWndName = RootWnd.Name
	local Tex = '"' .. TexNameToGamePatch( Wnd.TexName ) .. '"'
	local BtnSt = { "up", "select", "down", "disable" }
	local BtnTexName = ""
	for I = 1, #BtnSt do
		if string.sub( Wnd.SubTexName, -string.len( BtnSt[ I ] ) ) == BtnSt[ I ] then
			BtnTexName = string.sub( Wnd.SubTexName, 1, string.len( Wnd.SubTexName ) - string.len( BtnSt[ I ] ) )
		end
	end
	WrLine( tab .. ParentWndName .. "." .. Wnd.Name .. " = Window:CreateButton({" )
	WrLine( tab2 .. "Pos" .. tab .. "= " .. GetXY( Wnd.Pos ) .. "," )
	WrLine( tab2 .. "Size" .. tab .. "= " .. GetXY( Wnd.Size ) .. "," )
	WrLine( tab2 .. "Texture" .. tab .. "= { " .. Tex .. "," )
	WrLine( tab2 .. tab2 .. Tex .. "," )
	WrLine( tab2 .. tab2 .. Tex .. "," )
	WrLine( tab2 .. tab2 .. Tex .. " }," )
	WrLine( tab2 .. "SubTex" .. tab .. "= { " .. '"' .. BtnTexName .. BtnSt[ 1 ] .. '"' .. "," )
	WrLine( tab2 .. tab2 .. '"' .. BtnTexName .. BtnSt[ 2 ] .. '"' .. "," )
	WrLine( tab2 .. tab2 .. '"' .. BtnTexName .. BtnSt[ 3 ] .. '"' .. "," )
	WrLine( tab2 .. tab2 .. '"' .. BtnTexName .. BtnSt[ 4 ] .. '"' .. " }," )
	WrLine( tab .. "})" )
	WrLine( tab )							
end


function ExportText( Wnd )
	local RootWnd = GuiGetRootWnd()
	local ParentWndName = RootWnd.Name
	WrLine( tab .. ParentWndName .. "." .. Wnd.Name .. " = Window:CreateText( " .. RootWnd.Name .. ", {" )
	WrLine( tab2 .. "Pos" .. tab .. "= " .. GetXY( Wnd.Pos ) .. "," )
	if Wnd.TextAlign ~= 0 then
		WrLine( tab2 .. "TextAlign" .. tab .. "= " .. Wnd.TextAlign .. "," )
		WrLine( tab2 .. "TextWidth" .. tab .. "= " .. Wnd.Size[ 1 ] .. "," )
	end
	WrLine( tab2 .. "TextFont" .. tab .. "= " .. '"' .. Wnd.TextFont .. '"' .. "," )
	WrLine( tab2 .. "Text" .. tab .. "= " .. '"' .. Wnd.Text .. '"' .. "," )
	WrLine( tab2 .. "TextColor" .. tab .. "= " .. GetRGBA( Wnd.TextColor ) .. "," )
	WrLine( tab .. "})" )
	WrLine( tab )							
end