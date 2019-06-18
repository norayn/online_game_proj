local Suit = require 'lib.suit'

local StorageInv = {}


function Gui:InitInventory()
	local ICON_SIZE = { 72, 72 }

	local Result = slot_set_class()
	Result:CreateGrid({
		Row = 4,
		Col = 3,
		Size = ICON_SIZE,
	})
	Result.Pos = { 420, 300 }
	Result.StorageType = storage_type.INVENTORY
	Result.OnStopDrag = function( Info )
		--Info.StartSlot
		--Info.StopSlot
		--Info.TargetSlotIsEmty
		Logf( "OnStopDrag start ind " .. Info.StartSlot.Index )
		Logf( "OnStopDrag stop ind " .. Info.StopSlot.Index )

		assert( Info.StartSlot.OwnerSet.StorageType )
		assert( Info.StopSlot.OwnerSet.StorageType )
		assert( Info.StartSlot.Index )
		assert( Info.StopSlot.Index ) 
		assert( Info.StartSlot.ItemCount )
		
		Net.SendToServer( ts.DRAG_SLOT, 
			DecToHex( Info.StartSlot.OwnerSet.StorageType ) .. 
			DecToHex( Info.StopSlot.OwnerSet.StorageType ) .. 
			DecToHex( Info.StartSlot.Index ) .. --sever ind 0 = client ind 1
			DecToHex( Info.StopSlot.Index ) .. 
			DecToHex( Info.StartSlot.ItemCount ) )
	end

	Result.WndPos = { Result.Pos[ 1 ] - 5, Result.Pos[ 2 ] - 25 }
	Result.WndSize = { ( ICON_SIZE[ 1 ] + 2 ) * Result.SlotCols + 10, ( ICON_SIZE[ 2 ] + 2 ) * Result.SlotRows + 30 }

	StorageInv = Result
end


function Gui:InventoryPushConfigToSlot( SlotIndex, ConfigIndex )
	StorageInv:PushConfigToSlot( SlotIndex, ConfigIndex )
end


function Gui:UpdateInventory()
	local Pos = { StorageInv.WndPos[ 1 ] + StorageInv.WndSize[ 1 ] - 22, StorageInv.WndPos[ 2 ] + 2 }
	if Suit.Button( "X", { id = "b_close_inventory" }, Pos[ 1 ], Pos[ 2 ], 20, 20 ).hit then
		Gui:CloceInventory()
	end
end


function Gui:DrawInventory()
	local Pos = StorageInv.WndPos
	local Size = StorageInv.WndSize
	love.graphics.setColor( 33, 33, 33, 205 )
	love.graphics.rectangle( "fill", Pos[ 1 ], Pos[ 2 ], Size[ 1 ], Size[ 2 ] )
	
	StorageInv:Draw()
	love.graphics.print( "Inventory", Pos[ 1 ] + 4, Pos[ 2 ] + 4 )
end


function Gui:OpenInventory()
	StorageInv:SetUpdateFlag( true )
	Gui.ShowInventory = true
end


function Gui:CloceInventory()
	StorageInv:SetUpdateFlag( false )
	Gui.ShowInventory = false
end



