MAP_TYPE_NONE = 0
MAP_TYPE_BG_SPRITE = 1
MAP_TYPE_OBJ_SPRITE = 2
MAP_TYPE_SERV_RECT = 3
MAP_TYPE_SUB_LAYER = 4
MAP_TYPE_TRIGGER_RECT = 5


map_layer = class( function( self, Pos, Size )
	self.Name = "map_layer"
	self.Pos = Pos
	self.Size = Size
	self.Visible = 1
	self.ObjTable = {}

	self.EditorVisible = 1	
end)


map_obj = class( function( self, Type )
	self.Name = "no name"
	if Type == MAP_TYPE_BG_SPRITE then self.Name = "map_bg_sprite"  end
	if Type == MAP_TYPE_OBJ_SPRITE then self.Name = "map_obj"  end
	if Type == MAP_TYPE_SERV_RECT then self.Name = "map_rect"  end	
	if Type == MAP_TYPE_GROUP then self.Name = "map_group"  end	
	if Type == MAP_TYPE_SUB_LAYER then self.Name = "map_sub_layer"  end	
	if Type == MAP_TYPE_TRIGGER_RECT then self.Name = "map_trigger"; self.TriggerType = "none"; end	
	
	self.Type = Type
	self.Pos = { 0, 0 }
	self.Size = { 0, 0 }
	self.Rotate = 0
	self.Visible = 1
	--self.Text = ""	
	self.TexName = ""
	self.SubTexName = ""	
	self.TexRect = { 0, 0, 0, 0 }	
	self.Childs = {}
	self.ServRect = nil
	--self.Parent = nil
	
	self.EditorVisible = 1
	self.EditorShowChildsInList = 1
	self.EditorQuad = nil	 
end)


function map_obj:OnObj( X, Y )
	if X >= self.Pos[ 1 ] and X < self.Pos[ 1 ] + self.Size[ 1 ] and Y >= self.Pos[ 2 ] and Y < self.Pos[ 2 ] + self.Size[ 2 ] then
		return true
	else
		return false
	end
end


function map_obj:GetTypePrefix()
	if self.Type == MAP_TYPE_BG_SPRITE then return "BG:"  end
	if self.Type == MAP_TYPE_OBJ_SPRITE then return "OS:"  end
	if self.Type == MAP_TYPE_SERV_RECT then return "RS:"  end	
	if self.Type == MAP_TYPE_GROUP then return "GR:"  end	
	if self.Type == MAP_TYPE_SUB_LAYER then return "SL:"  end
	if self.Type == MAP_TYPE_TRIGGER_RECT then return "TR:"  end
	return "Uncnow:"		
end


function map_layer:GetTypePrefix()	
	return "ML:"		
end