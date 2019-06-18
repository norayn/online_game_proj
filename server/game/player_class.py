
from datetime import datetime

from helper_class import *
from net_class import net
from net_class import DecToHex
from net_class import HexToDec
from net_class import DecToHexS
from protocol import *
from update_client_cmd import UpdateClientCmdList
from combat_class import *
from player_param_class import player_param
from storage_class import storage
from config_class import g_Configs

class player_change_flags:
    NONE            = 0b00000000
    POS             = 0b00000001  
    LOOK_DIR        = 0b00000010 	  
    HEALS           = 0b00000100 	   
    MOVEMENT_STATE  = 0b00001000
    STAMINA         = 0b00010000
    RANK            = 0b00100000
    RESPECT         = 0b01000000     	   
    STEP_CMD        = 0b10000000

class player:
    ParentGame = None
    Map = None
    ClientConnection = None    
    ClientQuiteCounter = 0
    PingCounter = None
    Ping = 0
    ChangeFlags = player_change_flags.NONE

    PlayerId = None
    PlayerState = player_state.NONE
    PlayerName = "no_name"
    Heals = 0
    Stamina = 0

    Respect = 0
    Rank = 1

    Pos = vec2( 0, 0 )
    Size = vec2( 48, 32 )
    Rect = rect( Pos, Size )
    
    MoveVec = vec2( 0, 0 )
    LookDir = vec2( 1, 0 )
    MoveTarget = vec2( 0, 0 )
    MovementState = movement_state.NONE
    MovementStateChangeFrame = 0
    IsMoveToTarget = False
   
    IsStepMode = False
    StepCmd = None 

    Combat = None
    Params = None

    MovingCoolDown = 0

    CharParts = None
    ModelIndex = 1

    StorageInv = None
    StorageEquip = None


    def __init__( self, ClientConnection, ParentGame, Id ):
        self.ClientConnection = ClientConnection       
        self.PlayerId = Id
        self.PlayerName = Id #TODO
        self.ParentGame = ParentGame
        self.PlayerState = player_state.CONNECT
        self.Heals = 100
        self.Stamina = 100
        self.Respect = 0
        self.MovementState = movement_state.WAIT  
        self.MovementStateChangeFrame = 0      
        self.Combat = combat( self )
        self.Params = player_param()
        self.CharParts = []
        self.ClientQuiteCounter = 0
        self.Ping = 1
        self.PingCounter = datetime.utcnow() 
        self.StorageInv = storage( self, storage_type.INVENTORY, 12 )
        self.StorageEquip = storage( self, storage_type.EQUIP, 4 )
        self.StorageEquip.SetChangeSlotCallback( self.ChangeEquipSlot )
        self.IsStepMode = False  
        self.StepCmd = None   
                          
        GetCfgInd = g_Configs.GetIndexByName
        self.StorageInv.Slots[ 0 ].ConfigInd = GetCfgInd( "potions/healths_add_main" )  #test
        self.StorageInv.Slots[ 0 ].Count = 1      #test
        self.StorageInv.Slots[ 1 ].ConfigInd = GetCfgInd( "potions/healths_regen_main" )  #test
        self.StorageInv.Slots[ 1 ].Count = 1      #test
        self.StorageInv.Slots[ 3 ].ConfigInd = GetCfgInd( "clothes/shirt_green" )
        self.StorageInv.Slots[ 3 ].Count = 1      #test
        self.StorageInv.Slots[ 4 ].ConfigInd = GetCfgInd( "clothes/shirt_blue" )
        self.StorageInv.Slots[ 4 ].Count = 1      #test
        self.StorageInv.Slots[ 6 ].ConfigInd = GetCfgInd( "clothes/trousers_green" )
        self.StorageInv.Slots[ 6 ].Count = 1      #test
        self.StorageInv.Slots[ 7 ].ConfigInd = GetCfgInd( "clothes/trousers_blue" )
        self.StorageInv.Slots[ 7 ].Count = 1      #test
        self.StorageInv.Slots[ 9 ].ConfigInd = GetCfgInd( "clothes/boots_adi" )
        self.StorageInv.Slots[ 9 ].Count = 1      #test


    def ChangeEquipSlot( self, Index, Slot ): 
        for Player in self.ParentGame.Players:   #TODO is 1 iteration
            if Player.PlayerState == player_state.IN_GAME:                
                Player.SendToClient( tc.CHAR_CLOTH, self.PlayerId + DecToHex( Index, 1 ) + DecToHex( Slot.ConfigInd, 1 ) )
        

    def GetStorageByType( self, Type ):       
        if Type == storage_type.INVENTORY:
            return self.StorageInv
        if Type == storage_type.EQUIP:
            return self.StorageEquip
        ASSERT( 0 )


    def SetPos( self, Pos ):       
        if Pos != self.Pos:
            self.Pos = Pos
            self.Rect = rect( self.Pos, self.Size )      
            self.ChangeFlags |= player_change_flags.POS
 

    def SetMoveTarget( self, Pos ):       
        if Pos != self.MoveTarget:
            self.MoveTarget = Pos
            self.IsMoveToTarget = True        
          

    def SetMoveVec( self, MoveVec ):
        if self.MoveVec == MoveVec:
            return

        self.MoveVec = MoveVec        
        if self.MovementState == movement_state.WAIT or self.MovementState == movement_state.MOVE or self.MovementState == movement_state.FAST_MOVE:
            if MoveVec == vec2( 0, 0 ):            
                self.SetMovementState( movement_state.WAIT )
            else:
                if abs( MoveVec.X ) > 1 or abs( MoveVec.Y ) > 1:
                    self.SetMovementState( movement_state.FAST_MOVE )  
                    MoveVec.X = max( -1, min( MoveVec.X , 1 ) )
                    MoveVec.Y = max( -1, min( MoveVec.Y , 1 ) )
                else:
                    self.SetMovementState( movement_state.MOVE )        


    def SetSize( self, Size ):       
        self.Size = Size 
        self.Rect = rect( self.Pos, self.Size )          


    def SetState( self, PlayerState ):       
        self.PlayerState = PlayerState        


    def SetMap( self, Map ):
        self.Map = Map

        
    def SetLookDir( self, LookDir ):
        ASSERT( LookDir.X )

        if self.LookDir == LookDir:
            return
        self.LookDir = LookDir
        self.ChangeFlags |= player_change_flags.LOOK_DIR


    def SetMovementState( self, MovementState ):
        if self.MovementState == MovementState:
            return

        self.MovementState = MovementState
        self.ChangeFlags |= player_change_flags.MOVEMENT_STATE
        #print "Player.MovementState", self.PlayerId, self.MovementState
        self.MovementStateChangeFrame = self.ParentGame.CurrentFrame


    def SetMovingCoolDownByState( self, MovementState ):
        ASSERT( self.Params.MovementsCoolDown[ MovementState ] )
        self.MovingCoolDown = self.Params.MovementsCoolDown[ MovementState ]


    def SetHeals( self, Heals ):
        if self.Heals == Heals:
            return
        #print "Player.Heals", self.PlayerId, self.Heals
        if Heals >= 0 :
            self.Heals = Heals
        else: 
            self.Heals = 0

        self.ChangeFlags |= player_change_flags.HEALS
        self.CheckChanges()


    def SetStamina( self, Stamina ):
        if self.Stamina == Stamina:
            return
        #print "Player.Stamina", self.PlayerId, self.Stamina
        if Stamina >= 0 :
            self.Stamina = Stamina
        else: 
            self.Stamina = 0

        self.ChangeFlags |= player_change_flags.STAMINA
        self.CheckChanges()


    def SetRespect( self, Respect ):
        if self.Respect == Respect:
            return

        self.Respect = Respect
        print "Player.Respect", self.PlayerId, self.Respect
       
        self.ChangeFlags |= player_change_flags.RESPECT
        self.CheckChanges()


    def SetStepCmd( self, Cmd ):
        self.StepCmd = Cmd
        print "Player.Cmd", self.PlayerId, self.StepCmd
       
        self.ChangeFlags |= player_change_flags.STEP_CMD
        self.CheckChanges()


    def PrepareToNextFrame( self ):
        self.StepCmd = None
        self.ChangeFlags = 0b00000000
        
        
    def SendToClient( self, Comand, Data ):
        if self.ClientConnection:
            self.ParentGame.Net.SendToClient( self.ClientConnection, Comand, Data )


    def UpdateInitCmdList( self, Data ):     
        NextCmdOffset = Data.find( "\n" )
        #print "NextCmdOffset", NextCmdOffset, "len( Data )", len( Data ), "Data", Data
        NextData = Data     
        if NextCmdOffset >= 0 and NextCmdOffset + 1 < len( Data ):
            #print "--", Data[ 0:NextCmdOffset ], Data[ NextCmdOffset + 1:-1 ], len( Data[ 0:NextCmdOffset ] ), len( Data[ NextCmdOffset + 1:-1 ] )
            self.UpdateInitCmd( Data[ 0:NextCmdOffset ] + '\n' )           
            self.UpdateInitCmdList( Data[ NextCmdOffset + 1:-1 ] + '\n' )       
            return   
    
        self.UpdateInitCmd( NextData )


    def UpdateInitCmd( self, Data ):        
        #print "UpdateInitCmd:", Data
        
        try: 
            Cmd = HexToDec( Data[ 0:2 ] )
            Param = Data[ 2:-1 ]
        except ValueError:
            print "bad init cmd data:", Data
            return

        #print "Init cmd:", Cmd, Param
        if Cmd == ts.SELF_NAME:     
            self.PlayerName = Param
        
        if Cmd == ts.SELF_CHAR_PART:     
            Parts = vec2( HexToDec( Param[ 0:2 ] ), HexToDec( Param[ 2:4 ] ) )
            self.CharParts.append( Parts )
            #print self.PlayerId, 'CharParts.append', Parts.X, Parts.Y, "count", len( self.CharParts )
            self.SendToClient( tc.CHAR_PART, self.PlayerId + DecToHex( Parts.X, 1 ) + DecToHex( Parts.Y, 1 ) )
            
        if Cmd == ts.PLAYER_INIT_DONE:                              
            self.PlayerState = player_state.IN_GAME
            #print "PLAYER_INIT_DONE"
            for PlayerInGame in self.ParentGame.Players:
                if PlayerInGame.PlayerId != self.PlayerId:   #todo add check visible
                    #print self.PlayerId, "init other", PlayerInGame.PlayerId 
                    if PlayerInGame.ClientConnection:
                        self.SendInitInfo( PlayerInGame )
                                            
                    PlayerInGame.SendInitInfo( self )# todo separate player and npc


    def InitOwnClient( self, Net ):
        if self.PlayerState == player_state.INIT:
            Data = Net.RecvClientData( self.ClientConnection )
            if Data:
                self.UpdateInitCmdList( Data )       
            return
 
        if self.PlayerState == player_state.CONNECT:
            self.SendToClient( tc.PLAYER_INIT_SELF, self.PlayerId + self.PlayerName )
            self.SendToClient( tc.OBJECT_MODEL, self.PlayerId + DecToHex( model_type.PLAYER, 1 ) + DecToHex( self.ModelIndex, 1 ) )
            self.SendToClient( tc.MOVEMENT_STATE, self.PlayerId + DecToHex( self.MovementState, 1 ) )
            self.SendToClient( tc.OBJECT_POS, self.PlayerId + self.Pos.ToHexSigXY( 2 ) )
            self.SendToClient( tc.OBJECT_LOOK_DIR, self.PlayerId + self.LookDir.ToHexSigXY( 2 ) )
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.MAX_HEALTH, 1 ) + DecToHexS( self.Params.HealsMax, 2 ) )  
            self.SendToClient( tc.OBJECT_HEALS, self.PlayerId + DecToHex( self.Heals, 2 ) )
            self.SendToClient( tc.OBJECT_STAMINA, self.PlayerId + DecToHex( self.Stamina, 1 ) )  
            self.SendToClient( tc.OBJECT_SIZE, self.PlayerId + self.Size.ToHexSigXY( 2 ) )        
            self.SendToClient( tc.TARGET_RECT, self.PlayerId + self.Combat.AimRect.Pos.ToHexSigXY( 2 ) + self.Combat.AimRect.Size.ToHexSigXY( 2 ) )                   
            print "OBJECT_HEALS", self.Heals
            print "OBJECT_POS", self.Pos.X, self.Pos.Y 
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.RESPECT, 1 ) + DecToHexS( self.Respect, 2 ) )                 
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.RANK, 1 ) + DecToHexS( self.Rank, 2 ) )    
                                  
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.POWER, 1 ) + DecToHexS( self.Params.PlayerStats[ player_stats.POWER ], 2 ) )
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.AGILITY, 1 ) + DecToHexS( self.Params.PlayerStats[ player_stats.AGILITY ], 2 ) )
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.WEIGH, 1 ) + DecToHexS( self.Params.PlayerStats[ player_stats.WEIGH ], 2 ) )
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.ACCURACY, 1 ) + DecToHexS( self.Params.PlayerStats[ player_stats.ACCURACY ], 2 ) )
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.DURABILITY, 1 ) + DecToHexS( self.Params.PlayerStats[ player_stats.DURABILITY ], 2 ) )
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.SPEED, 1 ) + DecToHexS( self.Params.PlayerStats[ player_stats.SPEED ], 2 ) )
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.HEALTH, 1 ) + DecToHexS( self.Params.PlayerStats[ player_stats.HEALTH ], 2 ) )
            self.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.STAT_POINT, 1 ) + DecToHexS( self.Params.PlayerStats[ player_stats.STAT_POINT ], 2 ) )

            self.StorageInv.SendAllToOwner()

            self.SendToClient( tc.PRE_INIT_DONE, "" )
            self.PlayerState = player_state.INIT
            return


    def UpdateInGame2( self ):    
        Param = self.Params

        if self.ParentGame.CurrentFrame & 0b00000100:
            if self.Stamina < Param.StaminaMax:
                self.SetStamina( self.Stamina + Param.StaminaRegen )
        
        if self.MovingCoolDown != 0:
            self.MovingCoolDown -= 50   #todo delta from main loop
            if  self.MovingCoolDown < 0:
                 self.MovingCoolDown = 0
        
        if self.MovingCoolDown == 0:                
            self.Combat.Update()
        
        if self.MovingCoolDown == 0: 
            if ( self.MovementState == movement_state.MOVE or self.MovementState == movement_state.FAST_MOVE
            or self.MovementState == movement_state.RUN_KICK or self.MovementState == movement_state.WAIT ):
                if ( self.MoveVec.X != 0 or self.MoveVec.Y != 0 ):            
                    
                    if self.MovementState == movement_state.FAST_MOVE:
                        self.SetStamina( self.Stamina - Param.FastRunStaminaUse )
                        if self.Stamina == 0:
                            self.SetMoveVec( vec2( self.MoveVec.X / 2, self.MoveVec.Y / 2 ) )
                    
                    NewPos = Param.StepOffset * self.MoveVec + self.Pos
                    NewPosRect = rect( NewPos, self.Size )  #TODO opimize
                        
                    if not self.Map.CheckCollision( NewPosRect ):                
                        self.MovingCoolDown = Param.MovementsCoolDown[ movement_state.MOVE ]
                        self.SetPos( NewPos )
                        #print  self.ParentGame.CurrentFrame, "id", self.PlayerId, "Update self.Pos", self.Pos.X, self.Pos.Y
                        if self.MovementState == movement_state.WAIT:
                            self.SetMovementState( movement_state.MOVE )#Todo FAST_MOVE
                    else:
                        self.MovingCoolDown = 0
        
        if self.MovementState == movement_state.GET_HIT and self.MovementStateChangeFrame + 3 < self.ParentGame.CurrentFrame:       
            self.SetMovementState( movement_state.WAIT )


    def UpdateInGame( self ):  
        Param = self.Params

        if self.ParentGame.CurrentFrame & 0b00000100:
            if self.Stamina < Param.StaminaMax:
                self.SetStamina( self.Stamina + Param.StaminaRegen )
        
        if self.MovingCoolDown != 0:
            self.MovingCoolDown -= 50   #todo delta from main loop
            if  self.MovingCoolDown < 0:
                 self.MovingCoolDown = 0
        
        if self.MovingCoolDown == 0:                
            self.Combat.Update()
        
        if self.MovingCoolDown == 0: 
            if self.Pos == self.MoveTarget and not self.IsMoveToTarget:
                if ( self.MoveVec.X != 0 or self.MoveVec.Y != 0 ):
                    if self.MovementState == movement_state.FAST_MOVE:
                        self.SetStamina( self.Stamina - Param.FastRunStaminaUse )
                        if self.Stamina == 0:
                            self.SetMovementState( movement_state.MOVE )
                            self.MoveTarget = self.Pos + Param.StepOffset * self.MoveVec
                        else:
                            self.MoveTarget = self.Pos + Param.StepOffset * vec2( 2, 2 ) * self.MoveVec
                    else:
                        self.MoveTarget = self.Pos + Param.StepOffset * self.MoveVec
                   
            if ( self.MovementState == movement_state.MOVE or self.MovementState == movement_state.FAST_MOVE
            or self.MovementState == movement_state.RUN_KICK or self.MovementState == movement_state.WAIT ):
                
                if self.Pos != self.MoveTarget:
                    if self.MovementState == movement_state.WAIT:
                        self.SetMovementState( movement_state.MOVE )
                    
                    TargetMoveVec = vec2( 0, 0 )
                    if self.Pos.X < self.MoveTarget.X:  TargetMoveVec.X = 1
                    if self.Pos.X > self.MoveTarget.X:  TargetMoveVec.X = -1                    
                    if self.Pos.Y < self.MoveTarget.Y:  TargetMoveVec.Y = 1
                    if self.Pos.Y > self.MoveTarget.Y:  TargetMoveVec.Y = -1
                
                    if self.MovementState == movement_state.MOVE:
                        NewPos = Param.StepOffset * TargetMoveVec + self.Pos
                    if self.MovementState == movement_state.FAST_MOVE:
                        NewPos = Param.StepOffset * TargetMoveVec * vec2( 2, 2 ) + self.Pos
                    if self.MovementState == movement_state.RUN_KICK:
                        NewPos = Param.StepOffset * TargetMoveVec * vec2( 3, 3 ) + self.Pos

                    NewPosRect = rect( NewPos, self.Size )  #TODO opimize
                        
                    if not self.Map.CheckCollision( NewPosRect ):                
                        self.MovingCoolDown = Param.MovementsCoolDown[ self.MovementState ]
                        #self.MovingCoolDown = Param.MovementsCoolDown[ movement_state.MOVE ]                        
                        self.SetPos( NewPos )
                        #print  self.ParentGame.CurrentFrame, "id", self.PlayerId, "Update self.Pos", self.Pos.X, self.Pos.Y
                    else:
                        self.MovingCoolDown = 0
                        self.MoveTarget = self.Pos
                else:
                    if self.IsMoveToTarget:
                        self.IsMoveToTarget = False
                        self.SetMovementState( movement_state.WAIT )

        if self.MovementState == movement_state.GET_HIT and self.MovementStateChangeFrame + 3 < self.ParentGame.CurrentFrame:       
            self.SetMovementState( movement_state.WAIT )


    def CheckChanges( self ):        
        if self.ChangeFlags and self.ParentGame.ChangedPlayers.count( self ) == 0:
            self.ParentGame.ChangedPlayers.append( self )
            #print "changed PlayerId ", self.PlayerId
 
         
    def PingMeasure( self, IsStartMeasure ):
        if IsStartMeasure:
            self.PingCounter = datetime.utcnow()            
        else:            
            FrameTimeMicroseconds = ( datetime.utcnow() - self.PingCounter ).microseconds
            self.Ping = FrameTimeMicroseconds / 1000
            print self.PlayerId, "ping", self.Ping


    def Update( self, Net ):        
        #self.ChangeFlags = player_change_flags.NONE

        #update disconnect
        self.ClientQuiteCounter += 1

        if self.ClientQuiteCounter == game_constant.MAX_CLIENT_QUIET / 2:
            Ping = self.Ping
            if Ping > 250:
                Ping = 251

            self.SendToClient( tc.PING, DecToHex( Ping, 1 ) )
            self.PingMeasure( True )
        elif self.ClientQuiteCounter == game_constant.MAX_CLIENT_QUIET:
            self.PlayerState = player_state.DISCONNECT
            print self.PlayerId + " DISCONNECT by timeout"
            self.ParentGame.ChangedPlayers.append( self )
            return

        #update init       
        if self.PlayerState != player_state.IN_GAME:
            self.InitOwnClient( Net )
            return

        #update game
        Data = Net.RecvClientData( self.ClientConnection )
        if Data:           
            UpdateClientCmdList( self, Data )
        
               
        if self.PlayerState == player_state.IN_GAME: 
            if self.IsStepMode == False:
                self.UpdateInGame()
   
        self.CheckChanges()
 
                               
    def SendChanges( self, Player ):
        if self.PlayerState == player_state.DISCONNECT:
            Player.SendToClient( tc.DELETE_OBJECT, self.PlayerId )
            return

        if self.ChangeFlags & player_change_flags.MOVEMENT_STATE:
            Player.SendToClient( tc.MOVEMENT_STATE, self.PlayerId + DecToHex( self.MovementState, 1 ) )
        
        if self.ChangeFlags & player_change_flags.POS:
            Player.SendToClient( tc.OBJECT_POS, self.PlayerId + self.Pos.ToHexSigXY( 2 ) )
        
        if self.ChangeFlags & player_change_flags.LOOK_DIR:
            Player.SendToClient( tc.OBJECT_LOOK_DIR, self.PlayerId + self.LookDir.ToHexSigXY( 2 ) )
        
        if self.ChangeFlags & player_change_flags.HEALS:
            #print "send HEALS", self.PlayerId, "self player", Player.PlayerId
            Player.SendToClient( tc.OBJECT_HEALS, self.PlayerId + DecToHex( self.Heals, 2 ) )
        
        if Player == self and self.ChangeFlags & player_change_flags.STAMINA:
            Player.SendToClient( tc.OBJECT_STAMINA, self.PlayerId + DecToHex( self.Stamina, 1 ) )
        
        if Player == self and self.ChangeFlags & player_change_flags.RESPECT:
            Player.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.RESPECT, 1 ) + DecToHexS( self.Respect, 2 ) )     

        if Player == self and self.ChangeFlags & player_change_flags.RANK:
            Player.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.RANK, 1 ) + DecToHexS( self.Rank, 2 ) )     
        
        if self.ChangeFlags & player_change_flags.STEP_CMD:
            Player.SendToClient( tc.STEP_CMD, self.PlayerId + DecToHex( self.StepCmd, 1 ) + DecToHex( 55, 1 ) ) # 55 - todo

    def SendInitInfo( self, Player ):
        print self.PlayerId, "SendInitInfo >", Player.PlayerId
        Player.SendToClient( tc.INIT_OBJECT, self.PlayerId + self.PlayerName )        
        Player.SendToClient( tc.OBJECT_MODEL, self.PlayerId + DecToHex( model_type.PLAYER, 1 ) + DecToHex( self.ModelIndex, 1 ) )
        Player.SendToClient( tc.MOVEMENT_STATE, self.PlayerId + DecToHex( self.MovementState, 1 ) )
        Player.SendToClient( tc.OBJECT_POS, self.PlayerId + self.Pos.ToHexSigXY( 2 ) )                        
        Player.SendToClient( tc.OBJECT_LOOK_DIR, self.PlayerId + self.LookDir.ToHexSigXY( 2 ) )
        Player.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.MAX_HEALTH, 1 ) + DecToHexS( self.Params.HealsMax, 2 ) )     
        Player.SendToClient( tc.OBJECT_HEALS, self.PlayerId + DecToHex( self.Heals, 2 ) )  
        Player.SendToClient( tc.OBJECT_STAMINA, self.PlayerId + DecToHex( self.Stamina, 1 ) ) 
        Player.SendToClient( tc.OBJECT_SIZE, self.PlayerId + self.Size.ToHexSigXY( 2 ) )        
        Player.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.RESPECT, 1 ) + DecToHexS( self.Respect, 2 ) )     
        Player.SendToClient( tc.PLAYER_STAT, self.PlayerId + DecToHex( player_stats.RANK, 1 ) + DecToHexS( self.Rank, 2 ) )      
        if self.Combat:
            Player.SendToClient( tc.TARGET_RECT, self.PlayerId + self.Combat.AimRect.Pos.ToHexSigXY( 2 ) + self.Combat.AimRect.Size.ToHexSigXY( 2 ) )        

        for Part in self.CharParts:
            #print "part s", Part.X, Part.Y
            Player.SendToClient( tc.CHAR_PART, self.PlayerId + DecToHex( Part.X, 1 ) + DecToHex( Part.Y, 1 ) )
        
        #for Slot in self.StorageEquip.Slots:
        if self.StorageEquip:
            for I in range( len( self.StorageEquip.Slots ) ):
                Slot = self.StorageEquip.Slots[ I ]
                if Slot.ConfigInd != 0:
                    Player.SendToClient( tc.CHAR_CLOTH, self.PlayerId + DecToHex( I + 1, 1 ) + DecToHex( Slot.ConfigInd, 1 ) )

        Player.SendToClient( tc.OBJECT_STATE, self.PlayerId + DecToHex( object_logic_state.VALID, 1 ) )

