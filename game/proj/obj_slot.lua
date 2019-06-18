require "class"

g_SlotSetManager = {}

----------------------------------------------------------------------------------------------------------------
slot_set_manager = class( function( self )	
	self.SlotSets = {}
	self.StartDragPos = nil
	self.DragSlot = nil
	self.TargetDragSlot = nil
end)


function slot_set_manager:Draw()
	for I = 1, #self.SlotSets do
		if self.SlotSets[ I ].NeedDraw then
			self.SlotSets[ I ]:Draw()
		end
	end

	if self.DragSlot and self.DragSlot.Icon and self.DragSlot.Icon.Image then
		local Cx, Cy = love.mouse.getPosition()
		love.graphics.draw( self.DragSlot.Icon.Image, self.DragSlot.Icon.Quad, Cx, Cy, 0, 1 ,1 )
	end
end


function slot_set_manager:Update()
	for I = 1, #self.SlotSets do
		if self.SlotSets[ I ].NeedUpdate then
			self.SlotSets[ I ]:Update()
		end
	end

	if self.DragSlot then
		if not love.mouse.isDown( "l" ) then	--TODO add mouse api	
			self:StopDrag()
		end
	end
end


function slot_set_manager:StartDrag( Slot )
	if not self.DragSlot and Slot.Item then
		self.DragSlot = Slot
		Log.Show( "Start drag " .. Slot.Index )

		if Slot.OwnerSet.OnStartDrag then
			Slot.OwnerSet.OnStartDrag({
				StartSlot = Slot				
			})
		end 
	end
end


function slot_set_manager:StopDrag()
	for I = 1, #self.SlotSets do
		local SlotUnderCursor = self.SlotSets[ I ]:GetSlotUnderCursor()
		if SlotUnderCursor then
			Log.Show( "StopDrag " .. SlotUnderCursor.Index ) 

			local SlotUnderCursorEmpty = false
			if not SlotUnderCursor.Item then
				SlotUnderCursorEmpty = true
				--temp for test:
				--SlotUnderCursor.Item = self.DragSlot.Item
				--SlotUnderCursor.Icon = self.DragSlot.Icon
				--self.DragSlot.Item = nil
				--self.DragSlot.Icon = nil
			end

			if SlotUnderCursor.OwnerSet.OnStopDrag then
				SlotUnderCursor.OwnerSet.OnStopDrag({
					StartSlot = self.DragSlot,
					StopSlot = SlotUnderCursor,
					TargetSlotIsEmty = SlotUnderCursorEmpty,
				})
			end

			break
		end
	end

	self.StartDragPos = nil
	self.DragSlot = nil
end


function slot_set_manager:Test()
	local Result = slot_set_class()
	Result:CreateGrid({
		Row = 4,
		Col = 3,
		Size = { 72, 72 },
	})
	Result.Pos = { 500, 111 }

	ResMgr:LoadAtlasFromSubTex( "res/gui/" , "icons.tga" )
	local TmpAtlas = ResMgr:GetAtlas( "icons.tga" )	

	local Slot = Result.Slots[ 1 ]
	Slot.Icon.Image = TmpAtlas.Image
	Slot.Icon.Quad = TmpAtlas.SubTexTable[ "Test1" ].Quad
	Slot.Icon.Item = { 44 }

	Slot = Result.Slots[ 2 ]
	Slot.Icon.Image = TmpAtlas.Image
	Slot.Icon.Quad = TmpAtlas.SubTexTable[ "Test3" ].Quad
	Slot.Icon.Item = { 44 }

	Slot = Result.Slots[ 5 ]
	Slot.Icon.Image = TmpAtlas.Image
	Slot.Icon.Quad = TmpAtlas.SubTexTable[ "Test2" ].Quad
	Slot.Icon.Item = { 44 }
end

g_SlotSetManager = slot_set_manager()

----------------------------------------------------------------------------------------------------------------
slot_set_class = class( function( self )	
	self.StorageType = storage_type.NONE
	self.Pos = { 0, 0 }
	self.Size = { 0, 0 }

	self.SlotUnderCursor = nil
	self.Slots = {}
	self.SlotRows = 0
	self.SlotCols = 0

	self.NeedDraw = false
	self.NeedUpdate = false

	self.OnStartDrag = nil
	self.OnStopDrag = nil

	g_SlotSetManager.SlotSets[ #g_SlotSetManager.SlotSets + 1 ] = self
end)


function slot_set_class:CreateGrid( Param )	
	if not Param.Border then Param.Border = 2 end	
	self.Size[ 1 ] = ( Param.Border + Param.Size[ 1 ] ) * Param.Col
	self.Size[ 2 ] = ( Param.Border + Param.Size[ 2 ] ) * Param.Row
	self.SlotRows = Param.Row
	self.SlotCols = Param.Col

	for I = 1, Param.Row do
		for J = 1, Param.Col do
			local Slot = obj_slot_class()
			Slot.Size = Param.Size
			Slot.Pos[ 1 ] = ( Param.Border + Param.Size[ 1 ] ) * ( J - 1 )
			Slot.Pos[ 2 ] = ( Param.Border + Param.Size[ 2 ] ) * ( I - 1 )
			Slot.OwnerSet = self
			--Slot.OnMouseLeftDown = function()
			--	Log.Show( Slot.Index )
			--end
			--Slot.OnMouseOver = function()
			--	Log.Show( "self.OnMouseOver()" .. Slot.Index )
			--end
			--Slot.OnMouseOut = function()
			--	Log.Show( "self.OnMouseOut()" .. Slot.Index )
			--end

			Slot.Index = #self.Slots + 1
			self.Slots[ #self.Slots + 1 ] = Slot			
		end
	end
end


function slot_set_class:Update()
	local function InRect( Pos, Size, X, Y )
		if X < Pos[ 1 ] or X > Pos[ 1 ] + Size[ 1 ] or Y < Pos[ 2 ] or Y > Pos[ 2 ] + Size[ 2 ] then
			return false
		end

		return true
	end

	local Cx, Cy = love.mouse.getPosition()
	local IsMouseOver = false
	if InRect( self.Pos, self.Size, Cx, Cy ) then
		IsMouseOver = true
	end

	local OCx, OCy = Cx - self.Pos[ 1 ], Cy - self.Pos[ 2 ]
	for I = 1, #self.Slots do
		if IsMouseOver and InRect( self.Slots[ I ].Pos, self.Slots[ I ].Size, OCx, OCy ) then			
			self.Slots[ I ]:Update( true )
		else
			self.Slots[ I ]:Update( false )
		end
	end
end


function slot_set_class:Draw()
	love.graphics.setColor( 99, 99, 99, 85 )
	love.graphics.rectangle( "fill", self.Pos[ 1 ], self.Pos[ 2 ], self.Size[ 1 ], self.Size[ 2 ] )

	for I = 1, #self.Slots do
		self.Slots[ I ]:Draw( self.Pos )
	end
end


function slot_set_class:GetSlotUnderCursor()
	return self.SlotUnderCursor
end


function slot_set_class:SetUpdateFlag( State )		
	self.NeedUpdate = State
end


function slot_set_class:SetDrawFlag( State )		
	self.NeedDraw = State
end


function slot_set_class:PushConfigToSlot( SlotIndex, ConfigIndex )
	assert( SlotIndex <= #self.Slots )
	Logf( SlotIndex .. ' SlotIndex, ConfigIndex ' .. ConfigIndex )
	local Slot = self.Slots[ SlotIndex ]
	if ConfigIndex ~= 0 then
		local Config = Game.Configs:GetByIndex( ConfigIndex )
			
		local TmpAtlas = ResMgr:GetAtlas( "icons.tga" )	
				
		Slot.Icon.Image = TmpAtlas.Image
		Slot.Icon.Quad = TmpAtlas.SubTexTable[ Config.Icon ].Quad
		Slot.Item = { ConfigIndex = ConfigIndex }
		Slot.ItemCount = 1
	else
		Slot.Icon.Image = nil
		Slot.Icon.Quad = nil
		Slot.Item = nil
		Slot.ItemCount = 0
	end
end
----------------------------------------------------------------------------------------------------------------
obj_slot_class = class( function( self )
	self.OwnerSet = nil
	self.Index = nil
	self.Pos = { 0, 0 }
	self.Size = { 0, 0 }
	self.Bg = {}
	self.Icon = {}
	self.Item = nil
	self.ItemCount = 0
	self.IsMouseOver = false
	self.IsMouseLeftDown = false

	self.OnMouseLeftDown = nil
	self.OnMouseOver = nil
	self.OnMouseOut = nil
	--MouseOver = funk,
	--MouseClick = funk,
	--HiglightInDropMode = funk,
	--StartDrop = funk,
	--StopDrop = funk,
	--DropToTarget = funk,
end)


function obj_slot_class:Update( IsMouseOver )
	local Cx, Cy = love.mouse.getPosition()

	if love.mouse.isDown( "l" ) then	--TODO add mouse api	
		if self.IsMouseOver then
			--Log.Show( "-1-" )
			if not self.IsMouseLeftDown then
				if self.OnMouseLeftDown then
					self.OnMouseLeftDown()
				end

				g_SlotSetManager.StartDragPos = { Cx, Cy }
			end	
		end
		
		self.IsMouseLeftDown = IsMouseOver
	else
		self.IsMouseLeftDown = false		
	end


	if self.IsMouseOver ~= IsMouseOver then
		if IsMouseOver then
			if self.OnMouseOver then
				self.OnMouseOver()
			end

			if self.OwnerSet then
				self.OwnerSet.SlotUnderCursor = self
			end
		end

		if not IsMouseOver then
			if self.OnMouseOut then
				self.OnMouseOut()
			end

			if self.OwnerSet and self.OwnerSet.SlotUnderCursor == self then
				self.OwnerSet.SlotUnderCursor = nil
			end

			if g_SlotSetManager.StartDragPos and love.mouse.isDown( "l" ) then --TODO add mouse api	
				g_SlotSetManager:StartDrag( self )
			else
				g_SlotSetManager.StartDragPos = nil
			end
		end

		self.IsMouseOver = IsMouseOver
	end
end


function obj_slot_class:Draw( Offset )
	local Pos = { Offset[ 1 ] + self.Pos[ 1 ], Offset[ 2 ] + self.Pos[ 2 ] }
	
	if not self.Bg or not self.Bg.Image then
		if self.IsMouseOver then
			love.graphics.setColor( 79, 99, 99, 185 )
		else
			love.graphics.setColor( 99, 99, 99, 185 )
		end
		love.graphics.rectangle( "fill", Pos[ 1 ], Pos[ 2 ], self.Size[ 1 ], self.Size[ 2 ] )
	end

	love.graphics.setColor( 255, 255, 255, 255 )
	if self.Bg and self.Bg.Image then
		
		love.graphics.draw( self.Bg.Image, self.Bg.Quad, Pos[ 1 ], Pos[ 2 ], 0, 1 ,1 )
	end

	if self.Icon and self.Icon.Image then
		love.graphics.draw( self.Icon.Image, self.Icon.Quad, Pos[ 1 ], Pos[ 2 ], 0, 1 ,1 )
	end
end

