local CurrentPatch = ""

g_CurrentSubTexFileIndex = 1
g_NameOfSubTexUnderCursor = ""
g_NameOfSelectedSubTex = ""

RECT_MODE_OFF = 0
RECT_MODE_ON = 1
RECT_MODE_FIRST_POINT_SET = 2
RECT_MODE_SECOND_POINT_SET = 3

local ModeGetRect = RECT_MODE_OFF
local NewRect = { 0, 0, 0, 0 }


function LoadTexFileByIndex( Index )
	--if Intefase.ListSubTex ~= nil then
	--	SaveAll()
	--end

	g_CurrentSubTexFileIndex = Index
	CurrentPatch = Config_TexFiles[ Index ]
	
	dofile( "data/resources/" .. CurrentPatch .. ".tex" )

	TexImage = love.graphics.newImage( "resources/" .. CurrentPatch .. ".tga")
	
	if Intefase.ListSubTex ~= nil then		
		InterfaseRefreshSubTexList()
	end
	g_NameOfSelectedSubTex = ""
end


function SubTexLoadData()
	--for I = 1, #Config_TexFiles do
	--	local Param = Config_TexFilesFulPath[ I ] .. ".tex " .. Config_ResourcePath .. "/" .. Config_TexFiles[ I ] .. ".tex"
	--	os.copyFile( Param )
	--	Param = Config_TexFilesFulPath[ I ] .. ".tga " .. Config_ResourcePath .. "/" .. Config_TexFiles[ I ] .. ".tga"
	--	os.copyFile( Param )
	--end

	LoadTexFileByIndex( 1 )
end


function SaveAll()


	local FileName = "data/resources/" .. CurrentPatch .. ".tex"
	--local FileName = "data/resources/newtex.tex"
	local LogFile,err = io.open( string.gsub( FileName, '/', '\\' ),"w"  )

	LogFile:write( "SubTex = {" .. "\n" )
	for k, v in pairsByKeys( SubTex ) do
		LogFile:write( "\t" .. k .. "\t\t\t\t\t\t\t\t" .. "= { Coord = { " .. v.Coord[ 1 ] .. ", " .. v.Coord[ 2 ] .. ", " .. v.Coord[ 3 ] .. ", " .. v.Coord[ 4 ] .. " } }," .. "\n" )
	end
	LogFile:write( "}" .. "\n" )

	LogFile:close()

	Param = Config_ResourcePath .. "/" .. Config_TexFiles[ g_CurrentSubTexFileIndex ] .. ".tex " .. Config_TexFilesFulPath[ g_CurrentSubTexFileIndex ] .. ".tex"
	os.copyFile( Param )
end


function SubTexDraw()
	if Config_ReplaceAlphaColor then 
		love.graphics.setBlendMode( "replace" ) 
	end

	love.graphics.draw( TexImage, g_MapOffsetX, g_MapOffsetY, 0, g_MapScale, g_MapScale)
	love.graphics.setBlendMode( "alpha" )

	if g_NameOfSubTexUnderCursor ~= "" then
		DrawRectOnTex( g_NameOfSubTexUnderCursor )
	end

	love.graphics.setColor(0, 255, 0, 255)
	if g_NameOfSelectedSubTex ~= "" then
		DrawRectOnTex( g_NameOfSelectedSubTex )
	end

	love.graphics.setColor(0, 0, 255, 255)
	if ModeGetRect == RECT_MODE_FIRST_POINT_SET then
		local X = NewRect[ 1 ] * g_MapScale
		local Y = NewRect[ 2 ] * g_MapScale
		local W = NewRect[ 3 ] * g_MapScale
		local H = NewRect[ 4 ] * g_MapScale
		love.graphics.rectangle( "line", X + g_MapOffsetX, Y + g_MapOffsetY, W, H )
	end
end


function SelectSubTex( Name )
	if IntefaseMsg ~= nil or ModeGetRect ~= RECT_MODE_OFF then
		return
	end

	if Name == "" then
		g_NameOfSelectedSubTex = ""
		return
	end

	local CoordX, CoordY = GetTexCoordCur()
	g_NameOfSelectedSubTex = Name
	Intefase.NumberboxX:SetValue( SubTex[ g_NameOfSelectedSubTex ].Coord[ 1 ] )
	Intefase.NumberboxY:SetValue( SubTex[ g_NameOfSelectedSubTex ].Coord[ 2 ] )
	Intefase.NumberboxW:SetValue( SubTex[ g_NameOfSelectedSubTex ].Coord[ 3 ] )
	Intefase.NumberboxH:SetValue( SubTex[ g_NameOfSelectedSubTex ].Coord[ 4 ] )
	Intefase.TextInputSelectedSubTexName:SetText( g_NameOfSelectedSubTex )
end


function GetRectCoord( MouseStateL )
	g_MouseLbState = MouseStateL

	if ModeGetRect == RECT_MODE_OFF then
		return
	end

	if ModeGetRect == RECT_MODE_ON and g_MouseLbState == 1 then
		ModeGetRect = RECT_MODE_FIRST_POINT_SET
		local CoordX, CoordY = GetTexCoordCur()
		NewRect[ 1 ] = CoordX
		NewRect[ 2 ] = CoordY
		Intefase.NumberboxX:SetValue( CoordX )
		Intefase.NumberboxY:SetValue( CoordY )
		return
	end

	if ModeGetRect == RECT_MODE_FIRST_POINT_SET and g_MouseLbState == 0 then
		local CoordX, CoordY = GetTexCoordCur()
		NewRect[ 3 ] = CoordX - NewRect[ 1 ]
		NewRect[ 4 ] = CoordY - NewRect[ 2 ]
		Intefase.NumberboxW:SetValue( NewRect[ 3 ] )
		Intefase.NumberboxH:SetValue( NewRect[ 4 ] )

		ModeGetRect = RECT_MODE_OFF
		return
	end

end


function DrawRectOnTex( SubTexName )
	local X = ( SubTex[ SubTexName ].Coord[ 1 ] ) * g_MapScale
	local Y = ( SubTex[ SubTexName ].Coord[ 2 ] ) * g_MapScale
	local W = SubTex[ SubTexName ].Coord[ 3 ] * g_MapScale
	local H = SubTex[ SubTexName ].Coord[ 4 ] * g_MapScale
	love.graphics.rectangle( "line", X + g_MapOffsetX, Y + g_MapOffsetY, W, H )
end


function SubTexUpdateLogic()

	local CoordX, CoordY = GetTexCoordCur()
	Intefase.TexCurPos:SetText( "x:" .. CoordX .. " y:" .. CoordY .. " || Offset x: " .. CoordX - g_CurOffset[ 1 ] .. " y: " .. CoordY - g_CurOffset[ 2 ] )

	if ModeGetRect ~= RECT_MODE_OFF then
		if ModeGetRect == RECT_MODE_FIRST_POINT_SET then
			local CoordX, CoordY = GetTexCoordCur()
			NewRect[ 3 ] = CoordX - NewRect[ 1 ]
			NewRect[ 4 ] = CoordY - NewRect[ 2 ]
			Intefase.NumberboxW:SetValue( NewRect[ 3 ] )
			Intefase.NumberboxH:SetValue( NewRect[ 4 ] )
			return
		end
		return
	end

	g_NameOfSubTexUnderCursor = ""
	for k, v in pairs( SubTex ) do
	    if CoordX >= v.Coord[ 1 ] and CoordX < v.Coord[ 1 ] + v.Coord[ 3 ] and CoordY >= v.Coord[ 2 ] and CoordY < v.Coord[ 2 ] + v.Coord[ 4 ] then
			Intefase.Label1:SetText( "SubTex: " .. k )
			local X, Y, W, H = v.Coord[ 1 ], v.Coord[ 2 ], v.Coord[ 3 ], v.Coord[ 4 ]
			Intefase.Label2:SetText( "X:" .. X .. " Y:" .. Y .. " W:" .. W .. "(" .. X + W .. ") H:" .. H .. "(" .. Y + H .. ")" )
			g_NameOfSubTexUnderCursor = k
			break
		end
	end

end











function GetRect()
	ModeGetRect = RECT_MODE_ON
	g_NameOfSelectedSubTex = ""
	--Intefase.TextInputSelectedSubTexName:SetText( "" )
end


function SaveSelected()
	if g_NameOfSelectedSubTex == "" or SubTex[ g_NameOfSelectedSubTex ] == nil then
		InterfaseShowMsg( "no obj to save" )
		return
	end

	SubTex[ g_NameOfSelectedSubTex ].Coord[ 1 ] = Intefase.NumberboxX:GetValue()
	SubTex[ g_NameOfSelectedSubTex ].Coord[ 2 ] = Intefase.NumberboxY:GetValue()
	SubTex[ g_NameOfSelectedSubTex ].Coord[ 3 ] = Intefase.NumberboxW:GetValue()
	SubTex[ g_NameOfSelectedSubTex ].Coord[ 4 ] = Intefase.NumberboxH:GetValue()

	local SubTexName = Intefase.TextInputSelectedSubTexName:GetText()
	Log( SubTexName )
	if SubTexName ~= "" and SubTex[ SubTexName ] == nil then
		AddToList()
		DelSelected()
		SelectSubTex( SubTexName )
	end
end


function DelSelected()
	if g_NameOfSelectedSubTex == "" or SubTex[ g_NameOfSelectedSubTex ] == nil then
		InterfaseShowMsg( "no obj to del" )
		return
	end

	SubTex[ g_NameOfSelectedSubTex ] = nil
	g_NameOfSelectedSubTex = ""
	Intefase.TextInputSelectedSubTexName:SetText( "" )

	InterfaseRefreshSubTexList()
end


function AddToList()
	local SubTexName = Intefase.TextInputSelectedSubTexName:GetText()
	if SubTexName == "" or SubTex[ SubTexName ] ~= nil then
		InterfaseShowMsg( "SubTex already in the list" )
		return
	end
	local X, Y, W, H
	X = Intefase.NumberboxX:GetValue()
	Y = Intefase.NumberboxY:GetValue()
	W = Intefase.NumberboxW:GetValue()
	H = Intefase.NumberboxH:GetValue()

	if W == 0 or H == 0 then
		InterfaseShowMsg( "width or height = 0" )
		return
	end

	SubTex[ SubTexName ] = {}
	SubTex[ SubTexName ].Coord = {}

	SubTex[ SubTexName ].Coord[ 1 ] = X
	SubTex[ SubTexName ].Coord[ 2 ] = Y
	SubTex[ SubTexName ].Coord[ 3 ] = W
	SubTex[ SubTexName ].Coord[ 4 ] = H

	InterfaseRefreshSubTexList()
end

