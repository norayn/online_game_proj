require "class"
require "res/res_table"

resource_manager = class(function( self, res_patch )
	self.ImageCount = 0
	self.ImagePool = {}
	self.AtlasTable = {}
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


function resource_manager:LoadAtlas( Patch, FileName )
	local MODE_NAME, MODE_PRESTART, MODE_HEAD, MODE_DATA = 1, 2, 3, 4
	
	--local FulName = g_ProjPatch .. Patch .. FileName
	local FulName = Patch .. FileName
	assert( type( FulName ) == 'string', 'Parameter "fileName" must be a string.' )
	assert( love.filesystem.isFile( FulName ), 'Error loading file : ' .. FulName )
	local Data = {}
	local Mode = MODE_NAME

	local ImageName = ""
	local LastHeadName = ""

	for Line in love.filesystem.lines ( FulName ) do	
		
		if Mode == MODE_NAME then
			if Line:find( ".png" ) then
				ImageName = Line
				Mode = MODE_PRESTART				
			end
		elseif Mode == MODE_PRESTART then
			if Line:find( "repeat:" ) then				
				Mode = MODE_HEAD				
			end
		elseif Mode == MODE_HEAD then
			Data[ Line ] = { Rect = {} }
			LastHeadName = Line
			Mode = MODE_DATA
		elseif Mode == MODE_DATA then
			if Line:find( "index:" ) then
				Mode = MODE_HEAD
			elseif Line:find( "xy:" ) then
				S1, E1 = Line:find( "xy:" )
				S2, E2 = Line:find( ", " )
				Data[ LastHeadName ].Rect[ 1 ] = tonumber( Line:sub( E1 + 1, S2 - 1 ) )
				Data[ LastHeadName ].Rect[ 2 ] = tonumber( Line:sub( S2 + 1 ) )
			elseif Line:find( "size:" ) then
				S1, E1 = Line:find( "size:" )
				S2, E2 = Line:find( ", " )
				Data[ LastHeadName ].Rect[ 3 ] = tonumber( Line:sub( E1 + 1, S2 - 1 ) )
				Data[ LastHeadName ].Rect[ 4 ] = tonumber( Line:sub( S2 + 1 ) )
			end
		end
	end
	
	assert( self.AtlasTable[ ImageName ] == nil, ImageName .. ' already in atlas table' )
	
	self.AtlasTable[ ImageName ] = {}		
	self.AtlasTable[ ImageName ].Image = self:GetImage( Patch .. ImageName )

	for Key, Val in pairs( Data ) do
		Data[ Key ].Quad = self:GethQuad( self.AtlasTable[ ImageName ].Image, Data[ Key ].Rect )
	end

	self.AtlasTable[ ImageName ].SubTexTable = Data
end


function resource_manager:LoadAtlasFromSubTex( Patch, ImageName )

	assert( type( Patch ) == 'string' and type( ImageName ) == 'string', 'Parameter "Patch" and "ImageName" must be a string.' )
	
	local Data = {}
	local SubTexTableFileName = string.sub( ImageName, 1, -5 ) .. ".tex"

	love.filesystem.load( Patch .. SubTexTableFileName )()
	assert( SubTex, "no SubTex" )

	for Key, Val in pairs( SubTex ) do
		Data[ Key ] = {}
		Data[ Key ].Rect = {}
		Data[ Key ].Rect[ 1 ] = Val.Coord[ 1 ]
		Data[ Key ].Rect[ 2 ] = Val.Coord[ 2 ]
		Data[ Key ].Rect[ 3 ] = Val.Coord[ 3 ]
		Data[ Key ].Rect[ 4 ] = Val.Coord[ 4 ]
	end	
	SubTex = nil

	assert( self.AtlasTable[ ImageName ] == nil, ImageName .. ' already in atlas table' )
	
	self.AtlasTable[ ImageName ] = {}		
	self.AtlasTable[ ImageName ].Image = self:GetImage( Patch .. ImageName )
	
	for Key, Val in pairs( Data ) do
		Data[ Key ].Quad = self:GethQuad( self.AtlasTable[ ImageName ].Image, Data[ Key ].Rect )
	end

	self.AtlasTable[ ImageName ].SubTexTable = Data
end


function resource_manager:HasAtlas( Name )
	assert( type( Name ) == 'string', 'Parameter "Name" must be a string.' )
	if self.AtlasTable[ Name ] == nil then
		return false
	else
		return true
	end
end


function resource_manager:GetAtlas( Name )
	assert( self.AtlasTable[ Name ], Name .. ' atlas not found' )
	return self.AtlasTable[ Name ]
end