#from player_class import player 	   
from protocol import *
#from combat_class import *
from player_param_class import player_param
from helper_class import *

import random
import math

class battle_area:
    def __init__( self, ParentGame ):  
        self.ParentGame = ParentGame     
        self.Pos = vec2( 0, 0 )
        self.Size = vec2( 256, 128 )
        self.Rect = rect( self.Pos, self.Size )    
        self.Players = []
        self.StepTimerCounter = 0
        self.StepTimerMax = game_constant.BTL_AREA_STEP_TIME * ParentGame.FPS
        self.AreaInd = 0
        
        EmptyAreaIndex = 0
        while self.AreaInd == 0:
            EmptyAreaIndex += 1
            IndexFree = True
            for Area in ParentGame.BattleAreas:
                if Area.AreaInd == EmptyAreaIndex:
                    IndexFree = False
                    break

            if IndexFree:
                self.AreaInd = EmptyAreaIndex
                ASSERT( EmptyAreaIndex < 255 )
        

    def Update( self ): 
        self.StepTimerCounter += 1
        if self.StepTimerCounter >= self.StepTimerMax:
            self.StepTimerCounter = 0
            
            for Player in self.Players:
                if Player.PlayerState != player_state.IN_GAME:
                    self.DelPlayer( Player )
                    continue

                Player.SendToClient( tc.NEXT_BATTLE_STEP, DecToHex( self.AreaInd, 1 ) )
                        
                Player.Combat.UpdateStepMode( self )            
                #update step

                #update players turn
                #calc damage

            if len( self.Players ) < 2:
                self.ClearArea()
                return False

        #set next action
        return True


    def ClearArea( self ): 
        print "ClearArea" 
        for Player in self.Players:
            self.DelPlayer( Player )
        
        for Player in self.ParentGame.Players: 
            Player.SendToClient( tc.DEL_BATTLE_AREA, DecToHex( self.AreaInd, 1 ) ) 


    def AddPlayer( self, Player ): 
        self.Players.append( Player )
        Player.IsStepMode = True
 

    def DelPlayer( self, Player ): 
        self.Players.remove( Player )
        Player.IsStepMode = False


    def InitByPlayer( self, CreatePlayer ): 
        self.Pos.X = CreatePlayer.Pos.X
        self.Pos.Y = CreatePlayer.Pos.Y
        self.Rect = rect( self.Pos, self.Size )   
                
        for Player in self.ParentGame.Players:
            if Player.PlayerState == player_state.IN_GAME and Player != CreatePlayer:
                if self.Rect.CrossRectFast( Player.Rect ):
                    self.AddPlayer( Player ) 
                
        self.AddPlayer( CreatePlayer )
        
        for Player in self.ParentGame.Players: 
            Player.SendToClient( tc.INIT_BATTLE_AREA, DecToHex( self.AreaInd, 1 ) + \
                self.Pos.ToHexSigXY( 2 ) + self.Size.ToHexSigXY( 2 ) )      #todo optimize             

 
