
function LogInFile( Text )
	if Text == nil then Text = "NIL" end

	local FileName = "log.txt"
	local LogFile,err = io.open( string.gsub( FileName, '/', '\\' ),"a"  )

	LogFile:write( Text .. "\n" )
	LogFile:close()
end


function LogField( Space, Field, Value, StopReqursive )
	for i = 1, #StopReqursive do
		if Value == StopReqursive[ i ] then
			LogInFile( Space .. Field .. " = { reqursive table }," )
			return
		end
	end
	
	if type( Value ) == "string" then
		LogInFile( Space .. Field .. " = \"" .. Value .. "\"," )
	elseif type( Value ) == "boolean" then
		local BoolVal = "false"
		if Value then BoolVal = "true" end
		LogInFile( Space .. Field .. " = " .. BoolVal .. "," )
	elseif type( Value ) ~= "table" then
		LogInFile( Space .. Field .. " = " .. Value .. "," )
	else
		table.insert( StopReqursive, Value )
		LogInFile( Space .. Field .. " = {" )
		for i, v in pairs( Value ) do LogField( "	"..Space, i, v, StopReqursive ) end
		LogInFile( Space .. "}," )
	end
end


function Log( Var )
	if type( Var ) == "nil" then
		LogInFile( "nil" )
	elseif type( Var ) ~= "table" then
		LogInFile( tostring( Var ) )
	else
		local StopReqursive = { Var }
		LogInFile( "{" )
		for i, v in pairs( Var ) do LogField( "	", i, v, StopReqursive ) end
		LogInFile( "}" )
	end
end


function FindText( Str, Text )
	if string.find( Str, Text ) ~= nil then
		local StartS = 0
		local EndS = 0
		StartS, EndS = string.find( Str, Text )			
		return string.sub( Str, StartS )
	else
		return nil
	end
end

---FS----
function DelSpase(mask)
	--return string.gsub(mask, ' ', '_')
	return "\"" .. mask .. "\""
end


function os.copyFile(mask)
	--print("copy "..      string.gsub(mask, '/', '\\'))
	os.execute("copy "..      string.gsub(mask, '/', '\\'))  
end


function os.createDir(path)
	os.execute("mkdir "..string.gsub(path, '/', '\\'))
end


function os.deleteFiles(mask)
	os.execute("del "..string.gsub(mask, '/', '\\'))
end


function table.val_to_str ( v )
   if "string" == type( v ) then
      v = string.gsub( v, "\n", "\\n" )
      if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
         return "'" .. v .. "'"
      end
      return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
   end
   return "table" == type( v ) and table.tostring( v ) or tostring( v )
end


function table.key_to_str ( k )
   if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
      return k
   end
   return "[" .. table.val_to_str( k ) .. "]"
end


function cr_lines(s)
    return s:gsub('\r\n?', '\n'):gmatch('(.-)\n')
end


function cr_file_lines(filename)
    local f = io.open(filename, 'rb')
    local s = f:read('*a')
    f:close()
    return cr_lines(s)
end


-- ѕреобразование таблицы или массива в текстовое представление в соответствии с синтаксисом €зыка lua
function table.tostring( tbl )
   local result, done = {}, {}
   for k, v in ipairs( tbl ) do
      table.insert( result, table.val_to_str( v ) )
      done[ k ] = true
   end
   for k, v in pairs( tbl ) do
      if not done[ k ] then
         table.insert( result, table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
      end
   end
   return "{" .. table.concat( result, "," ) .. "}"
end

-- —охранение таблицы или массива в файл
function table.save(tbl,filename)
   local f,err = io.open(string.gsub(filename, '/', '\\'),"w")
   if not f then
      return nil,err
   end
   f:write(table.tostring(tbl))
   f:close()
   return true
end

-- „тение таблицы из файла в массива или таблицу
function table.read(filename)
   local f,err = io.open(string.gsub(filename, '/', '\\'),"r")
   if not f then
      return nil,err
   end
   local tbl = assert(loadstring("return " .. f:read("*a")))
   f:close()
   return tbl()
end

-- for sotring
function pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
    end


function NumToBool( val )
	if val == 0 then return false end
	return true
end


function BoolToNum( val )
	if val == true then
		return 1
	else
		return 0
	end
end


function RotatePoint( Point, Angle, AxisPoint )
	if not AxisPoint then AxisPoint = { 0, 0 } end
	
	local X = math.cos( Angle ) * ( Point[ 1 ] - AxisPoint[ 1 ] ) - math.sin( Angle ) * ( Point[ 2 ] - AxisPoint[ 2 ] ) + AxisPoint[ 1 ]
	local Y = math.sin( Angle ) * ( Point[ 1 ] - AxisPoint[ 1 ] ) + math.cos( Angle ) * ( Point[ 2 ] - AxisPoint[ 2 ] ) + AxisPoint[ 2 ]
	return { X, Y }
end


function GetRectFromRotatedObj( Obj )
	if Obj.Rotate == nil or Obj.Rotate == 0 then 
		return nil 
	end
	
	local P = {}
	P[ 1 ] = { 0, 0 }
	P[ 2 ] = RotatePoint( { Obj.Size[ 1 ], 0 }, Obj.Rotate )
	P[ 3 ] = RotatePoint( { Obj.Size[ 1 ], Obj.Size[ 2 ] }, Obj.Rotate )
	P[ 4 ] = RotatePoint( { 0, Obj.Size[ 2 ] }, Obj.Rotate )
	
	MinMaxXY = { 0, 0, 0, 0 }
	for I = 1, #P do
		local Point = P[ I ]
		if MinMaxXY[ 1 ] > Point[ 1 ] then MinMaxXY[ 1 ] = Point[ 1 ] end
		if MinMaxXY[ 2 ] < Point[ 1 ] then MinMaxXY[ 2 ] = Point[ 1 ] end
		if MinMaxXY[ 3 ] > Point[ 2 ] then MinMaxXY[ 3 ] = Point[ 2 ] end
		if MinMaxXY[ 4 ] < Point[ 2 ] then MinMaxXY[ 4 ] = Point[ 2 ] end
	end

	local Rect = {	math.floor( MinMaxXY[ 1 ] + Obj.Pos[ 1 ] ),
					math.floor( MinMaxXY[ 3 ] + Obj.Pos[ 2 ] ),
					math.ceil( MinMaxXY[ 2 ] - MinMaxXY[ 1 ] ),
					math.ceil( MinMaxXY[ 4 ] - MinMaxXY[ 3 ] ) }
	return Rect
end


function deepcopy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[deepcopy(k, s)] = deepcopy(v, s) end
  return res
end