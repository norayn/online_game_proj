local Suit = require 'lib.suit'

local StorageEquip = {}

local WndPos = { 100, 300 }
local WndSize = { 300, 400 }

local EquipCharData = {}

function Gui:InitEquipment()	
	local ICON_SIZE = { 72, 72 }
	
	EquipCharData.SelectChar = character_class()	
	EquipCharData.SelectChar.LoadScale = 0.2   -- original size =x5	
	EquipCharData.SelectChar:SkeletonInit( "res/main_char_1", "MainChar1" )
	EquipCharData.SelectChar:SetPos( { WndPos[ 1 ] + 100, WndPos[ 2 ] + 220 } )

	local Result = slot_set_class()
	Result:CreateGrid({
		Row = 4,
		Col = 1,
		Size = ICON_SIZE,
	})
	Result.Pos = { WndPos[ 1 ] + 210, WndPos[ 2 ] + 30 }
	Result.StorageType = storage_type.EQUIP
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
	
	StorageEquip = Result
end


function Gui:EquipmentPushConfigToSlot( SlotIndex, ConfigIndex )
	StorageEquip:PushConfigToSlot( SlotIndex, ConfigIndex )
	EquipCharData.SelectChar:SetClothConf( SlotIndex, ConfigIndex )	
end


function Gui:UpdateEquipment( Delta )
	local Pos = { WndPos[ 1 ] + WndSize[ 1 ] - 22, WndPos[ 2 ] + 2 }
	if Suit.Button( "X", { id = "b_close_equip" }, Pos[ 1 ], Pos[ 2 ], 20, 20 ).hit then
		Gui:CloceEquipment()
	end

	EquipCharData.SelectChar:Update( Delta )	
end


function Gui:DrawEquipment()
	love.graphics.setColor( 33, 33, 33, 205 )
	love.graphics.rectangle( "fill", WndPos[ 1 ], WndPos[ 2 ], WndSize[ 1 ], WndSize[ 2 ] )
	
	StorageEquip:Draw()
	EquipCharData.SelectChar:Draw()

	love.graphics.print( "Equipment", WndPos[ 1 ] + 4, WndPos[ 2 ] + 4 )
end


function Gui:OpenEquipment()
	StorageEquip:SetUpdateFlag( true )
	Gui.ShowEquip = true
end


function Gui:CloceEquipment()
	StorageEquip:SetUpdateFlag( false )
	Gui.ShowEquip = false
end



