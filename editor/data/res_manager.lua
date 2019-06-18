--imported from t_project

resource_manager = class(function( self, res_patch )
	self.ImageCount = 0
	self.ImagePool = {}
end)


function resource_manager:GetImageCount()
	return self.ImageCount
end


function resource_manager:GetImage( Name )
	if self.ImagePool[ Name ] == nil then
		self.ImagePool[ Name ] = love.graphics.newImage( Name )
		self.ImageCount = self.ImageCount + 1
		return self.ImagePool[ Name ]
	else
		return self.ImagePool[ Name ]
	end
end


function resource_manager:GethQuad( Image, Rect )
	local tilesetW, tilesetH = Image:getWidth(), Image:getHeight()
	return love.graphics.newQuad( Rect[ 1 ],  Rect[ 2 ], Rect[ 3 ], Rect[ 4 ], tilesetW, tilesetH )
end


function resource_manager:GetImageWithQuad( Name, Rect )

	if self.ImagePool[ Name ] == nil then
		self.ImagePool[ Name ] = love.graphics.newImage( Name )
		self.ImageCount = self.ImageCount + 1
	end
	local tilesetW, tilesetH = self.ImagePool[ Name ]:getWidth(), self.ImagePool[ Name ]:getHeight()
	return self.ImagePool[ Name ], love.graphics.newQuad( Rect[ 1 ],  Rect[ 2 ], Rect[ 3 ], Rect[ 4 ], tilesetW, tilesetH)
end


function resource_manager:GetSubImage( Name )

	if Res_table[ Name ] == nil then
		print( "no SubImage:" .. Name )
	else
		return self.ImagePool[ Name ]
	end
end


function resource_manager:GetImageEx( NameAndRectTable )
	local Result	= {}
	Result.Image	= self:GetImage( NameAndRectTable.Name )
	Result.Quad		= self:GethQuad( Result.Image, NameAndRectTable.Rect )
	Result.Width	= NameAndRectTable.Rect[ 3 ]
	Result.Height	= NameAndRectTable.Rect[ 4 ]
	if NameAndRectTable.Pivot ~= nil then
		Result.Pivot = NameAndRectTable.Pivot
	end

	return Result
end
