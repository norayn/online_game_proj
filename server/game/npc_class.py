from player_class import player 	   
from protocol import *
from combat_class import *
from player_param_class import player_param

import random
import math

DIST_TO_NO_MOVE_ATTACK = 50


class npc_actions:
    NONE            = 0
    FREE_MOVE		= 1
    MOVE_TO_TARGET	= 2
    ATTACK_TARGET	= 3
    NO_MOVE_ATTACK	= 4

    COUNT			= 4


class npc( player ):

    def __init__( self, ParentGame, Id ):       
        self.PlayerId = Id
        self.PlayerName = "_bot_"
        self.ParentGame = ParentGame
        self.Heals = 100
        self.Stamina = 100
        #self.Respect = 0
        self.MovementState = movement_state.WAIT
        
        self.MovementStateChangeFrame = 0      
        self.Combat = combat( self )
        self.Params = player_param()
        self.CharParts = []

        self.BotCurrentAction = npc_actions.ATTACK_TARGET
        self.BotLastUpdateFrame = self.ParentGame.CurrentFrame
        self.BotTargetId = None

    def GetNumberFromId( self, Id ):
        return  HexToDec( Id[ 2: ] ) - 1

    def Update( self, Net ):
        self.UpdateBot()  
        #self.UpdateBotNoMoveAttackNearTarget()
             
        self.UpdateInGame()
        self.CheckChanges()

 

    def UpdateBot( self ):
        if self.BotLastUpdateFrame + 10 > self.ParentGame.CurrentFrame:
            return

        self.BotLastUpdateFrame = self.ParentGame.CurrentFrame
        NewActionInd = random.randint( 1, 20 )
        if NewActionInd <= npc_actions.COUNT:
            self.BotCurrentAction = NewActionInd
            self.BotTargetId = None

                
        if self.BotCurrentAction == npc_actions.FREE_MOVE:
            self.UpdateBotFreeMove()
        if self.BotCurrentAction == npc_actions.MOVE_TO_TARGET:
            self.UpdateBotnMoveToTarget()
        if self.BotCurrentAction == npc_actions.ATTACK_TARGET:
            self.UpdateBotAttackTarget()
        if self.BotCurrentAction == npc_actions.NO_MOVE_ATTACK:
            self.UpdateBotNoMoveAttackNearTarget()


    def UpdateBotFreeMove( self ):
        ActionChanseIndex = random.randint( 1, 10 )
        
        if ActionChanseIndex < 5:            
            MoveVecX = random.randint( -1, 1 )
            MoveVecY = random.randint( -1, 1 )

            if MoveVecX != 0 and self.LookDir.X != MoveVecX:                 
                self.SetLookDir( vec2( MoveVecX, self.LookDir.Y ) )
                
            self.SetMoveVec( vec2( MoveVecX, MoveVecY ) )      
        
        if ActionChanseIndex > 8:
            self.SetMoveVec( vec2( 0, 0 ) )      


    def FindTarget( self ):
        Players = self.ParentGame.Players        
        if not self.BotTargetId or not self.ParentGame.GetObjById( self.BotTargetId ):
            self.BotTargetId = None
            for Player in Players:
                if Player.PlayerId != None and random.randint( 1, 5 ) == 3 and self != Player:
                    if math.fabs( Player.Pos.X - self.Pos.X ) < 200:
                        self.BotTargetId = Player.PlayerId
                        #print "--BotTargetId",  self.BotTargetId, self.PlayerId 


    def UpdateBotnMoveToTarget( self ):
        self.FindTarget()
        if not self.BotTargetId:
            return
               
        Player = self.ParentGame.GetObjById( self.BotTargetId )
        if self.BotTargetId and Player:
            MoveDir = vec2( 0, 0 )
            
            #print "ids",  self.PlayerId, Player.PlayerId     
            if self.Pos.X > Player.Pos.X:
            	MoveDir.X = -1
            elif self.Pos.X < Player.Pos.X:
                MoveDir.X = 1
                        
            if self.Pos.Y > Player.Pos.Y:
            	MoveDir.Y = -1
            elif self.Pos.Y < Player.Pos.Y:
                MoveDir.Y = 1

            #print "MoveDir", self.Pos.X, self.Pos.Y, Player.Pos.X, Player.Pos.Y
            if MoveDir.X != 0 and self.LookDir.X != MoveDir.X:                 
                self.SetLookDir( vec2( MoveDir.X, self.LookDir.Y ) )

            self.SetMoveVec( MoveDir )  


    def UpdateBotAttackTarget( self ):
        self.FindTarget()
        if not self.BotTargetId:
            return
               
        Player = self.ParentGame.GetObjById( self.BotTargetId )
        if self.BotTargetId and Player:
            MoveDir = vec2( 0, 0 )           
            TargetOffsetX = 100
            TargetOffsetY = 20

            if self.Pos.X > Player.Pos.X and self.Pos.X > Player.Pos.X + TargetOffsetX:
            	MoveDir.X = -1
            elif self.Pos.X < Player.Pos.X and self.Pos.X < Player.Pos.X - TargetOffsetX:
                MoveDir.X = 1
                        
            if self.Pos.Y > Player.Pos.Y and self.Pos.Y > Player.Pos.Y + TargetOffsetY:
            	MoveDir.Y = -1
            elif self.Pos.Y < Player.Pos.Y and self.Pos.Y < Player.Pos.Y - TargetOffsetY:
                MoveDir.Y = 1
            
            if MoveDir.X != 0 or MoveDir.Y != 0:
                if MoveDir.X != 0 and self.LookDir.X != MoveDir.X:                 
                    self.SetLookDir( vec2( MoveDir.X, self.LookDir.Y ) )

                self.SetMoveVec( MoveDir )
            else:
                self.Combat.AddCombatState( combat_states.SMALL_PUNCH )  

 
    def UpdateBotNoMoveAttackNearTarget( self ):
        if not self.BotTargetId:
            Players = self.ParentGame.Players
            for Player in Players:
              if Player.PlayerId != None and random.randint( 1, 5 ) == 3 and self != Player:
                  if math.fabs( Player.Pos.X - self.Pos.X ) < DIST_TO_NO_MOVE_ATTACK and math.fabs( Player.Pos.Y - self.Pos.Y ) < DIST_TO_NO_MOVE_ATTACK / 2:
                      self.BotTargetId = Player.PlayerId
                      break
        else:
            Player = self.ParentGame.GetObjById( self.BotTargetId )
            if self.BotTargetId and Player:
                if math.fabs( Player.Pos.X - self.Pos.X ) > DIST_TO_NO_MOVE_ATTACK or math.fabs( Player.Pos.Y - self.Pos.Y ) > DIST_TO_NO_MOVE_ATTACK / 2:
                        self.BotTargetId = None
                        return

        if not self.BotTargetId:
            return
               
        Player = self.ParentGame.GetObjById( self.BotTargetId )
        if self.BotTargetId and Player:
            LookDir = vec2( 0, self.LookDir.Y )           
            
            if self.Pos.X > Player.Pos.X:
            	LookDir.X = -1
            elif self.Pos.X < Player.Pos.X:
                LookDir.X = 1

            if LookDir.X != 0 and self.LookDir.X != LookDir.X:                 
                self.SetLookDir( LookDir )
                
            self.Combat.AddCombatState( combat_states.SMALL_PUNCH )  

 
