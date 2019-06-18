require( "window_base_class" )
require( "export_window" )

g_GuiShowRect = true

local Gui = {
	RootWindow = nil,
	Textures = {},
	WindowUnderCursor = nil,
	SelectedWindow = nil,
	WndTree = {},
	CurrentWndConfigIndex = 0
}


function GuiSaveData()
	Log( "Save session" )

	local WndTree = {}
	local RootW = GuiGetRootWnd()
	RootW:GetChildsTree( WndTree, 0 )

	for k, v in pairs( WndTree ) do		
		v[ 1 ].EditorQuad = nil
		v[ 1 ].Parent = nil
	end

	if Gui.CurrentWndConfigIndex == 0 then
		table.save( RootW, "data/working_folder/last_sesson.save" )
	else
		local WndName = Config_GuiWindows[ Gui.CurrentWndConfigIndex ].Name	
		WndName = "data/working_folder/" .. WndName .. ".save"	
		table.save( RootW, WndName ) 
	end

	--Log( Gui.RootWindow )

	RootW:SetMetatablesForChild()
	RootW:SetParentsForChild()
end


function GuiLoadData()
	--Gui.RootWindow = table.read( "data/working_folder/last_sesson.save" ) 
	
	if Gui.RootWindow == nil then
			Log( "No load sessin" )
		Gui.RootWindow = window_base( GUI_TYPE_WINDOW )
		Gui.RootWindow.Size = { 200, 200 }
		Gui.RootWindow.Name = "Window"
	else
		local dd = window_base( GUI_TYPE_WINDOW )
		setmetatable( Gui.RootWindow, getmetatable( dd ) )
		Gui.RootWindow:SetMetatablesForChild()
		Gui.RootWindow:SetParentsForChild()
	end
end


function GuiLoadConfig( ConfigIndex )
	Gui.RootWindow = nil

	if ConfigIndex ~= nil then
		Gui.CurrentWndConfigIndex = ConfigIndex
		local WndName = Config_GuiWindows[ ConfigIndex ].Name
		Gui.RootWindow = table.read( "data/working_folder/" .. WndName .. ".save" ) 
		love.window.setTitle( "SubTexUtil - " .. WndName )
	else
		Gui.RootWindow = table.read( "data/working_folder/last_sesson.save" ) 
	end

	if Gui.RootWindow == nil then
			Log( "No load sessin" )
		Gui.RootWindow = window_base( GUI_TYPE_WINDOW )
		Gui.RootWindow.Size = { 200, 200 }
		Gui.RootWindow.Name = "Window"
	else
		local dd = window_base( GUI_TYPE_WINDOW )
		setmetatable( Gui.RootWindow, getmetatable( dd ) )
		Gui.RootWindow:SetMetatablesForChild()
		Gui.RootWindow:SetParentsForChild()
	end
	--SubMenuOpen:AddOption("Open " .. Config_GuiWindows[ 1 ].Name, false, function() GuiLoadConfig( 1 ) end)
end


function GuiDraw()	
	local WndTree = Gui.WndTree
	if #WndTree == 0 then return end
	
	for I = 1, # WndTree do
		local Wnd = WndTree[ I ][ 1 ]
		if Wnd.EditorVisible ~= 0 then
			local X = Wnd.Pos[ 1 ] * g_MapScale
			local Y = Wnd.Pos[ 2 ] * g_MapScale
			local W = Wnd.Size[ 1 ] * g_MapScale
			local H = Wnd.Size[ 2 ] * g_MapScale
			
			if Wnd == Gui.SelectedWindow then
				love.graphics.setColor( 0, 255, 0, 255 )
				if g_ctrl_down == 1 and g_Lmb_down == 1 then
					local CX, CY = GetTexCoordCur()
					X = ( Wnd.Pos[ 1 ] + CX - g_Lmb_down_coord[ 1 ] ) * g_MapScale
					Y = ( Wnd.Pos[ 2 ] + CY - g_Lmb_down_coord[ 2 ] ) * g_MapScale
				end
				if g_alt_down == 1 and g_Lmb_down == 1 then
					local CX, CY = GetTexCoordCur()
					--Log( "g_alt_down " .. CX - g_Lmb_down_coord[ 1 ] .. "  " .. CY - g_Lmb_down_coord[ 2 ] )
					W = ( Wnd.Size[ 1 ] + CX - g_Lmb_down_coord[ 1 ] ) * g_MapScale
					H = ( Wnd.Size[ 2 ] + CY - g_Lmb_down_coord[ 2 ] ) * g_MapScale
				end
			else
				love.graphics.setColor( 255, 255, 255, 255 )
			end

			if g_GuiShowRect then
				love.graphics.rectangle( "line", X + g_MapOffsetX, Y + g_MapOffsetY, W, H )
			end

			if Wnd.TexName ~= "" then --DRAW texture
				if Wnd.EditorQuad == nil then
					local Tex = g_ResMgr:GetImage( Wnd.TexName )	
					Wnd.EditorQuad = g_ResMgr:GethQuad( Tex, Wnd.TexRect )					
				end
				
				love.graphics.setColor( 255, 255, 255, 255 )
				local Tex = g_ResMgr:GetImage( Wnd.TexName )
				local StSlX, StSlY = Wnd.Size[ 1 ] / Wnd.TexRect[ 3 ] * g_MapScale, Wnd.Size[ 2 ] / Wnd.TexRect[ 4 ] * g_MapScale			
				love.graphics.draw( Tex, Wnd.EditorQuad, X + g_MapOffsetX, Y + g_MapOffsetY, 0, StSlX , StSlY )
			end

			if Wnd.Text ~= "" then --DRAW text				
				local AlignOffsetX = 0
				if Wnd.TextAlign ~= 0 then
					if Wnd.TextAlign == 1 then
						AlignOffsetX = W - love.graphics.getFont():getWidth( Wnd.Text )
					end
					if Wnd.TextAlign == 2 then
						AlignOffsetX = W / 2 - ( love.graphics.getFont():getWidth( Wnd.Text ) / 2 )
					end
				end
				love.graphics.setColor( Wnd.TextColor )
				love.graphics.print( Wnd.Text , X + g_MapOffsetX + AlignOffsetX, Y + g_MapOffsetY )
			end
		end
	end
end


function GuiUpdateLogic()
	Gui.WndTree = {}
	Gui.RootWindow:GetChildsTree( Gui.WndTree, 0 )

	local WndTree = Gui.WndTree 
	local CoordX, CoordY = GetTexCoordCur()
	Intefase.TexCurPos:SetText( "x:" .. CoordX .. " y:" .. CoordY .. " || Offset x: " .. CoordX - g_CurOffset[ 1 ] .. " y: " .. CoordY - g_CurOffset[ 2 ] )

	Gui.WindowUnderCursor = nil

	for I = 1, #WndTree do
		local Wnd = WndTree[ I ][ 1 ]
		if Wnd:InWindow( CoordX, CoordY ) then
			Gui.WindowUnderCursor = Wnd
		end
	end
	
	if Gui.WindowUnderCursor == nil then
		Intefase.Label2:SetText( "^_^" )
		Intefase.Label1:SetText( "^_^" )
	else
		local X, Y, W, H = Gui.WindowUnderCursor.Pos[ 1 ], Gui.WindowUnderCursor.Pos[ 2 ],
			Gui.WindowUnderCursor.Size[ 1 ], Gui.WindowUnderCursor.Size[ 2 ]
		Intefase.Label2:SetText( "X:" .. X .. " Y:" .. Y .. " W:" .. W .. "(" .. X + W .. ") H:" .. H .. "(" .. Y + H .. ")" )
		Intefase.Label1:SetText( Gui.WindowUnderCursor.Name )
	end
end


function GuiSelectWnd( SelectedWindow )
	if SelectedWindow == nil then
		Gui.SelectedWindow = Gui.WindowUnderCursor	
	else
		Gui.SelectedWindow = SelectedWindow
	end

	local Wnd = Gui.SelectedWindow
	InterfaseRefreshGuiWindowsList( Gui.SelectedWindow )
	
	local Name, x, y, w, h = "", 0, 0, 0, 0
	if Wnd ~= nil then
		Name = Wnd.Name
		x = Wnd.Pos[ 1 ]
		y = Wnd.Pos[ 2 ]
		w = Wnd.Size[ 1 ]
		h = Wnd.Size[ 2 ]
	end

	Intefase.TextInputSelectedWndName:SetText( Name )
	Intefase.NumberboxX:SetValue( x )
	Intefase.NumberboxY:SetValue( y )
	Intefase.NumberboxW:SetValue( w )
	Intefase.NumberboxH:SetValue( h )

	--properties panel
	if Wnd ~= nil then
		if Wnd.Type == GUI_TYPE_TEXT then
			GuiSetPropertiesClass( GUI_TYPE_TEXT )
			Intefase.TextPropertiesText:SetText( Wnd.Text )
			
			if Wnd.TextAlign == 0 then Intefase.RadiobuttonPropertiesTextAlign1:SetChecked( true ) end
			if Wnd.TextAlign == 1 then Intefase.RadiobuttonPropertiesTextAlign2:SetChecked( true ) end
			if Wnd.TextAlign == 2 then Intefase.RadiobuttonPropertiesTextAlign3:SetChecked( true ) end

			Intefase.MultichoiceTextFont:SetChoice( Wnd.TextFont )

			Intefase.TextColorR:SetText( Wnd.TextColor[ 1 ] )
			Intefase.TextColorG:SetText( Wnd.TextColor[ 2 ] )
			Intefase.TextColorB:SetText( Wnd.TextColor[ 3 ] )
			Intefase.TextColorA:SetText( Wnd.TextColor[ 4 ] )
		else
			GuiSetPropertiesClass( GUI_TYPE_NONE )
		end
	else
		GuiSetPropertiesClass( GUI_TYPE_NONE )
	end
end


function GuiGetCurrentWndConfigIndex()
	return Gui.CurrentWndConfigIndex
end


function GuiGetRootWnd()
	return Gui.RootWindow
end


function GuiSaveNewWndPos()
	if Gui.SelectedWindow ~= nil then
		local CX, CY = GetTexCoordCur()
		local OfX = CX - g_Lmb_down_coord[ 1 ]
		local OfY = CY - g_Lmb_down_coord[ 2 ]
		GuiOffsetWndWithChilds( Gui.SelectedWindow, OfX, OfY )
	end
	GuiSelectWnd( Gui.SelectedWindow )
end


function GuiSaveSelected()
	if Gui.SelectedWindow ~= nil then
		local Wnd = Gui.SelectedWindow

		local X = Intefase.NumberboxX:GetValue() - Wnd.Pos[ 1 ]
		local Y = Intefase.NumberboxY:GetValue() - Wnd.Pos[ 2 ]
		GuiOffsetWndWithChilds( Wnd, X, Y )

		Wnd.Size[ 1 ] = Intefase.NumberboxW:GetValue()
		Wnd.Size[ 2 ] = Intefase.NumberboxH:GetValue()

		Wnd.Name = Intefase.TextInputSelectedWndName:GetText()

		if Wnd.Type == GUI_TYPE_TEXT then
			Wnd.Text = Intefase.TextPropertiesText:GetText()

			if Intefase.RadiobuttonPropertiesTextAlign1:GetChecked() then
				Wnd.TextAlign = 0
			elseif Intefase.RadiobuttonPropertiesTextAlign2:GetChecked() then
				Wnd.TextAlign = 1
			elseif Intefase.RadiobuttonPropertiesTextAlign3:GetChecked() then
				Wnd.TextAlign = 2
			end	

			Wnd.TextFont = Intefase.MultichoiceTextFont:GetChoice()

			Wnd.TextColor[ 1 ] = GuiGetColor( Intefase.TextColorR )
			Wnd.TextColor[ 2 ] = GuiGetColor( Intefase.TextColorG )
			Wnd.TextColor[ 3 ] = GuiGetColor( Intefase.TextColorB )
			Wnd.TextColor[ 4 ] = GuiGetColor( Intefase.TextColorA )
		end
	end
	GuiSelectWnd( Gui.SelectedWindow )
end


function GuiDelSelected()
	if Gui.SelectedWindow ~= nil then
		local Wnd = Gui.SelectedWindow

		if #Wnd.Childs > 0 then
			for I = 1, #Wnd.Childs do
				Log( Wnd.Childs[ I ].Name .. " rechild to " .. Wnd.Parent.Name )
				Wnd.Parent:PushChild( Wnd.Childs[ I ] )
			end			
		end

		if Wnd.Parent ~= nil then
			for I = 1, #Wnd.Parent.Childs do
				if Wnd.Parent.Childs[ I ] == Wnd then
					table.remove ( Wnd.Parent.Childs, I )
					break
				end
			end
		end
	end
	GuiSelectWnd( nil )
end


function GuiOffsetWndWithChilds( Wnd, X, Y )
	local ChildTree = {}
	Gui.SelectedWindow:GetChildsTree( ChildTree, 0 ) 

	for I = 1, #ChildTree do
		local Wnd = ChildTree[ I ][ 1 ]
		Wnd.Pos[ 1 ] = Wnd.Pos[ 1 ] + X
		Wnd.Pos[ 2 ] = Wnd.Pos[ 2 ] + Y
	end
end


function GuiSaveNewWndSize()
	if Gui.SelectedWindow ~= nil then
		local CX, CY = GetTexCoordCur()
		Gui.SelectedWindow.Size[ 1 ] = ( Gui.SelectedWindow.Size[ 1 ] + CX - g_Lmb_down_coord[ 1 ] )
		Gui.SelectedWindow.Size[ 2 ] = ( Gui.SelectedWindow.Size[ 2 ] + CY - g_Lmb_down_coord[ 2 ] )
	end
	GuiSelectWnd( Gui.SelectedWindow )
end


function GuiAddWnd()	

	local c1 = window_base( GUI_TYPE_WINDOW )
	c1.Pos = { 10, 10 }
	c1.Size = { 10, 10 }
	c1.Type = Tp
	c1.Name = "new_obj"

	if Intefase.AddNewWndRadiobuttonSprite:GetChecked() then
		c1.Type = GUI_TYPE_SPRITE
	end
	if Intefase.AddNewWndRadiobuttonButton:GetChecked() then
		c1.Type = GUI_TYPE_BUTTON
	end
	if Intefase.AddNewWndRadiobuttonText:GetChecked() then
		c1.Type = GUI_TYPE_TEXT
		c1.Text = "New_text"
		c1.TextFont = "Calibri_white"
	end

	if Gui.SelectedWindow ~= nil then
		Gui.SelectedWindow:PushChild( c1 )
	else
		Gui.RootWindow:PushChild( c1 )
	end

	InterfaseRefreshGuiWindowsList( Gui.SelectedWindow )
end


function GuiSetTex()
	if SubTex[ g_NameOfSelectedSubTex ] == nil then
		InterfaseShowMsg( "no selekted tex" )
		return
	end

	if Gui.SelectedWindow.Type == GUI_TYPE_TEXT then
		InterfaseShowMsg( "not available for text" )
		return
	end

	if Gui.SelectedWindow ~= nil then
		Gui.SelectedWindow.TexName = "resources/" .. Config_TexFiles[ g_CurrentSubTexFileIndex ] .. ".tga"
		Gui.SelectedWindow.SubTexName = g_NameOfSelectedSubTex
		Gui.SelectedWindow.TexRect[ 1 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 1 ]
		Gui.SelectedWindow.TexRect[ 2 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 2 ]
		Gui.SelectedWindow.TexRect[ 3 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 3 ]
		Gui.SelectedWindow.TexRect[ 4 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 4 ]
		local Tex = g_ResMgr:GetImage( Gui.SelectedWindow.TexName )
		Gui.SelectedWindow.EditorQuad = g_ResMgr:GethQuad( Tex, SubTex[ g_NameOfSelectedSubTex ].Coord )
	end	
end


function GuiSetWndSizeAsTex( StepDirText )	
	local Wnd = Gui.SelectedWindow
	if Wnd ~= nil and Wnd.TexRect[ 4 ] ~= 0 then
		local CX, CY = GetTexCoordCur()
		Wnd.Size[ 1 ] = Wnd.TexRect[ 3 ]
		Wnd.Size[ 2 ] = Wnd.TexRect[ 4 ]
	else		
		InterfaseShowMsg( "no selekted tex or no sub tex" )
	end
	GuiSelectWnd( Gui.SelectedWindow )
end


function GuiStepInTree( StepDirText )	
	local Wnd = Gui.SelectedWindow
	if Wnd == nil  then	
		InterfaseShowMsg( "no selekted Wnd" )
		return
	end
	if Wnd.Parent == nil  then	
		InterfaseShowMsg( "no parent Wnd" )
		return
	end

	local ChildNum = 1
	local Childs = Wnd.Parent.Childs
	for I = 1, #Childs do
		if Childs[ I ] == Wnd then
			ChildNum = I
		end
	end

	if StepDirText == "up" then
		if ChildNum == 1 then	
			InterfaseShowMsg( "already up" )		
			return
		end

		local UpChild = Childs[ ChildNum - 1 ]
		Childs[ ChildNum - 1 ] = Wnd
		Childs[ ChildNum ] = UpChild
	end

	if StepDirText == "down" then
		if ChildNum == #Childs then	
			InterfaseShowMsg( "already down" )		
			return
		end

		local DownChild = Childs[ ChildNum + 1 ]
		Childs[ ChildNum + 1 ] = Wnd
		Childs[ ChildNum ] = DownChild
	end

	GuiSelectWnd( Gui.SelectedWindow )
end


function GuiWndCopy()
	local Wnd = Gui.SelectedWindow

	if Wnd.Parent == nil then
		InterfaseShowMsg( "no copy root wnd" )
		return
	end

	if Gui.SelectedWindow ~= nil then

		local C = window_base( GUI_TYPE_WINDOW )
		C.Pos = { Wnd.Pos[ 1 ] + 10, Wnd.Pos[ 2 ] + 10 }
		C.Size = { Wnd.Size[ 1 ], Wnd.Size[ 2 ] }
		C.Type = Wnd.Type
		C.Name = Wnd.Name .. "_copy"
		C.Visible = Wnd.Visible
		C.Text = Wnd.Text
		C.TextAlign = Wnd.TextAlign
		C.TextFont = Wnd.TextFont
		C.TextColor = { Wnd.TextColor[ 1 ], Wnd.TextColor[ 2 ], Wnd.TextColor[ 3 ], Wnd.TextColor[ 4 ] }
		C.TexName = Wnd.TexName
		C.SubTexName = Wnd.SubTexName
		C.TexRect = { Wnd.TexRect[ 1 ], Wnd.TexRect[ 2 ], Wnd.TexRect[ 3 ], Wnd.TexRect[ 4 ] }		
		C.Parent = Wnd.Parent

		Wnd.Parent:PushChild( C )
		GuiSelectWnd( C )
	else
		InterfaseShowMsg( "no selekted tex" )
	end	
end