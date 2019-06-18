from helper_class import vec2
from net_class import net
from net_class import DecToHex
from net_class import DecToHexS
from net_class import HexToDec
from protocol import *
from combat_class import combat_states

def UpdateClientCmdList( Player, Data ):     
    NextCmdOffset = Data.find( "\n" )
    NextData = Data     
    if NextCmdOffset >= 0 and NextCmdOffset + 1 < len( Data ):
        UpdateClientCmd( Player, Data[ 0:NextCmdOffset ] + '\n' )
        UpdateClientCmdList( Player, Data[ NextCmdOffset + 1:-1 ] + '\n' )       
        return   

    UpdateClientCmd( Player, NextData )


def UpdateClientCmd( Player, Data ):
    #Player.ClientQuiteCounter = 0
         
    Game = Player.ParentGame
    Cmd = HexToDec( Data[ 0:2 ] )
    Param = Data[ 2:-1 ]
    #print "cmd:", Cmd
    #print "Param:", Param
    
    if Cmd == ts.PRESS_KEY:
         Key = HexToDec( Param )
         if Key == client_key.EXIT:                 
             #print Player.ParentGame.CurrentFrame, "TS_PRESS_KEY: esc"
             Player.PlayerState = player_state.DISCONNECT
             Player.ParentGame.ChangedPlayers.append( Player )
             return 

         if Key == client_key.PUNCH1:   
             Player.Combat.AddCombatState( combat_states.SMALL_PUNCH )
             return
         if Key == client_key.PUNCH2: 
             Player.Combat.AddCombatState( combat_states.HEAWY_PUNCH )
             return
         if Key == client_key.BLOCK:
             for BattleAreaRect in Player.ParentGame.Map.BattleAreaRects:
                 if Player.Rect.InRect( BattleAreaRect ):
                     Player.ParentGame.AddBattleArea( Player )
 
                     break
                          
             #Player.Combat.AddCombatState( combat_states.BLOCK )
             return
                              
    if Cmd == ts.RELEASE_KEY:
         Key = HexToDec( Param )
         if Key == client_key.BLOCK:             
             Player.Combat.AddCombatState( combat_states.WAIT )
             return

         return

    if Cmd == ts.GET_OBJECT:
        Id = Param
        print  Player.PlayerId, "GET_OBJECT", Id               
        # TODO check visible
        if Game.GetClassFromId( Id ) == object_class.PLAYER:                
            for NeedPlayer in Game.Players:
                if NeedPlayer.PlayerId == Id:    
                    NeedPlayer.SendInitInfo( Player )
                    break
            return

    if Cmd == ts.MOVE_VEC:
        X = HexToDec( Data[ 2:5 ] )
        Y = HexToDec( Data[ 5:8 ] )

        LookDirX = 0
        if X > 0:
            LookDirX = 1
        if X < 0:
            LookDirX = -1
        
        #X = max( -2, min( X , 2 ) ) #TODO add speed move cmd and del this
        #Y = max( -2, min( Y , 2 ) )

        #print Player.ParentGame.CurrentFrame, Player.PlayerId, "MOVE_VEC", X, Y   
        if LookDirX != 0 and Player.LookDir.X != LookDirX:                 
            Player.SetLookDir( vec2( LookDirX, Player.LookDir.Y ) )
            Player.SendToClient( tc.OBJECT_LOOK_DIR, Player.PlayerId + Player.LookDir.ToHexSigXY( 2 ) )                 
                            
        Player.SetMoveVec( vec2( X, Y ) )
        return

    if Cmd == ts.CHAT_SEND_MSG:
        MsgLen = HexToDec( Data[ 2:4 ] )
        Msg = Data[ 4:4 + MsgLen ]
        #print Msg
        if Msg[ 0:1 ] == '.':            
            UpdateDbgCmd( Player, Msg )
            return

        for PlayerForSend in Game.Players:            
            if PlayerForSend.PlayerState == player_state.IN_GAME:
                PlayerForSend.SendToClient( tc.CHAT_SEND_MSG, Player.PlayerId + DecToHex( MsgLen, 1 ) + Msg ) 
        return

    if Cmd == ts.CHANGE_STAT:
        PlayerState = HexToDec( Data[ 2:4 ] )
        Param = HexToDec( Data[ 4:4 + 5 ] )
        print Player.ParentGame.CurrentFrame, Player.PlayerId, "CHANGE_STAT", PlayerState, Param 
        #TODO add CHECKS
        Player.Params.PlayerStats[ PlayerState ] = Player.Params.PlayerStats[ PlayerState ] + Param
        Player.Params.PlayerStats[ player_stats.STAT_POINT ] = Player.Params.PlayerStats[ player_stats.STAT_POINT ] - Param        
        Player.SendToClient( tc.PLAYER_STAT, DecToHex( PlayerState, 1 ) + DecToHexS( Player.Params.PlayerStats[ PlayerState ], 2 ) )
        Player.SendToClient( tc.PLAYER_STAT, DecToHex( player_stats.STAT_POINT, 1 ) + DecToHexS( Player.Params.PlayerStats[ player_stats.STAT_POINT ], 2 ) )
        Player.Params.ReCalcParams()
        return

    if Cmd == ts.DRAG_SLOT:
        StartType = HexToDec( Data[ 2:4 ] )
        TargetType = HexToDec( Data[ 4:6 ] )
        StartIndex = HexToDec( Data[ 6:8 ] )
        TargetIndex = HexToDec( Data[ 8:10 ] )
        Coount = HexToDec( Data[ 10:12 ] )
        print Player.ParentGame.CurrentFrame, Player.PlayerId, "DRAG_SLOT", StartType, TargetType, StartIndex, TargetIndex, Coount

        StartStorage = Player.GetStorageByType( StartType )
        TargetStorage = Player.GetStorageByType( TargetType )
        
        TmpSlot = TargetStorage.GetSlot( TargetIndex )
        TargetStorage.PushToSlot( TargetIndex, StartStorage.GetSlot( StartIndex ) ) 
        if TmpSlot.ConfigInd == 0:
            StartStorage.ClearSlot( StartIndex )
        else:
            StartStorage.PushToSlot( StartIndex, TmpSlot ) 

        return

    if Cmd == ts.STEP_CMD:        
        IdIndex = HexToDec( Data[ 2:4 ] )
        Param = HexToDec( Data[ 4:6 ] )
        Player.Combat.StepCmdIdIndex = IdIndex
        Player.Combat.StepCmdAddParam = Param
        return

    if Cmd == ts.PING:
        Player.ClientQuiteCounter = 0
        Player.PingMeasure( False )
        return
        
    print Player.ParentGame.CurrentFrame, "Unknow cmd, Data:", Data


def UpdateDbgCmd( Player, CmdText ):     
    MsgParam = CmdText.split()
    if MsgParam[ 0 ] == '.move_cd':                
        State = int( MsgParam[ 1 ] )
        CoolDown = int( MsgParam[ 2 ] )
        Player.Params.MovementsCoolDown[ State ] = CoolDown
        print "move_cd", State, CoolDown
        return  

    if MsgParam[ 0 ] == '.step_ofs':                
        X = int( MsgParam[ 1 ] )
        Y = int( MsgParam[ 2 ] )
        Player.Params.StepOffset = vec2( X, Y )
        print "step_ofs", X, Y
        return     
    
    
    
      