
local TcDataTypeLenghtByte = {}
	TcDataTypeLenghtByte[ "8bit" ] = 2
	TcDataTypeLenghtByte[ "8sign_8bit" ] = 4
	TcDataTypeLenghtByte[ "16bit" ] = 4
	TcDataTypeLenghtByte[ "8sign_16bit" ] = 5
	TcDataTypeLenghtByte[ "Id" ] = 6


function DecToHex( IN, ByteCount )
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end

	if ByteCount == nil then
		ByteCount = 2
	else
		ByteCount = ByteCount * 2
	end	

	if #OUT < ByteCount then
		OUT = string.rep( "0", ByteCount - #OUT ) .. OUT
	end
	
    return OUT
end


function DecToHexS( IN, ByteCount )
	if IN < 0 then
		return "X" .. DecToHex( -IN, ByteCount )
	else
		return "Y" .. DecToHex( IN, ByteCount )
	end
end


function HexToDec( IN )
	if string.sub( IN, 1, 1 ) == "X" then
		return -tonumber( string.sub( IN, 2, -1 ), 16 )
	elseif string.sub( IN, 1, 1 ) == "Y" then
		return tonumber( string.sub( IN, 2, -1 ), 16 )
	else
		return tonumber( IN, 16 )
	end
end


function GetDataWithoutCMD( Data, Type )
	local Ofs = 3
	local Res = {}
		
	for I = 1, #Type do
		local Tp = Type[ I ]
		if Type[ I ] == "Id" then
			Res[ I ] = string.sub( Data, Ofs, Ofs + TcDataTypeLenghtByte[ "Id" ] - 1 )			
		else			
			Res[ I ] = HexToDec( string.sub( Data, Ofs, Ofs + TcDataTypeLenghtByte[ Tp ] - 1 ) )	
		end
		Ofs = Ofs + TcDataTypeLenghtByte[ Tp ]
	end

	return Res
end


Net = {

	host = "127.0.0.1", --local
	--host = "192.168.0.110", --shinne noir
	host = "193.254.225.11", --emp serv


	port = 8082,
	socket = require("socket"),
	tcp = assert(socket.tcp()),
	
	Connect = function()
		Net.tcp:settimeout( 0 )
		Net.tcp:setoption('tcp-nodelay', true )
		Net.tcp:connect( Net.host, Net.port );
	end,

	CloseConnect = function()
		Net.tcp:close()
	end,

	RecvServerData = function()
		local s, status, partial = Net.tcp:receive()
		return s
	end,

	SendServerData = function( Data )
		Net.tcp:send( Data .. "\n" );
	end,

	SendToServer = function( Cmd, Data )
		Net.tcp:send( DecToHex( Cmd ) .. Data .. "\n" );
	end,
	}