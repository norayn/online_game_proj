require "class"

--local Utf8 = require 'utf8'


config_set = class( function( self )
	self.Configs = {}
    self.ConfigNames = {}
    self.ConfigNameToIndexTab = {} 

	Logf( 'load configs------' )
	local Patch = "res/items/"
	LoadChunkData = love.filesystem.load( Patch .. 'items.lua' ) -- загружает кусок
	LoadChunkData() -- выполняет кусок
		
	for I = 1, #configs_list do
		Logf( 'load ' .. '[' .. I .. ']' .. configs_list[ I ]  )
		LoadChunkData = love.filesystem.load( Patch .. configs_list[ I ] .. '.lua' )
		LoadChunkData()
		self.Configs[ I ] = item_config
		self.ConfigNames[ I ] = configs_list[ I ]
		self.ConfigNameToIndexTab[ configs_list[ I ] ] = I
	end
	Logf( "load configs done, count: " .. #self.Configs )
end)


function config_set:GetByIndex( Index )
	assert( Index > 0 )
	assert( Index <= #self.Configs )
	return self.Configs[ Index ]	
end


function config_set:GetByName( Name )
	return self.Configs[ self.ConfigNameToIndexTab[ Name ] ]
end


function config_set:GetNameByIndex( Index )
	assert( Index > 0 )
	assert( Index <= #self.Configs )
	return self.ConfigNames[ Index ]
end


function config_set:GetIndexByName( Name )
	return self.ConfigNameToIndexTab[ Name ]
end
