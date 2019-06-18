from protocol import *
from helper_class import *

class storage_slot:
    ConfigInd = 0
    Count = 0    
  

class storage:
    Slots = None    
    Owner = None
    Type = None
    ChangeSlotCallback = None    # ( Index, Slot )


    def __init__( self, Owner, Type, Size ):
        self.Owner = Owner
        self.Type = Type
        self.Slots = [ storage_slot() for I in range( Size ) ]
   

    def SetChangeSlotCallback( self, Func ):
        self.ChangeSlotCallback = Func       
     

    def GetSlot( self, Index ):
        ASSERT( Index > 0 )
        ASSERT( Index <= len( self.Slots ) )
        return self.Slots[ Index - 1 ]      # 1 index = slot[ 0 ]
    

    def SendSlotToOwner( self, Index ):
        ASSERT( Index > 0 )
        ASSERT( Index <= len( self.Slots ) )
        self.Owner.SendToClient( tc.STORAGE_SLOT, 
                                DecToHex( self.Type, 1 ) +
                                DecToHex( Index, 1 ) +
                                DecToHex( self.Slots[ Index - 1 ].ConfigInd, 1 ) +
                                DecToHex( self.Slots[ Index - 1 ].Count, 1 ) )


    def PushToSlot( self, Index, Slot ):
        ASSERT( Index > 0 )
        ASSERT( Index <= len( self.Slots ) )
        self.Slots[ Index - 1 ] = Slot
        self.SendSlotToOwner( Index )
        if ( self.ChangeSlotCallback ):
            self.ChangeSlotCallback( Index, Slot )


    def ClearSlot( self, Index ):
        ASSERT( Index > 0 )
        ASSERT( Index <= len( self.Slots ) )
        self.Slots[ Index - 1 ] = storage_slot()
        self.SendSlotToOwner( Index )
        if ( self.ChangeSlotCallback ):
            self.ChangeSlotCallback( Index, self.Slots[ Index - 1 ] )


    def SendAllToOwner( self ):
        for I in range( len( self.Slots ) ):
            self.SendSlotToOwner( I + 1 )