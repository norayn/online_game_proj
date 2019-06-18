require "res_manager"

g_ResMgr = resource_manager()

g_MapOffsetX, g_MapOffsetY = 0, 0
g_MapScale = 1

g_MouseLbState = 0

g_CurOffset = { 0, 0 }

MODE_SUB_TEX = 0
MODE_GUI_CREATOR = 1
MODE_MAP_EDITOR = 2


local ModesCurParam = {}
ModesCurParam[ MODE_SUB_TEX ] = { OfX = 0, OfY = 0, Scl = 1 }
ModesCurParam[ MODE_GUI_CREATOR ] = { OfX = 0, OfY = 0, Scl = 1 }
ModesCurParam[ MODE_MAP_EDITOR ] = { OfX = 0, OfY = 0, Scl = 1 }


g_mode = MODE_SUB_TEX
g_ctrl_down = 0
g_alt_down = 0
g_shift_down = 0
g_Lmb_down = 0
g_Lmb_down_coord = { 0, 0 }


function LoadData()
	dofile( "data/config.cfg")
	if Config_DisableLinearFiltration == 1 then
		love.graphics.setDefaultFilter( 'nearest', 'nearest', 1 )
	end
	love.graphics.setBackgroundColor( 0, 60, 0 )
	
	SubTexLoadData()
	GuiLoadData()
	MapLoadData()

	Intefase = SubTexIntefase
	love.window.setTitle( "SubTexUtil" )
end



function DrawMain()
	love.graphics.setColor(255, 255, 255, 255)

	if g_mode == MODE_SUB_TEX then
		SubTexDraw()		
	elseif g_mode == MODE_GUI_CREATOR then
		GuiDraw()	
	elseif g_mode == MODE_MAP_EDITOR then
		MapDraw()
	end	

end


function GetTexCoordCur()
 	local CoordX, CoordY = love.mouse.getPosition()
	CoordX = math.floor( ( CoordX - g_MapOffsetX ) / g_MapScale )
	CoordY = math.floor( ( CoordY - g_MapOffsetY ) / g_MapScale )
	return CoordX, CoordY
end


function UpdateLogic()
	if MoveKeyIsPressed == 1 then
		local X, Y = love.mouse.getPosition()
		g_MapOffsetX, g_MapOffsetY = OffsetPresX + X - MovePresX, OffsetPresY + Y - MovePresY
	end

	if IntefaseMsg ~= nil then
		return
	end

	if g_mode == MODE_SUB_TEX then
		SubTexUpdateLogic()
	elseif g_mode == MODE_GUI_CREATOR then
		GuiUpdateLogic()
	elseif g_mode == MODE_MAP_EDITOR then
		MapUpdateLogic()
	end	
end


function ChangeMode()
	if g_mode == MODE_SUB_TEX then
		--g_mode = MODE_GUI_CREATOR
		--Intefase.Panel:SetVisible( false )
		--Intefase = GuiIntefase
		--Intefase.Panel:SetVisible( true )
		--
		--InterfaseRefreshGuiWindowsList()
		ModesCurParam[ MODE_SUB_TEX ].OfX = g_MapOffsetX
		ModesCurParam[ MODE_SUB_TEX ].OfY = g_MapOffsetY
		ModesCurParam[ MODE_SUB_TEX ].Scl = g_MapScale
		g_MapOffsetX = ModesCurParam[ MODE_MAP_EDITOR ].OfX
		g_MapOffsetY = ModesCurParam[ MODE_MAP_EDITOR ].OfY
		g_MapScale	 = ModesCurParam[ MODE_MAP_EDITOR ].Scl

		g_mode = MODE_MAP_EDITOR
		Intefase.Panel:SetVisible( false )
		Intefase = MapIntefase
		Intefase.Panel:SetVisible( true )
		love.window.setTitle( "MapEditor" )
		InterfaseRefreshMapObjList()
	else
		ModesCurParam[ MODE_MAP_EDITOR ].OfX = g_MapOffsetX
		ModesCurParam[ MODE_MAP_EDITOR ].OfY = g_MapOffsetY
		ModesCurParam[ MODE_MAP_EDITOR ].Scl = g_MapScale
		g_MapOffsetX = ModesCurParam[ MODE_SUB_TEX ].OfX
		g_MapOffsetY = ModesCurParam[ MODE_SUB_TEX ].OfY
		g_MapScale	 = ModesCurParam[ MODE_SUB_TEX ].Scl

		g_mode = MODE_SUB_TEX
		Intefase.Panel:SetVisible( false )
		Intefase = SubTexIntefase
		Intefase.Panel:SetVisible( true )
		love.window.setTitle( "SubTexUtil" )
	end
end


function MousePressed(x, y, button)
	if IsOnInterfase() ~= 1 then

		if button == "l" then
			g_Lmb_down = 1
			local X, Y = GetTexCoordCur()
			g_Lmb_down_coord = { X, Y }	

			if g_mode == MODE_SUB_TEX then
				GetRectCoord( 1 )
				SelectSubTex( g_NameOfSubTexUnderCursor )		
			elseif g_mode == MODE_GUI_CREATOR then
				if g_ctrl_down == 0 then
					GuiSelectWnd()
				end
			elseif g_mode == MODE_MAP_EDITOR then
				MapLmbAction()
			end			
		end
		
		if button == "m" then
			MoveKeyIsPressed = 1
			MovePresX, MovePresY = x, y
			OffsetPresX, OffsetPresY = g_MapOffsetX, g_MapOffsetY
		end

		if button == "wu" then
			local X, Y = love.mouse.getPosition()

			g_MapOffsetX = g_MapOffsetX - ( X - g_MapOffsetX )
			g_MapOffsetY = g_MapOffsetY - ( Y - g_MapOffsetY )
			g_MapScale = g_MapScale * 2

		end
		if button == "wd" then
			local X, Y = love.mouse.getPosition()

			g_MapOffsetX = (g_MapOffsetX-X)/2 + X
			g_MapOffsetY = (g_MapOffsetY-Y)/2 + Y

			g_MapScale = g_MapScale / 2
		end
	else	
		local HoverObject = loveframes.hoverobject
		if HoverObject and button == "r" and g_mode == MODE_GUI_CREATOR then
			if HoverObject.menu then
				HoverObject.menu:Remove()
				HoverObject.menu = nil
			end
			GuiShowMenu(x, y)
		end
	end

end


function MouseReleased(x, y, button)
	if button == "l" then
		GetRectCoord( 0 )
		g_Lmb_down = 0

		if g_mode == MODE_GUI_CREATOR and g_ctrl_down == 1 then
			GuiSaveNewWndPos()
		end

		if g_mode == MODE_GUI_CREATOR and g_alt_down == 1 then
			GuiSaveNewWndSize()
		end

		if g_mode == MODE_MAP_EDITOR and g_ctrl_down == 1 and g_alt_down ~= 1 then
			MapSaveNewObjPos()
		end

		if g_mode == MODE_MAP_EDITOR and g_alt_down == 1 and g_ctrl_down ~= 1 then
			MapSaveNewObjSize()
		end
	end

	if button == "m" then
		MoveKeyIsPressed = 0
	end
end


function KeyPressed(key, isrepeat)
	--Log( key )
	if key == "escape" then
		GuiSaveData()
		love.event.quit()
	end
	
	if key == "tab" then		
		ChangeMode()
	end
	
	if key == "lctrl" then		
		g_ctrl_down = 1		
	end
	
	if key == "lalt" then	
		g_alt_down = 1
	end
	
	if key == "lshift" then	
		g_shift_down = 1
	end		

	if key == "return" then			
		if g_mode == MODE_GUI_CREATOR and IsOnGuiInterfase() then
			GuiSaveSelected()
		end
		if g_mode == MODE_SUB_TEX and IsOnInterfase() then
			SaveSelected()
		end
		if g_mode == MODE_MAP_EDITOR and IsOnMapInterfase() then
			MapSaveSelected()
		end
	end

	if key == "delete" then
		if g_mode == MODE_MAP_EDITOR then
			MapDelSelected()
		end
	end

	if key == "f5" then			
		GuiSaveData()
	end

	if key == "f7" then			
		ExportAllWindows()
	end

	if key == "f8" then			
		MapSave()
	end

	if key == "f9" then			
		MapLoad()
	end

	if key == "f1" then			
		g_CurOffset[ 1 ], g_CurOffset[ 2 ] = GetTexCoordCur()
	end

	if key == "c" and g_ctrl_down == 1 then			
		if g_mode == MODE_MAP_EDITOR then
			MapCopySelected()
		end		
	end

	if key == "v" and g_ctrl_down == 1 then			
		if g_mode == MODE_MAP_EDITOR then
			MapPasteToSelected()
		end		
	end

end


function KeyReleased(key, isrepeat)

	if key == "lctrl" then		
		g_ctrl_down = 0		
	end
	
	if key == "lalt" then	
		g_alt_down = 0
	end
	
	if key == "lshift" then	
		g_shift_down = 0
	end	
end