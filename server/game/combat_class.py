import json
from helper_class import *
from protocol import *
from net_class import *
from config_class import g_Configs

class combat_states:
    NONE        = 0
    WAIT        = 1
    BLOCK       = 2
    SMALL_PUNCH = 3
    HEAWY_PUNCH = 4
    DEFEATED    = 5
    RUN_KICK    = 6

class combat:
    OwnerPlayer = None
    CombatState = combat_states.NONE
    CommandPull = None
    AimRect = None  
    StepCmdIdIndex = 0
    StepCmdAddParam = 0   
       

    def __init__( self, Player ):
        self.OwnerPlayer = Player
        self.CombatState = combat_states.WAIT
        self.CommandPull = []
        self.AimRect = rect( vec2( Player.Size.X + 18, 0 ), vec2( 20, 8 ) ) 
        print( "init conbat done" )
        

    def CheckCollision( self, PlayerRect ):
        if not PlayerRect.InRect( self.Rect ):
            return True

        for Rect in self.CollisionRects:
            if Rect.CrossRectFast( PlayerRect ):
                return True
        
        return False


    def Update( self ):
        OwnPlayer = self.OwnerPlayer
        
        if OwnPlayer.MovingCoolDown == 0 and ( self.CombatState == combat_states.SMALL_PUNCH
        or self.CombatState == combat_states.HEAWY_PUNCH or self.CombatState == combat_states.RUN_KICK ):
            self.UpdateAttack()

        if self.CombatState == combat_states.DEFEATED:
            if OwnPlayer.MovingCoolDown == 0:
                HealsMax = self.OwnerPlayer.Params.HealsMax
                self.OwnerPlayer.MovingCoolDown = 500
                if OwnPlayer.Heals >= HealsMax:
                    OwnPlayer.SetHeals( HealsMax )
                    self.CombatState = combat_states.WAIT
                    OwnPlayer.SetMovementState( movement_state.WAIT ) 
                else:
                    OwnPlayer.SetHeals( OwnPlayer.Heals + 5 )

            return 

        if len( self.CommandPull ) > 0:
            #print OwnPlayer.PlayerId, "SetCombatState"
            self.SetCombatState( self.CommandPull.pop( 0 ) )
        
        if self.CombatState == combat_states.BLOCK:
            self.OwnerPlayer.MovingCoolDown = 5
            return           


    def AddDamage( self, Player, CombatState, IsBlock ):
        Params = self.OwnerPlayer.Params
        Damage = 0
        if IsBlock == False:
            Damage = int( Params.AttackDamage[ CombatState ] )
        else:
            Damage = int( Params.AttackDamage[ CombatState ] * Params.BlockPersent )

        ResultHeals = Player.Heals - Damage
        self.OwnerPlayer.SendToClient( tc.OBJECT_HIT, Player.PlayerId + DecToHex( hit_type.DAMAGE, 1 ) + DecToHexS( Damage, 2 ) )     
        Player.SendToClient( tc.OBJECT_HIT, Player.PlayerId + DecToHex( hit_type.SELF_DAMAGE, 1 ) + DecToHexS( Damage, 2 ) )     
        
        Player.SetHeals( ResultHeals )
        if ResultHeals <= 0:
            Player.SetRespect( Player.Respect - 1 )
            self.OwnerPlayer.SetRespect( self.OwnerPlayer.Respect + 1 )

            Params.PlayerStats[ player_stats.STAT_POINT ] = Params.PlayerStats[ player_stats.STAT_POINT ] + 1
            self.OwnerPlayer.SendToClient( tc.PLAYER_STAT, self.OwnerPlayer.PlayerId + DecToHex( player_stats.STAT_POINT, 1 ) + DecToHexS( Params.PlayerStats[ player_stats.STAT_POINT ], 2 ) )


    def UpdateAttack( self ):
         OwnPlayer = self.OwnerPlayer
         if OwnPlayer.IsMoveToTarget:
             return
                      
         OwnPlayer.SetMovementState( movement_state.WAIT )

         AimX = OwnPlayer.Pos.X + self.AimRect.Pos.X * OwnPlayer.LookDir.X
         AimY = OwnPlayer.Pos.Y + self.AimRect.Pos.Y
         AimRect = rect( vec2( AimX, AimY ), self.AimRect.Size )                    
         #print "Po", OwnPlayer.Pos.X, OwnPlayer.Pos.Y
         HitFlag = False
         #AimRect.Print()
         for Player in OwnPlayer.ParentGame.Players: #todo get from near cells
             if HitFlag:                
                 break             
             
             if Player.PlayerId == OwnPlayer.PlayerId:
                 continue

             if Player.Combat.CombatState == combat_states.DEFEATED:
                 continue

             if self.CombatState == combat_states.RUN_KICK:
                if OwnPlayer.Rect.CrossRectFast( rect( Player.Pos, Player.Size ) ):
                    if Player.Combat.CombatState != combat_states.BLOCK:
                        self.AddDamage( Player, self.CombatState, False )
                        Player.SetMovementState( movement_state.GET_HIT )
                        Player.Combat.SetCombatState( combat_states.DEFEATED )
                    else:
                        self.AddDamage( OwnPlayer, self.CombatState, False )
                        OwnPlayer.SetMovementState( movement_state.GET_HIT )
                        OwnPlayer.Combat.SetCombatState( combat_states.DEFEATED )
                continue

             if AimRect.CrossRectFast( rect( Player.Pos, Player.Size ) ):
                 HitFlag = True
                 #print "PUNCH Player.PlayerId", Player.PlayerId   
                 if Player.Combat.CombatState != combat_states.BLOCK:
                     if self.CombatState == combat_states.SMALL_PUNCH:
                         self.AddDamage( Player, self.CombatState, False )
                         Player.SetMovementState( movement_state.GET_HIT )
                     if self.CombatState == combat_states.HEAWY_PUNCH:
                         self.AddDamage( Player, self.CombatState, False )
                         Player.SetMovementState( movement_state.GET_HIT )
                 else:                     
                     if self.CombatState == combat_states.SMALL_PUNCH:
                         StaminaBlockSmallPunch = Player.Params.BlockStaminaUse[ combat_states.SMALL_PUNCH ] 
                         if Player.Stamina - StaminaBlockSmallPunch <= 0:
                            Player.SetStamina( 0 )
                            self.AddDamage( Player, self.CombatState, False )     
                         else:
                            Player.SetStamina( Player.Stamina - StaminaBlockSmallPunch )
                            self.AddDamage( Player, self.CombatState, True )                   
                     if self.CombatState == combat_states.HEAWY_PUNCH:
                         StaminaHeawyPunch = Player.Params.BlockStaminaUse[ combat_states.HEAWY_PUNCH ] 
                         if Player.Stamina - StaminaHeawyPunch <= 0:
                            Player.SetStamina( 0 )
                            self.AddDamage( Player, self.CombatState, False )     
                         else:
                            Player.SetStamina( Player.Stamina - StaminaHeawyPunch )
                            self.AddDamage( Player, self.CombatState, True )
                 
                 if Player.Heals <= 0:
                     Player.Combat.SetCombatState( combat_states.DEFEATED )
                 
         if self.CombatState != combat_states.DEFEATED:
            self.CombatState = combat_states.WAIT


    def SetCombatState( self, State ):
        OwnPlayer = self.OwnerPlayer
        
        if State == combat_states.WAIT:           
            OwnPlayer.SetMovementState( movement_state.WAIT )
            self.CombatState = State

        if State == combat_states.SMALL_PUNCH:            
            StaminaSmallPunch = OwnPlayer.Params.AttackStaminaUse[ combat_states.SMALL_PUNCH ]
            StaminaRunKick = OwnPlayer.Params.AttackStaminaUse[ combat_states.RUN_KICK ] 
                       
            if OwnPlayer.MovementState == movement_state.FAST_MOVE and OwnPlayer.Stamina > StaminaRunKick:
                OwnPlayer.SetStamina( OwnPlayer.Stamina - StaminaRunKick )
                #OwnPlayer.SetMovingCoolDownByState( movement_state.RUN_KICK )
                OwnPlayer.SetMovementState( movement_state.RUN_KICK )
                State = combat_states.RUN_KICK
                self.CombatState = State

                NewPos = OwnPlayer.Params.StepOffset * OwnPlayer.MoveVec * vec2( 9, 9 ) + OwnPlayer.Pos# ???StepOffset
                OwnPlayer.SetMoveTarget( NewPos )

            elif OwnPlayer.Stamina > StaminaSmallPunch:
                OwnPlayer.SetStamina( OwnPlayer.Stamina - StaminaSmallPunch )
                OwnPlayer.SetMovingCoolDownByState( movement_state.PUNCH )
                OwnPlayer.SetMovementState( movement_state.PUNCH )
                self.CombatState = State
             
        if State == combat_states.HEAWY_PUNCH: 
            StaminaHeawyPunch = OwnPlayer.Params.AttackStaminaUse[ combat_states.HEAWY_PUNCH ]  
            #print "stam", OwnPlayer.Stamina, StaminaHeawyPunch            
            if OwnPlayer.Stamina > StaminaHeawyPunch:
                OwnPlayer.SetStamina( OwnPlayer.Stamina - StaminaHeawyPunch )
                OwnPlayer.SetMovingCoolDownByState( movement_state.PUNCH_HEAWY )
                OwnPlayer.SetMovementState( movement_state.PUNCH_HEAWY )
                self.CombatState = State

        if State == combat_states.BLOCK:           
            OwnPlayer.SetMovementState( movement_state.BLOCK )
            self.CombatState = State

        if State == combat_states.DEFEATED:           
            OwnPlayer.SetMovementState( movement_state.ON_GROUND )
            if len( self.CommandPull ):
                self.CommandPull = []

            self.CombatState = State


    def AddCombatState( self, State ):
        if self.CombatState == combat_states.DEFEATED:
            return
        
        #print "AddCombatState", State, self.CombatState
        if State == movement_state.WAIT and self.CombatState != combat_states.BLOCK :
            return
        
        #print self.OwnerPlayer.PlayerId, "_AddCombatState"
        if len( self.CommandPull ) < 2: #comand buffer size
            self.CommandPull.append( State )
       

    def UpdateStepMode( self, BattleArea ):
        OwnPlayer = self.OwnerPlayer
        AreaPlayers = BattleArea.Players

        if OwnPlayer.Stamina < 100:       #temp for test, TODO!!!
                OwnPlayer.SetStamina( OwnPlayer.Stamina + 10 )

        if self.StepCmdIdIndex == 0:
            self.StepCmdIdIndex = g_Configs.GetIndexByName( "actions/wait" )

        StepCmd = g_Configs.GetByIndex( self.StepCmdIdIndex )
        ASSERT( StepCmd[ 'Type' ] == "ACTION" )
        
        if StepCmd[ 'StaminaNeed' ]:
            if StepCmd[ 'StaminaNeed' ] <= OwnPlayer.Stamina:       
                OwnPlayer.SetStamina( OwnPlayer.Stamina - StepCmd[ 'StaminaNeed' ] )
            else:
                return

        if StepCmd[ 'ActionType' ] == "ATTACK":            
            AimRectParam = StepCmd[ 'AimRect' ]
            AimX = OwnPlayer.Pos.X + AimRectParam[ 0 ] * OwnPlayer.LookDir.X
            AimY = OwnPlayer.Pos.Y + AimRectParam[ 1 ]
            AimRect = rect( vec2( AimX, AimY ), vec2( AimRectParam[ 2 ], AimRectParam[ 3 ] ) )

            for Player in AreaPlayers: 
                if AimRect.CrossRectFast( rect( Player.Pos, Player.Size ) ):
                    Damage = StepCmd[ 'Damage' ]
                    ResultHeals = Player.Heals - Damage
                    #self.OwnerPlayer.SendToClient( tc.OBJECT_HIT, Player.PlayerId + DecToHex( hit_type.DAMAGE, 1 ) + DecToHexS( Damage, 2 ) )     
                    #Player.SendToClient( tc.OBJECT_HIT, Player.PlayerId + DecToHex( hit_type.SELF_DAMAGE, 1 ) + DecToHexS( Damage, 2 ) )     

                    Player.SetHeals( ResultHeals )
                    if ResultHeals < 1:
                        Player.SetMovementState( movement_state.ON_GROUND )
                        BattleArea.DelPlayer( Player )

            OwnPlayer.SetStepCmd( self.StepCmdIdIndex )

        if StepCmd[ 'ActionType' ] == "MOVE":                 
            ParamY = self.StepCmdAddParam % 10
            ParamX = ( self.StepCmdAddParam - ParamY ) / 10 
            MoveVecs = vec2(  ParamX - 2, ParamY - 2 )
            #Param = ( X + 2 ) * 10 + Y + 2

            NewPos = ( MoveVecs * vec2( StepCmd[ 'MoveStepX' ], StepCmd[ 'MoveStepY' ] ) ) + OwnPlayer.Pos
            OwnPlayer.SetPos( NewPos )
            OwnPlayer.SetStepCmd( self.StepCmdIdIndex )

        self.StepCmdIdIndex = 0
        self.StepCmdAddParam = 0