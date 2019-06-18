require "class"

MAP_SHIFT_BORDER_DIST = 150

MAP_TYPE_NONE = 0
MAP_TYPE_BG_SPRITE = 1
MAP_TYPE_OBJ_SPRITE = 2
MAP_TYPE_SERV_RECT = 3
MAP_TYPE_SUB_LAYER = 4
MAP_TYPE_TRIGGER_RECT = 5


local function CompareByY( a, b )
  return a.Pos[ 2 ] < b.Pos[ 2 ]
end	


map_class = class(function( self, MapPatch )
	self.Offset = { 0, 0 } 		
	self.Layers = table.readWithLove( "res/map/test/map_last_sesson.save" ) 
	assert( self.Layers, "self.Layers" )
	self.ObjSprites = {}
	self.BattleAreas = {}

	for J = 1, #self.Layers do
		local ObjTable = self.Layers[ J ].ObjTable
		for I = 1, #ObjTable do	
			self:LoadObjWithChilds( ObjTable[ I ] )			
		end
	end
			
	table.sort( self.ObjSprites, CompareByY )
end)


function map_class:LoadObjWithChilds( Obj )
	if Obj.TexName ~= "" then				
		local TexName = "" --patch to name
		for I = 1, string.len( Obj.TexName ) do
			local Char = string.sub( Obj.TexName, -I, -I )
			if Char == '/' then break end
			TexName = Char .. TexName
		end
		Obj.TexName = TexName
		
		if not ResMgr:HasAtlas( Obj.TexName ) then
			ResMgr:LoadAtlasFromSubTex( "res/map/test/" , Obj.TexName )
		end

		local TmpAtlas = ResMgr:GetAtlas( Obj.TexName )	
		assert( TmpAtlas.SubTexTable[ Obj.SubTexName ], Obj.SubTexName .. ' SubTexName not found in ' .. Obj.TexName )
	
		Obj.Image = TmpAtlas.Image				
		Obj.Quad = TmpAtlas.SubTexTable[ Obj.SubTexName ].Quad
	end

	if Obj.Type == MAP_TYPE_OBJ_SPRITE then		
		table.insert( self.ObjSprites, Obj ) 
	end
	
	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do
			self:LoadObjWithChilds( Obj.Childs[ I ] )
		end
	end	
end 


function map_class:AddNewBattleArea( AreaInd, Rect )
	self.BattleAreas[ #self.BattleAreas + 1 ] = {
		AreaIndex = AreaInd,
		AreaRect = Rect
	}	
end


function map_class:DelBattleArea( AreaInd )
	for I = 1, #self.BattleAreas do
		if self.BattleAreas[ I ].AreaIndex == AreaInd then
			table.remove ( self.BattleAreas, I )
			return
		end
	end	
end


function map_class:IsPlayerInBattleArea( AreaInd, Player )	
	for I = 1, #self.BattleAreas do
		if self.BattleAreas[ I ].AreaIndex == AreaInd then			
			local Rect = self.BattleAreas[ I ].AreaRect
			if CheckPointInRect( Player.Pos, Rect ) then
				return true
			end
		end
	end	

	return false
end


local function DrawObjWithChilds( Obj, RenderRect )	
	local X = Obj.Pos[ 1 ]
	local Y = Obj.Pos[ 2 ]
	local W = Obj.Size[ 1 ]
	local H = Obj.Size[ 2 ]
	
	if Obj.Type == MAP_TYPE_OBJ_SPRITE then
		return
	end

	local ObjRect = { X, Y, W, H }
	if Obj.RotateRect then ObjRect = Obj.RotateRect end

	if not OutOfRect( RenderRect, ObjRect ) then
		local MapOffsetX, MapOffsetY = -RenderRect[ 1 ], -RenderRect[ 2 ]
		
		if Obj.TexName ~= "" then --DRAW texture
			love.graphics.setColor( 255, 255, 255, 255 )				
			local StSlX, StSlY = Obj.Size[ 1 ] / Obj.TexRect[ 3 ], Obj.Size[ 2 ] / Obj.TexRect[ 4 ]		
			
			love.graphics.draw( Obj.Image, Obj.Quad, X + MapOffsetX, Y + MapOffsetY, Obj.Rotate, StSlX , StSlY )
			g_RenderCount = g_RenderCount + 1
		end

		if Obj.Type == MAP_TYPE_SERV_RECT and Obj.Name == "battle_area" then--DRAW battle_area rect		
			love.graphics.setColor( 0, 0, 110, 35 )
			love.graphics.rectangle( "fill", X + MapOffsetX, Y + MapOffsetY, W, H )		
		end
	end

	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do
			DrawObjWithChilds( Obj.Childs[ I ], RenderRect )
		end
	end	
end

local function DrawLayer( Layer, RenderRect )	
	local ObjTable = Layer.ObjTable
	for I = 1, #ObjTable do
		DrawObjWithChilds( ObjTable[ I ], RenderRect )			
	end
end


function map_class:RenderPlayersOnMap( Players )
	local RenderRect = { -self.Offset[ 1 ], -self.Offset[ 2 ], g_Resolution[ 1 ], g_Resolution[ 2 ] }
	local PlayersCounter = 1

	for I = 1, #self.ObjSprites do		
		local Obj = self.ObjSprites[ I ]
		local X = Obj.Pos[ 1 ]
		local Y = Obj.Pos[ 2 ]
		local W = Obj.Size[ 1 ]
		local H = Obj.Size[ 2 ]
		
		if not OutOfRect( RenderRect, { X, Y, W, H } ) then					
			local SY = Obj.ServRect[ 2 ]
			for J = PlayersCounter, #Players do			
				if Players[ J ].Pos[ 2 ] < SY then		
					Players[ J ]:Render()
					PlayersCounter = J + 1					
				else	
					break
				end
			end
	
			if Obj.TexName ~= "" then --DRAW texture
				local MapOffsetX, MapOffsetY = -RenderRect[ 1 ], -RenderRect[ 2 ]
	
				love.graphics.setColor( 255, 255, 255, 255 )				
				local StSlX, StSlY = Obj.Size[ 1 ] / Obj.TexRect[ 3 ], Obj.Size[ 2 ] / Obj.TexRect[ 4 ]		
				
				love.graphics.draw( Obj.Image, Obj.Quad, X + MapOffsetX, Y + MapOffsetY, 0, StSlX , StSlY )
				g_RenderCount = g_RenderCount + 1
			end
		end
	end
	
	if PlayersCounter <= #Players then
		for J = PlayersCounter, #Players do					
			--if Players[ J ].Pos[ 2 ] < Y then		--in RECT?
				Players[ J ]:Render()
			--end
		end
	end

	--love.graphics.print("BgRenderCount:".. tostring( g_RenderCount ), 4, 24)	
end


function map_class:RenderBg( Offset )
	self:Update( ) --temp
	
	if not self.Layers then return end
	g_RenderCount = 0
		
	local WndRect = { -self.Offset[ 1 ], -self.Offset[ 2 ], g_Resolution[ 1 ], g_Resolution[ 2 ] }
	
	for J = 1, #self.Layers do
		local Lay = self.Layers[ J ]
		
		if not OutOfRect( WndRect, { Lay.Pos[ 1 ], Lay.Pos[ 2 ], Lay.Size[ 1 ], Lay.Size[ 2 ] } ) then
			DrawLayer( self.Layers[ J ], WndRect )
		end
	end	
		
	local MapOffsetX, MapOffsetY = self.Offset[ 1 ], self.Offset[ 2 ]
	for J = 1, #self.BattleAreas do--DRAW dimanic battle_area rect		
		
		local Rect = self.BattleAreas[ J ].AreaRect
		love.graphics.setColor( 222, 0, 11, 35 )
		love.graphics.rectangle( "fill", Rect[ 1 ] + MapOffsetX, Rect[ 2 ] + MapOffsetY, Rect[ 3 ], Rect[ 4 ] )			
	end

	if g_DebugEnable then
		love.graphics.print("BgRenderCount:".. tostring( g_RenderCount ), 4, 24)
	end	
end


function map_class:Update( )	
	if not g_SelfPlayer or g_SelfPlayer.State ~= object_logic_state.VALID then return end
	
	local PlayerScreenPos = Add( g_SelfPlayer.Pos, self.Offset )

	local MAP_SHIFT_BORDER_DIST_X = MAP_SHIFT_BORDER_DIST * 2
	if PlayerScreenPos[ 1 ] > g_Resolution[ 1 ] - MAP_SHIFT_BORDER_DIST_X then
		local OffsetSize = PlayerScreenPos[ 1 ] - ( g_Resolution[ 1 ] - MAP_SHIFT_BORDER_DIST_X )
		self.Offset[ 1 ] = self.Offset[ 1 ] - OffsetSize	
	elseif PlayerScreenPos[ 1 ] < MAP_SHIFT_BORDER_DIST_X then
		local OffsetSize = -PlayerScreenPos[ 1 ] + MAP_SHIFT_BORDER_DIST_X
		self.Offset[ 1 ] = self.Offset[ 1 ] + OffsetSize				
	end

	if PlayerScreenPos[ 2 ] > g_Resolution[ 2 ] - MAP_SHIFT_BORDER_DIST then
		local OffsetSize = PlayerScreenPos[ 2 ] - ( g_Resolution[ 2 ] - MAP_SHIFT_BORDER_DIST )
		self.Offset[ 2 ] = self.Offset[ 2 ] - OffsetSize
	elseif PlayerScreenPos[ 2 ] < MAP_SHIFT_BORDER_DIST + MAP_SHIFT_BORDER_DIST then
		local OffsetSize = -PlayerScreenPos[ 2 ] + MAP_SHIFT_BORDER_DIST + MAP_SHIFT_BORDER_DIST
		self.Offset[ 2 ] = self.Offset[ 2 ] + OffsetSize			
	end		
end
