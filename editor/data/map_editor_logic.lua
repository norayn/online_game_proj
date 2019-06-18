require( "map_base_class" )
require( "func" )
local json = require( "libraries.dkjson" )

MAP_EDITOR_MODE_EDIT = 1
MAP_EDITOR_MODE_BRUSH = 2
MAP_EDITOR_MODE_GRID_BRUSH = 3
MAP_EDITOR_MODE_EDIT_LAYER = 4


local Map = {	
	Mode = MAP_EDITOR_MODE_EDIT,
	
	LayerTable = {},
		
	SelectedLayer = nil,
	ObjUnderCursor = nil,
	SelectedObj = nil,
	CopyedObj = nil,

	ModeGridBrushParam = { LastPos = { 0, 0 }, DrawPass = 0 },
}


function MapLoadData()
	local Pos, Size = { 0, 0 }, { 222, 222 }
	Map.LayerTable[ 1 ] = map_layer( Pos, Size )
	local ObjTable = Map.LayerTable[ 1 ].ObjTable
	
	Map.SelectedLayer = Map.LayerTable[ 1 ]
end


function MapGetMapEditor()
	return Map
end


local function DrawLayerRect( Layer )
	if Layer ~= Map.SelectedLayer then
		if Map.Mode ~= MAP_EDITOR_MODE_EDIT_LAYER then return  end		
		love.graphics.setColor( 0, 155, 155, 255 )
	else
		love.graphics.setColor( 0, 0, 255, 255 )
	end

	local X, Y, W, H = Layer.Pos[ 1 ] * g_MapScale, Layer.Pos[ 2 ] * g_MapScale, Layer.Size[ 1 ] * g_MapScale, Layer.Size[ 2 ] * g_MapScale
	love.graphics.rectangle( "line", X + g_MapOffsetX, Y + g_MapOffsetY, W, H )
	
end


local function DrawAngleRect( Obj, Mode, X, Y, W, H )
	local P1 = { 0, 0 }
	local P2 = RotatePoint( { W, 0 }, Obj.Rotate )
	local P3 = RotatePoint( { W, H }, Obj.Rotate )
	local P4 = RotatePoint( { 0, H }, Obj.Rotate )
	
	local Vertices = { 
		P1[ 1 ] + g_MapOffsetX + X, P1[ 2 ] + g_MapOffsetY + Y,
		P2[ 1 ] + g_MapOffsetX + X, P2[ 2 ] + g_MapOffsetY + Y,
		P3[ 1 ] + g_MapOffsetX + X, P3[ 2 ] + g_MapOffsetY + Y,
		P4[ 1 ] + g_MapOffsetX + X, P4[ 2 ] + g_MapOffsetY + Y,
		P1[ 1 ] + g_MapOffsetX + X, P1[ 2 ] + g_MapOffsetY + Y }
	
	love.graphics.polygon( Mode, Vertices )
end


local function DrawObjWithChilds( Obj, LayerIsSelected )
	if Obj.EditorVisible ~= 0 then
		local X = Obj.Pos[ 1 ] * g_MapScale
		local Y = Obj.Pos[ 2 ] * g_MapScale
		local W = Obj.Size[ 1 ] * g_MapScale
		local H = Obj.Size[ 2 ] * g_MapScale

		if Obj == Map.SelectedObj then
			love.graphics.setColor( 0, 255, 0, 255 )
			if g_ctrl_down == 1 and g_alt_down ~= 1 and g_Lmb_down == 1 then
				local CX, CY = GetTexCoordCur()--move
				X = ( Obj.Pos[ 1 ] + CX - g_Lmb_down_coord[ 1 ] ) * g_MapScale
				Y = ( Obj.Pos[ 2 ] + CY - g_Lmb_down_coord[ 2 ] ) * g_MapScale
			end
			if g_alt_down == 1 and g_ctrl_down ~= 1 and g_Lmb_down == 1 then
				local CX, CY = GetTexCoordCur()	--scale				
				W = ( Obj.Size[ 1 ] + CX - g_Lmb_down_coord[ 1 ] ) * g_MapScale
				H = ( Obj.Size[ 2 ] + CY - g_Lmb_down_coord[ 2 ] ) * g_MapScale
			end
			if g_alt_down == 1 and g_ctrl_down == 1 and g_Lmb_down == 1 then
				local CX, CY = GetTexCoordCur()	--rotate				
				R = 0 + ( ( CX - g_Lmb_down_coord[ 1 ] ) / 100 ) + ( ( CY - g_Lmb_down_coord[ 2 ] ) / 10000 )
				Obj.Rotate = R
			end
		else
			love.graphics.setColor( 255, 255, 255, 255 )
		end

		if g_GuiShowRect and LayerIsSelected then
			if Obj.Type ~= MAP_TYPE_SERV_RECT and Obj.Type ~= MAP_TYPE_TRIGGER_RECT then					
				if not Obj.Rotate or Obj.Rotate == 0 then
					love.graphics.rectangle( "line", X + g_MapOffsetX, Y + g_MapOffsetY, W, H )
				else
					DrawAngleRect( Obj, "line", X, Y, W, H )
				end


			else
				local r, g, b, a = love.graphics.getColor()
				love.graphics.setColor( r, g, b, 111 )
				if Obj.Type == MAP_TYPE_TRIGGER_RECT then
					love.graphics.print( "TR " .. Obj.TriggerType, X + g_MapOffsetX + 5, Y + g_MapOffsetY + 5 )
						
					love.graphics.setColor( r, g, 0, 111 )
				end
				
				if not Obj.Rotate or Obj.Rotate == 0 then
					love.graphics.rectangle( "fill", X + g_MapOffsetX, Y + g_MapOffsetY, W, H )
				else
					DrawAngleRect( Obj, "fill", X, Y, W, H )
				end
			end
		end



		if Obj.TexName ~= "" then --DRAW texture
			if Obj.EditorQuad == nil then
				local Tex = g_ResMgr:GetImage( Obj.TexName )	
				Obj.EditorQuad = g_ResMgr:GethQuad( Tex, Obj.TexRect )					
			end
			
			love.graphics.setColor( 255, 255, 255, 255 )
			local Tex = g_ResMgr:GetImage( Obj.TexName )			
			local StSlX, StSlY = Obj.Size[ 1 ] / Obj.TexRect[ 3 ] * g_MapScale, Obj.Size[ 2 ] / Obj.TexRect[ 4 ] * g_MapScale			
			love.graphics.draw( Tex, Obj.EditorQuad, X + g_MapOffsetX, Y + g_MapOffsetY, Obj.Rotate, StSlX , StSlY )
		end
				
		if Obj.ServRect and g_GuiShowRect and LayerIsSelected then
			local X1 = Obj.ServRect[ 1 ] * g_MapScale + g_MapOffsetX
			local Y1 = Obj.ServRect[ 2 ] * g_MapScale + g_MapOffsetY
			local W1 = Obj.ServRect[ 3 ] * g_MapScale
			local H1 = Obj.ServRect[ 4 ] * g_MapScale
			love.graphics.setColor( 55, 55, 133, 211 )
			love.graphics.rectangle( "fill", X1, Y1, W1, H1 )
		end
	elseif Obj.Type == MAP_TYPE_SUB_LAYER then	
		return
	end	

	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do	
			DrawObjWithChilds( Obj.Childs[ I ], LayerIsSelected )
		end
	end
end


local function DrawLayer( Layer )
	local LayerIsSelected = Layer == Map.SelectedLayer
	local ObjTable = Layer.ObjTable

	for I = 1, #ObjTable do
		DrawObjWithChilds( ObjTable[ I ], LayerIsSelected )
	end
end


function MapDraw()
	for J = 1, #Map.LayerTable do
		if Map.LayerTable[ J ].EditorVisible ~= 0 then 
			DrawLayer( Map.LayerTable[ J ] )
		end

		DrawLayerRect( Map.LayerTable[ J ] )
	end

	----------------------MAP_EDITOR_MODE_BRUSH-    -MAP_EDITOR_MODE_GRID_BRUSH
	if ( Map.Mode == MAP_EDITOR_MODE_BRUSH or Map.Mode == MAP_EDITOR_MODE_GRID_BRUSH ) 
	and SubTex[ g_NameOfSelectedSubTex ] ~= nil then
		love.graphics.setColor( 255, 255, 255, 155 )
		
		local CoordX, CoordY = GetTexCoordCur()
		if Map.Mode == MAP_EDITOR_MODE_GRID_BRUSH then
			CoordX, CoordY = GetGridCoordCur()
		end
		
		local X = CoordX * g_MapScale
		local Y = CoordY * g_MapScale

		local TexName = "resources/" .. Config_TexFiles[ g_CurrentSubTexFileIndex ] .. ".tga"
		local Tex = g_ResMgr:GetImage( TexName )
		local TexRect = SubTex[ g_NameOfSelectedSubTex ].Coord					
		local Quad = g_ResMgr:GethQuad( Tex, TexRect )	
		love.graphics.draw( Tex, Quad, X + g_MapOffsetX, Y + g_MapOffsetY, 0, g_MapScale, g_MapScale )
	
		love.graphics.setColor( 255, 255, 255, 255 )
	end
end


local function GetObjUnderCursorWithChilds( Obj, CoordX, CoordY )	
	local CX, CY = CoordX, CoordY
	if Obj.Rotate ~= 0 then
		local Res = RotatePoint( { CX, CY }, -Obj.Rotate, Obj.Pos )
		CX, CY = Res[ 1 ], Res[ 2 ]
	end
	
	if Obj:OnObj( CX, CY ) and Obj.EditorVisible == 1 then
		Map.ObjUnderCursor = Obj
	end

	for I = 1, #Obj.Childs do		
		local Res = GetObjUnderCursorWithChilds( Obj.Childs[ I ], CoordX, CoordY )
		if Res then Map.ObjUnderCursor = Res end
	end
end


local function MapGetObjParent( Obj, ObjParent )	
	if not ObjParent then
		local ObjTable = Map.SelectedLayer.ObjTable

		for I = 1, #ObjTable do
			if ObjTable[ I ] == Obj then return nil end --layer == parent
			local Res = MapGetObjParent( Obj, ObjTable[ I ] )
			if Res then return Res end
		end
		return nil --no parent
	end

	if #ObjParent.Childs > 0 then
		for I = 1, #ObjParent.Childs do			
			if ObjParent.Childs[ I ] == Obj then return ObjParent end
			local Res = MapGetObjParent( Obj, ObjParent.Childs[ I ] )
			if Res then return Res end
		end
	end

	return nil
end


function MapUpdateLogic()	
	local ObjTable = Map.SelectedLayer.ObjTable
	local CoordX, CoordY = GetTexCoordCur()
	Intefase.TexCurPos:SetText( "x:" .. CoordX .. " y:" .. CoordY .. " || Offset x: " .. CoordX - g_CurOffset[ 1 ] .. " y: " .. CoordY - g_CurOffset[ 2 ] )

	Map.ObjUnderCursor = nil

	for I = 1, #ObjTable do
		GetObjUnderCursorWithChilds( ObjTable[ I ], CoordX, CoordY )
	end
	
	if Map.ObjUnderCursor == nil then
		Intefase.Label2:SetText( "^__^" )
		Intefase.Label1:SetText( "^__^" )
	else
		local X, Y, W, H = Map.ObjUnderCursor.Pos[ 1 ], Map.ObjUnderCursor.Pos[ 2 ],
			Map.ObjUnderCursor.Size[ 1 ], Map.ObjUnderCursor.Size[ 2 ]
		Intefase.Label2:SetText( "X:" .. X .. " Y:" .. Y .. " W:" .. W .. "(" .. X + W .. ") H:" .. H .. "(" .. Y + H .. ")" )
		Intefase.Label1:SetText( Map.ObjUnderCursor.Name )
	end

	if Map.Mode == MAP_EDITOR_MODE_GRID_BRUSH and SubTex[ g_NameOfSelectedSubTex ] ~= nil then
		if g_Lmb_down == 1 then		
			if Map.ModeGridBrushParam.DrawPass == 1 then
				local PosX, PosY = GetGridCoordCur()
				if Map.ModeGridBrushParam.LastPos[ 1 ] ~= PosX or Map.ModeGridBrushParam.LastPos[ 2 ] ~= PosY then
				-----
					local Obj = map_obj( MAP_TYPE_BG_SPRITE )
					Obj.TexName = "resources/" .. Config_TexFiles[ g_CurrentSubTexFileIndex ] .. ".tga"
					Obj.SubTexName = g_NameOfSelectedSubTex
					Obj.TexRect[ 1 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 1 ]
					Obj.TexRect[ 2 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 2 ]
					Obj.TexRect[ 3 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 3 ]
					Obj.TexRect[ 4 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 4 ]
									
					Obj.Pos = { PosX, PosY }
					Obj.Size = { Obj.TexRect[ 3 ], Obj.TexRect[ 4 ] }	
					
					local ObjParent = MapGetObjParent( Map.SelectedObj )
					if ObjParent ~= nil then
						table.insert( ObjParent.Childs, Obj )					
					else
						table.insert( Map.SelectedLayer.ObjTable, Obj )
					end

					InterfaseRefreshMapObjList()

					Map.ModeGridBrushParam.LastPos = { PosX, PosY }	
				-----
				end
			end
		else
			Map.ModeGridBrushParam.DrawPass = 2
		end
	else
		Map.ModeGridBrushParam.DrawPass = 0
	end
end


function MapLmbAction()

	if Map.Mode == MAP_EDITOR_MODE_EDIT then
		if g_ctrl_down == 0 then
			MapSelectObj()
		end
	elseif Map.Mode == MAP_EDITOR_MODE_BRUSH and g_Lmb_down == 1 and SubTex[ g_NameOfSelectedSubTex ] ~= nil then
		local Obj = map_obj( MAP_TYPE_BG_SPRITE )

		Obj.TexName = "resources/" .. Config_TexFiles[ g_CurrentSubTexFileIndex ] .. ".tga"
		Obj.SubTexName = g_NameOfSelectedSubTex
		Obj.TexRect[ 1 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 1 ]
		Obj.TexRect[ 2 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 2 ]
		Obj.TexRect[ 3 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 3 ]
		Obj.TexRect[ 4 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 4 ]
		Obj.Pos = g_Lmb_down_coord	
		Obj.Size = { Obj.TexRect[ 3 ], Obj.TexRect[ 4 ] }	
		
		if Map.SelectedObj ~= nil then
			table.insert( Map.SelectedObj.Childs, Obj )					
		else
			table.insert( Map.SelectedLayer.ObjTable, Obj )
		end

		InterfaseRefreshMapObjList()
	elseif Map.Mode == MAP_EDITOR_MODE_GRID_BRUSH and g_Lmb_down == 1 and SubTex[ g_NameOfSelectedSubTex ] ~= nil then
		local Obj = map_obj( MAP_TYPE_BG_SPRITE )

		Obj.TexName = "resources/" .. Config_TexFiles[ g_CurrentSubTexFileIndex ] .. ".tga"
		Obj.SubTexName = g_NameOfSelectedSubTex
		Obj.TexRect[ 1 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 1 ]
		Obj.TexRect[ 2 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 2 ]
		Obj.TexRect[ 3 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 3 ]
		Obj.TexRect[ 4 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 4 ]
		local PosX, PosY = GetGridCoordCur()	
		Obj.Pos = { PosX, PosY }
		Obj.Size = { Obj.TexRect[ 3 ], Obj.TexRect[ 4 ] }	
		local ObjParent = MapGetObjParent( Map.SelectedObj )
		if ObjParent ~= nil then
			table.insert( ObjParent.Childs, Obj )					
		else
			table.insert( Map.SelectedLayer.ObjTable, Obj )
		end

		InterfaseRefreshMapObjList()

		Map.ModeGridBrushParam.LastPos = { PosX, PosY }	
		Map.ModeGridBrushParam.DrawPass = 1
	end
end


function MapChangeMode( NewMode )
	Map.Mode = NewMode

	InterfaseRefreshMapObjList()
end


function GetGridCoordCur( NewMode )
		local Obj = Map.SelectedObj
		local CoordX, CoordY = GetTexCoordCur()
		if not Obj then
			return { CoordX, CoordY } 
		end

		local X, Y, W, H = Obj.Pos[ 1 ], Obj.Pos[ 2 ], Obj.Size[ 1 ], Obj.Size[ 2 ]		
		local OffsetX, OffsetY = X, Y
		MapIntefase.Label1:SetText( "ox " .. OffsetX .. " oy " .. OffsetX )
		CoordX = math.floor( ( CoordX - OffsetX ) / W )
		CoordY = math.floor( ( CoordY - OffsetY ) / H )
		return CoordX * W + OffsetX, CoordY * H + OffsetY
end


function MapSelectObj( SelectedObj )
	if SelectedObj and SelectedObj == Map.SelectedObj then		
		if SelectedObj.EditorShowChildsInList == 1 then
			SelectedObj.EditorShowChildsInList = 0
		else
			SelectedObj.EditorShowChildsInList = 1
		end
		InterfaseRefreshMapObjList()
		return
	end
	
	if SelectedObj == nil then
		Map.SelectedObj = Map.ObjUnderCursor	
	else
		Map.SelectedObj = SelectedObj
	end

	local Obj = Map.SelectedObj

	InterfaseRefreshMapObjList()
	
	local Name, x, y, w, h = "", 0, 0, 0, 0
	if Obj ~= nil then
		Name = Obj.Name
		x = Obj.Pos[ 1 ]
		y = Obj.Pos[ 2 ]
		w = Obj.Size[ 1 ]
		h = Obj.Size[ 2 ]
	end

	Intefase.TextInputSelectedWndName:SetText( Name )
	Intefase.NumberboxX:SetValue( x )
	Intefase.NumberboxY:SetValue( y )
	Intefase.NumberboxW:SetValue( w )
	Intefase.NumberboxH:SetValue( h )
end


function MapSelectLayer( SelectedLayer )
	Map.SelectedObj = nil
	Map.SelectedLayer = SelectedLayer

	InterfaseRefreshMapObjList()

	if Map.Mode == MAP_EDITOR_MODE_EDIT_LAYER then
		local Name, x, y, w, h = "", 0, 0, 0, 0
		if SelectedLayer ~= nil then
			Name = SelectedLayer.Name
			x = SelectedLayer.Pos[ 1 ]
			y = SelectedLayer.Pos[ 2 ]
			w = SelectedLayer.Size[ 1 ]
			h = SelectedLayer.Size[ 2 ]
		end

		Intefase.TextInputSelectedWndName:SetText( Name )
		Intefase.NumberboxX:SetValue( x )
		Intefase.NumberboxY:SetValue( y )
		Intefase.NumberboxW:SetValue( w )
		Intefase.NumberboxH:SetValue( h )
	end
end


function MapDelSelected()
	local Obj = Map.SelectedObj
	if Obj ~= nil then	
		if Obj == Map.CopyedObj then	
			Map.CopyedObj = nil
		end

		local ObjTable = Map.SelectedLayer.ObjTable	
		local ObjParent = MapGetObjParent( Obj )
		if ObjParent then
			ObjTable = ObjParent.Childs			
		end

		for I = 1, #ObjTable do
			if ObjTable[ I ] == Obj then
				table.remove ( ObjTable, I )
				break
			end
		end		
	end	

	InterfaseRefreshMapObjList()
end


local function MapOffsetObjWithChilds( Obj, X, Y )
	Obj.Pos[ 1 ] = Obj.Pos[ 1 ] + X
	Obj.Pos[ 2 ] = Obj.Pos[ 2 ] + Y

	if Obj.ServRect then
		Obj.ServRect[ 1 ] = Obj.ServRect[ 1 ] + X
		Obj.ServRect[ 2 ] = Obj.ServRect[ 2 ] + Y
	end

	if g_shift_down == 1 then return end

	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do			
			MapOffsetObjWithChilds( Obj.Childs[ I ], X, Y )
		end
	end
end


function MapSaveNewObjPos()
	if Map.SelectedObj ~= nil then
		local CX, CY = GetTexCoordCur()
		local OfX = CX - g_Lmb_down_coord[ 1 ]
		local OfY = CY - g_Lmb_down_coord[ 2 ]
		MapOffsetObjWithChilds( Map.SelectedObj, OfX, OfY )
	end
	MapSelectObj( Map.SelectedObj )
end


function MapSaveNewObjSize()
	if Map.SelectedObj ~= nil then
		local CX, CY = GetTexCoordCur()
		Map.SelectedObj.Size[ 1 ] = ( Map.SelectedObj.Size[ 1 ] + CX - g_Lmb_down_coord[ 1 ] )
		Map.SelectedObj.Size[ 2 ] = ( Map.SelectedObj.Size[ 2 ] + CY - g_Lmb_down_coord[ 2 ] )
	end
	MapSelectObj( Map.SelectedObj )
end


function LayerMoveTo( Layer, NewX, NewY )
	local Ox, Oy = NewX - Layer.Pos[ 1 ], NewY - Layer.Pos[ 2 ]	
	Layer.Pos = { NewX, NewY }		
	if g_shift_down == 1 then return end
	
	for I = 1, #Layer.ObjTable do
		MapOffsetObjWithChilds( Layer.ObjTable[ I ], Ox, Oy )
	end
end


function MapSaveSelected()
	local Obj = {}
	if Map.Mode == MAP_EDITOR_MODE_EDIT_LAYER then
		Obj = Map.SelectedLayer
	else
		Obj = Map.SelectedObj
	end

	if Obj ~= nil then
		local X = Intefase.NumberboxX:GetValue()
		local Y = Intefase.NumberboxY:GetValue()
		
		if Map.Mode == MAP_EDITOR_MODE_EDIT_LAYER then
			LayerMoveTo( Obj, X, Y )
		else
			Obj.Pos[ 1 ] = X
			Obj.Pos[ 2 ] = Y
		end

		Obj.Size[ 1 ] = Intefase.NumberboxW:GetValue()
		Obj.Size[ 2 ] = Intefase.NumberboxH:GetValue()

		Obj.Name = Intefase.TextInputSelectedWndName:GetText()				
	end

	if Map.Mode == MAP_EDITOR_MODE_EDIT_LAYER then
		MapSelectLayer( Obj )
	else
		MapSelectObj( Obj )
	end
end


function MapSetTex()
	if SubTex[ g_NameOfSelectedSubTex ] == nil then
		InterfaseShowMsg( "no selekted tex" )
		return
	end

	if Map.SelectedObj ~= nil then
		if Map.SelectedObj.Type == MAP_TYPE_SUB_LAYER then
			InterfaseShowMsg( "no set tex to sub layer" )
			return
		end

		Map.SelectedObj.TexName = "resources/" .. Config_TexFiles[ g_CurrentSubTexFileIndex ] .. ".tga"
		Map.SelectedObj.SubTexName = g_NameOfSelectedSubTex
		Map.SelectedObj.TexRect[ 1 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 1 ]
		Map.SelectedObj.TexRect[ 2 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 2 ]
		Map.SelectedObj.TexRect[ 3 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 3 ]
		Map.SelectedObj.TexRect[ 4 ] = SubTex[ g_NameOfSelectedSubTex ].Coord[ 4 ]
		local Tex = g_ResMgr:GetImage( Map.SelectedObj.TexName )
		Map.SelectedObj.EditorQuad = g_ResMgr:GethQuad( Tex, SubTex[ g_NameOfSelectedSubTex ].Coord )
	end	
end


function MapSetWndSizeAsTex( StepDirText )	
	local Obj = Map.SelectedObj
	if Obj ~= nil and Obj.TexRect[ 4 ] ~= 0 then
		local CX, CY = GetTexCoordCur()
		Obj.Size[ 1 ] = Obj.TexRect[ 3 ]
		Obj.Size[ 2 ] = Obj.TexRect[ 4 ]
	else		
		InterfaseShowMsg( "no selekted tex or no sub tex" )
	end
	MapSelectObj( Obj )
end


function MapAddObj( Type )
	local Obj = map_obj( Type )
		
	Obj.Size = { 100, 100 }
	if Map.SelectedObj ~= nil then		
		table.insert( Map.SelectedObj.Childs, Obj )
		Obj.Pos = Add( Map.SelectedObj.Pos, { 10, 10 } )
	else
		table.insert( Map.SelectedLayer.ObjTable, Obj )
	end
	
	InterfaseRefreshMapObjList()
end


function MapAddSprite()
	MapAddObj( MAP_TYPE_BG_SPRITE )
end


function MapAddServRect()
	MapAddObj( MAP_TYPE_SERV_RECT )
end


function MapAddSubLayer()
	MapAddObj( MAP_TYPE_SUB_LAYER )
end


function MapAddTriggerRect()
	MapAddObj( MAP_TYPE_TRIGGER_RECT )
end


function MapAddLayer()
	local Layer = map_layer( { 0, 0 }, { 100, 100 } )

	table.insert( Map.LayerTable, Layer )
	
	InterfaseRefreshMapObjList()
end


function MapStepInTree( StepDirText )	
	local Obj = {}
	local ObjTable = {}
	if Map.Mode == MAP_EDITOR_MODE_EDIT_LAYER then
		Obj = Map.SelectedLayer
		ObjTable = Map.LayerTable
	else
		Obj = Map.SelectedObj	
		local ObjParent = MapGetObjParent( Obj )
		if ObjParent then
			ObjTable = ObjParent.Childs	
		else
			ObjTable = Map.SelectedLayer.ObjTable		
		end
	end

	if Obj == nil  then	
		InterfaseShowMsg( "no selekted Obj" )
		return
	end
	
	local ObjNum = 1	
	for I = 1, #ObjTable do
		if ObjTable[ I ] == Obj then
			ObjNum = I
		end
	end

	if StepDirText == "up" then
		if ObjNum == 1 then	
			InterfaseShowMsg( "already up" )		
			return
		end

		local UpObj = ObjTable[ ObjNum - 1 ]
		ObjTable[ ObjNum - 1 ] = Obj
		ObjTable[ ObjNum ] = UpObj
	end

	if StepDirText == "down" then
		if ObjNum == #ObjTable then	
			InterfaseShowMsg( "already down" )		
			return
		end

		local DownObj = ObjTable[ ObjNum + 1 ]
		ObjTable[ ObjNum + 1 ] = Obj
		ObjTable[ ObjNum ] = DownObj
	end

	if Map.Mode == MAP_EDITOR_MODE_EDIT_LAYER then
		MapSelectLayer( Obj )
	else
		MapSelectObj( Obj )
	end
end


function MapSetRectToParent()
	if Map.SelectedObj == nil then
		InterfaseShowMsg( "no Selected Obj" )
		return
	end

	local Parent = MapGetObjParent( Map.SelectedObj )
	if Parent == nil then
		InterfaseShowMsg( "no Parent Obj" )
		return
	end

	if Parent.Type ~= MAP_TYPE_BG_SPRITE then
		InterfaseShowMsg( "Parent no BG" .. Parent.Type )
		return
	end
	Parent.Type = MAP_TYPE_OBJ_SPRITE
	Parent.ServRect = { Map.SelectedObj.Pos[ 1 ], Map.SelectedObj.Pos[ 2 ], Map.SelectedObj.Size[ 1 ], Map.SelectedObj.Size[ 2 ] }
	MapDelSelected()
end


function MapGetRectFromParent()
	if Map.SelectedObj == nil then
		InterfaseShowMsg( "no Selected Obj" )
		return
	end
	
	if Map.SelectedObj.ServRect == nil then
		InterfaseShowMsg( "no included Rect" )
		return
	end

	local Obj = map_obj( MAP_TYPE_SERV_RECT )
		
	Obj.Pos = { Map.SelectedObj.ServRect[ 1 ], Map.SelectedObj.ServRect[ 2 ] }
	Obj.Size = { Map.SelectedObj.ServRect[ 3 ], Map.SelectedObj.ServRect[ 4 ] }
	table.insert( Map.SelectedObj.Childs, Obj )
	Map.SelectedObj.ServRect = nil
	Map.SelectedObj.Type = MAP_TYPE_BG_SPRITE

	InterfaseRefreshMapObjList()
end


function MapTriggerToSpawn()
	if Map.SelectedObj == nil then
		InterfaseShowMsg( "no Selected Obj" )
		return
	end
	
	if Map.SelectedObj.Type ~= MAP_TYPE_TRIGGER_RECT then
		InterfaseShowMsg( "obj not trigger" )
		return
	end
	
	if Map.SelectedObj.TriggerType ~= "none" then
		InterfaseShowMsg( "trigger already " .. Map.SelectedObj.TriggerType )
		return
	end

	Map.SelectedObj.TriggerType = "spawn"
end


function MapCopySelected()
	if Map.SelectedObj ~= nil then
		Map.CopyedObj = Map.SelectedObj
	else
		InterfaseShowMsg( "no Selected Obj" )
	end
end


function MapPasteToSelected()
	if Map.CopyedObj == nil then
		InterfaseShowMsg( "no Copyed Obj" )
		return
	end
	
	local Obj = deepcopy( Map.CopyedObj )
		
	if Map.SelectedObj ~= nil then		
		table.insert( Map.SelectedObj.Childs, Obj )
	else
		table.insert( Map.SelectedLayer.ObjTable, Obj )
	end
	InterfaseRefreshMapObjList()
end


local function GetMinMaxAndRectFromObjWithChilds( Obj, Params )
	Obj.EditorQuad = nil

	if Obj.Type == MAP_TYPE_TRIGGER_RECT then
		Params.SrTab.Triggers[ #Params.SrTab.Triggers + 1 ] = Obj
	end

	if Obj.Type == MAP_TYPE_SERV_RECT then
		Params.SrTab.Rects[ #Params.SrTab.Rects + 1 ] = Obj
	end
	
	if Obj.ServRect then
		local RectObj = map_obj( MAP_TYPE_SERV_RECT )
		
		RectObj.Pos = { Obj.ServRect[ 1 ], Obj.ServRect[ 2 ] }
		RectObj.Size = { Obj.ServRect[ 3 ], Obj.ServRect[ 4 ] }
		if Obj.Rotate ~= 0 then
			RectObj.Rotate = Obj.Rotate
			RectObj.RotateRect = {}
			RectObj.RotateRect.Pos = { Obj.RotateRect[ 1 ], Obj.RotateRect[ 2 ] }
			RectObj.RotateRect.Size = { Obj.RotateRect[ 3 ], Obj.RotateRect[ 4 ] }
		end
		Params.SrTab.Rects[ #Params.SrTab.Rects + 1 ] = RectObj
	end

	Params.Min[ 1 ] = GetMin( Params.Min[ 1 ], Obj.Pos[ 1 ] )
	Params.Min[ 2 ] = GetMin( Params.Min[ 2 ], Obj.Pos[ 2 ] )
	Params.Max[ 1 ] = GetMax( Params.Max[ 1 ], Obj.Pos[ 1 ] + Obj.Size[ 1 ] )
	Params.Max[ 2 ] = GetMax( Params.Max[ 2 ], Obj.Pos[ 2 ] + Obj.Size[ 2 ] )

	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do
			GetMinMaxAndRectFromObjWithChilds( Obj.Childs[ I ], Params )
		end
	end
end
	

function MapSave()
	local ServTab = { 
		Rects = {},
		Triggers = {}, 
	}

	local MapMin = { 9999, 9999 }
	local MapMax = { -9999, -9999 }
	
	for J = 1, #Map.LayerTable do
		local ObjTable = Map.LayerTable[ J ].ObjTable
		for I = 1, #ObjTable do
			ObjTable[ I ].RotateRect = GetRectFromRotatedObj( ObjTable[ I ] )
			
			-- create ServTab
			GetMinMaxAndRectFromObjWithChilds( ObjTable[ I ], { SrTab = ServTab, Min = MapMin, Max = MapMax } )			
		end
	end

	table.save( Map.LayerTable, "data/working_folder/map_last_sesson.save" )
	
	ServTab.MapSize = { MapMin, MapMax }
	local JsonRes = json.encode ( ServTab, { indent = true } )	
	local JsonFile,err = io.open( "data/working_folder/map_last_sesson.mrt", "w" )
	JsonFile:write( JsonRes )
	JsonFile:close()

	InterfaseShowMsg( "Save ok" )
end


local function SetMetatableForObjWithChilds( Obj )
	local MapObjClass = map_obj( MAP_TYPE_NONE )	
	setmetatable( Obj, getmetatable( MapObjClass ) )
	
	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do
			SetMetatableForObjWithChilds( Obj.Childs[ I ] )
		end
	end
end


function MapLoad()
	Map.LayerTable = table.read( "data/working_folder/map_last_sesson.save" ) 

	local LayerClass = map_layer( { 0, 0 }, { 0, 0 } )
		
	for J = 1, #Map.LayerTable do
		setmetatable( Map.LayerTable[ J ], getmetatable( LayerClass ) )
		local ObjTable = Map.LayerTable[ J ].ObjTable
		for I = 1, #ObjTable do
			SetMetatableForObjWithChilds( ObjTable[ I ] )
		end
	end

	InterfaseShowMsg( "Load ok" )
end