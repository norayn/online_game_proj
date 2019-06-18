Log = {}


Log.Pos = { 10, 0 }
Log.VisibleOnDisplayCount = 45
Log.NextLineOffsetY = 14
Log.ShowBuffer = {}

Log.Show = function( Text )	
	if Text ~= nil then
		table.insert ( Log.ShowBuffer, g_ClientFrame .. " " .. Text )
	else
		table.insert ( Log.ShowBuffer, "nill" )
	end
	
	if #Log.ShowBuffer > Log.VisibleOnDisplayCount then
		table.remove ( Log.ShowBuffer , 1 )
	end
	--Logf( Text )
end

Log.Render = function()
	love.graphics.setColor( 199, 199, 199, 185 )
	for I = 1, #Log.ShowBuffer do
		love.graphics.print( Log.ShowBuffer[ I ], Log.Pos[ 1 ], I * Log.NextLineOffsetY + Log.Pos[ 2 ] )
	end
end


EventLog = {}

EventLog.Pos = { 10, 50 }
EventLog.VisibleOnDisplayCount = 10
EventLog.NextLineOffsetY = 12
EventLog.ShowBuffer = {}

EventLog.Show = function( Text )	
	if Text ~= nil then
		table.insert ( EventLog.ShowBuffer, Text )
	else
		table.insert ( EventLog.ShowBuffer, "nill" )
	end
	
	if #EventLog.ShowBuffer > EventLog.VisibleOnDisplayCount then
		table.remove ( EventLog.ShowBuffer , 1 )
	end
end

EventLog.Render = function()
	love.graphics.setColor( 202, 222, 222, 185 )
	for I = 1, #EventLog.ShowBuffer do
		love.graphics.print( EventLog.ShowBuffer[ I ], EventLog.Pos[ 1 ], I * EventLog.NextLineOffsetY + EventLog.Pos[ 2 ] )
	end
end