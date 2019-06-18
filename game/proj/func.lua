


function CheckPointIn( Point, Pos, Size )
	if ( Point[ 1 ] >= Pos[ 1 ] ) and ( Point[ 1 ] < Pos[ 1 ] + Size[ 1 ] ) and
	   ( Point[ 2 ] >= Pos[ 2 ] ) and ( Point[ 2 ] < Pos[ 2 ] + Size[ 2 ] ) then
	   return 1
   else
	   return 0
   end
end


function CheckPointIn2( Point1, Point2, Pos, Size )
	if CheckPointIn( Point1, Pos, Size ) == 1 and CheckPointIn( Point2, Pos, Size ) == 1 then
		return 1
	else
		return 0
	end
end


function CheckPointInRect( Point, Rect )
	if ( Point[ 1 ] >= Rect[ 1 ] ) and ( Point[ 1 ] < Rect[ 1 ] + Rect[ 3 ] ) and
	   ( Point[ 2 ] >= Rect[ 2 ] ) and ( Point[ 2 ] < Rect[ 2 ] + Rect[ 4 ] ) then
	   return 1
   else
	   return 0
   end
end


function OutOfRect( Rect1, Rect2 )
	if Rect1[ 1 ] > Rect2[ 1 ] + Rect2[ 3 ] or Rect2[ 1 ] > Rect1[ 1 ] + Rect1[ 3 ] 
		or Rect1[ 2 ] > Rect2[ 2 ] + Rect2[ 4 ] or Rect2[ 2 ] > Rect1[ 2 ] + Rect1[ 4 ] then		
		return true
	end	
	return false
end


function RotatePoint( Point, Angle, AxisPoint )
	if not AxisPoint then AxisPoint = { 0, 0 } end
	
	local X = math.cos( Angle ) * ( Point[ 1 ] - AxisPoint[ 1 ] ) - math.sin( Angle ) * ( Point[ 2 ] - AxisPoint[ 2 ] ) + AxisPoint[ 1 ]
	local Y = math.sin( Angle ) * ( Point[ 1 ] - AxisPoint[ 1 ] ) + math.cos( Angle ) * ( Point[ 2 ] - AxisPoint[ 2 ] ) + AxisPoint[ 2 ]
	return { X, Y }
end


function GetMin( A, B )
	if type( A ) ~= "table" then
		return math.min( A, B )
	else
		local Result = {}
		for i = 1, #A do 
			Result[ i ] = GetMin( A[ i ], B[ i ] )
		end
		return Result
	end
end


function GetMax( A, B )
	if type( A ) ~= "table" then
		return math.max( A, B )
	else
		local Result = {}
		for i = 1, #A do 
			Result[ i ] = GetMax( A[ i ], B[ i ] )
		end
		return Result
	end
end


function Add( A, B )
	if type( A ) == "table" then
		if type( B ) == "table" then
			local Result = {}
			for i = 1, #A do 
				Result[ i ] = Add( A[ i ], B[ i ] )
			end
			return Result
		else
			local Result = {}
			for i = 1, #A do 
				Result[ i ] = Add( A[ i ], B )
			end
			return Result
		end
	else
		if type( B ) == "table" then
			local Result = {}
			for i = 1, #B do 
				Result[ i ] = Add( A, B[ i ] )
			end
			return Result
		else
			return Default( A, 0 ) + Default( B, 0 )
		end
	end
end


function Sub( A, B )
	if type( A ) == "table" then
		if type( B ) == "table" then
			local Result = {}
			for i = 1, #A do 
				Result[ i ] = Sub( A[ i ], B[ i ] )
			end
			return Result
		else
			local Result = {}
			for i = 1, #A do 
				Result[ i ] = Sub( A[ i ], B )
			end
			return Result
		end
	else
		if type( B ) == "table" then
			local Result = {}
			for i = 1, #B do 
				Result[ i ] = Sub( A, B[ i ] )
			end
			return Result
		else
			return Default( A, 0 ) - Default( B, 0 )
		end
	end
end


function Mul( A, B )
	if type( A ) == "table" then
		if type( B ) == "table" then
			local Result = {}
			for i = 1, #A do 
				Result[ i ] = A[ i ] * B[ i ]
			end
			return Result
		else
			local Result = {}
			for i = 1, #A do 
				Result[ i ] = A[ i ] * B
			end
			return Result
		end
	else
		if type( B ) == "table" then
			local Result = {}
			for i = 1, #B do 
				Result[ i ] = A * B[ i ]
			end
			return Result
		else
			return A * B
		end
	end
end


function Div( A, B )
	if type( A ) == "table" then
		if type( B ) == "table" then
			local Result = {}
			for i = 1, #A do 
				Result[ i ] = A[ i ] / B[ i ]
			end
			return Result
		else
			local Result = {}
			for i = 1, #A do 
				Result[ i ] = A[ i ] / B
			end
			return Result
		end
	else
		if type( B ) == "table" then
			local Result = {}
			for i = 1, #B do 
				Result[ i ] = A / B[ i ]
			end
			return Result
		else
			return A / B
		end
	end
end


function GetMinSize( PosSize )
	local min = { 0, 0 }
	local max = { 0, 0 }
	
	for i = 1, #PosSize do 
		local A = PosSize[ i ].Pos
		local B = Add( PosSize[ i ].Pos, PosSize[ i ].Size )
		
		if i == 1 then
			min = A
			max = B
		else
			min = GetMin( min, B )
			max = GetMax( min, B )
		end
	end
	
	return { Min = min, Size = Sub( max, min ) }
end


function Equal( A, B )
	if type( A ) ~= "table" then
		return A == B
	end

	if #A ~= #B then
		return 0
	end
	
	for i = 1, #A do 
		if Equal( A[ i ], B[ i ] ) == 0 then
			return 0
		end
	end

	return 1
end


function Clamp( X, Min, Max )
	if X < Min then return Min end
	if X > Max then return Max end
	return X
end


function ClampNS( X, A, B )-- no sign
	if A > B then
		Max = A
		Min = B
	else
		Max = B
		Min = A
	end
	if X < Min then return Min end
	if X > Max then return Max end
	return X
end


function Default( Src, Default )
	if Src ~= nil then
		return Src
	end
	return Default
end


function Dot( A, B )
	return A[ 1 ] * B[ 1 ] + A[ 2 ] * B[ 2 ] + A[ 3 ] * B[ 3 ]
end


function Lerp( A, B, X )
	return  A + ( B - A ) * X
end


function LineStep( AX, AY, BX, BY, X )
	if X <= AX then
		return AY
	end
	if X >= BX then
		return BY
	end
	return Lerp( AY, BY,  ( X - AX  ) / ( BX  - AX  ) )
end


function Sign( X )
	if X < 0 then
		return -1
	elseif X > 0 then
		return 1
	end
	return 0
end


function Not( X )
	if X ~= 0 then
		return 0
	end
	return 1
end


function SecondsToHMS( Sec )
	local Hours   = math.floor( Sec / 3600 )
	local Minutes = math.floor( ( Sec - Hours * 3600 ) / 60 )
	local Seconds = math.floor( Sec - Hours * 3600 - Minutes * 60 )
	return Hours, Minutes, Seconds
end



