GUI_TYPE_NONE = 0
GUI_TYPE_WINDOW = 1
GUI_TYPE_SPRITE = 2
GUI_TYPE_BUTTON = 3
GUI_TYPE_TEXT = 4

window_base = class( function( self, Type )
	self.Name = "NoName" 
	self.Type = Type
	self.Pos = { 0, 0 }
	self.Size = { 0, 0 }
	self.Visible = 1
	self.Text = ""
	self.TextAlign = 0
	self.TextFont = nil
	self.TextColor = { 0, 0, 0, 255 } --rgba
	self.TexName = ""
	self.SubTexName = ""
	self.TexRect = { 0, 0, 0, 0 }
	self.Childs = {}
	self.Parent = nil
	
	self.EditorVisible = 1
	self.EditorQuad = nil	 
end)


function window_base:GetTypeString()
	if self.Type == GUI_TYPE_WINDOW then
		return "[w]"
	elseif self.Type == GUI_TYPE_SPRITE then
		return "[s]"
	elseif self.Type == GUI_TYPE_BUTTON then
		return "[b]"
	elseif self.Type == GUI_TYPE_TEXT then
		return "[t]"
	end
end


function window_base:InWindow( X, Y )
	if X >= self.Pos[ 1 ] and X < self.Pos[ 1 ] + self.Size[ 1 ] and Y >= self.Pos[ 2 ] and Y < self.Pos[ 2 ] + self.Size[ 2 ] then
		return true
	else
		return false
	end
end


function window_base:GetChildsTree( ResultArrayPtr, StartOffset )
	local Result = { self, StartOffset }
	table.insert( ResultArrayPtr, Result )

	if #self.Childs == 0 then
		return nil
	end

	for I = 1, #self.Childs do
		self.Childs[ I ]:GetChildsTree( ResultArrayPtr, StartOffset + 1 )
	end
end


function window_base:PushChild( Child )
	table.insert( self.Childs, Child )
	Child.Parent = self
end


function window_base:SetMetatablesForChild()	
	if #self.Childs == 0 then
		return
	end
	
	for I = 1, #self.Childs do
		setmetatable( self.Childs[ I ], getmetatable( self ) )
		self.Childs[ I ]:SetMetatablesForChild()
	end
end


function window_base:SetParentsForChild()	
	if #self.Childs == 0 then
		return
	end
	
	for I = 1, #self.Childs do
		self.Childs[ I ].Parent = self
		self.Childs[ I ]:SetParentsForChild()
	end
end