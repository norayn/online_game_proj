import time
from datetime import datetime

from helper_class import vec2

from map_class import map
from player_class import player
from npc_class import npc
from net_class import net
from net_class import DecToHex
from net_class import HexToDec
from protocol import *
from battle_area_class import battle_area




class game:
    State = 0
    Net = None

    Players = [] #TODO map
    PlayerCounter = 0
    ChangedPlayers = []
    BattleAreas = []
    Map = map()
    CurrentFrame = 0
    FPS = 20
     

    def GetId( self, ObjClass, Index ):
        return  DecToHex( ObjClass, 1 ) + DecToHex( Index, 2 )


    def GetClassFromId( self, Id ):
        return  HexToDec( Id[ 0:2 ] )


    def GetObjById( self, Id ):
        if self.GetClassFromId( Id ) == object_class.PLAYER:                
            for Player in self.Players:
                if Player.PlayerId == Id:    
                    return Player
                    
        return None


    def Update( self ):
        #self.Net.UpdateConnection()
        self.Net.Update()
          
        for Player in self.Players:
            if Player.PlayerState == player_state.IN_GAME:
                for ChangedPlayer in self.ChangedPlayers:
                    ChangedPlayer.SendChanges( Player )

        for Player in self.Players:
            Player.PrepareToNextFrame()

        del self.ChangedPlayers[:]  
        
        for BattleArea in self.BattleAreas:
            if BattleArea.Update() == False:    #BattleArea update
               self.BattleAreas.remove( BattleArea ) 

        for Player in self.Players:
            if Player.PlayerState == player_state.DISCONNECT: 
                Player.PlayerId = None
                self.Net.CloseConnection( Player.ClientConnection )
                self.Players.remove( Player )
            else:
                Player.Update( self.Net )
              
        self.CurrentFrame += 1


    def Run( self ):
        while 1:
            PrevTime = datetime.utcnow() 

            self.Update()

            FrameTimeMicroseconds = ( datetime.utcnow() - PrevTime ).microseconds
            time.sleep( 0.05 - ( FrameTimeMicroseconds / 1000000 ) ) #20fps main
            #time.sleep( 0.01 - ( FrameTimeMicroseconds / 1000000 ) ) #100fps test
            #time.sleep( 1.0 - ( FrameTimeMicroseconds / 1000000 ) ) #1fps DEBUG
            #print time.time(), "FrameTimeMicroseconds", FrameTimeMicroseconds
            
            if self.CurrentFrame % 20 == 0:
                 #print 'Send/Resv byte/s:', str( self.Net.DebugSendedByte ) + '/' + str( self.Net.DebugResvedByte ), "FrameTime ms:", FrameTimeMicroseconds / 1000
                 self.Net.DebugSendedByte = 0
                 self.Net.DebugResvedByte = 0
                           
        print "o_O"


    def AddNewUser( self, Connection ):
        SpawnPos = self.Map.SpawnTrigger.Pos

        self.PlayerCounter += 1
        Id = self.GetId( object_class.PLAYER, self.PlayerCounter )

        Connection.PlayerId = Id

        Pl = player( Connection, self, Id )        
        Pl.SetMap( self.Map ) 
        Pl.SetPos( SpawnPos ) 
        Pl.MoveTarget = SpawnPos
        Pl.PlayerState = player_state.CONNECT
       
        self.Players.append( Pl )
        print 'AddNewUser:', len( self.Players ), "PlayerCounter", self.PlayerCounter
        
        #self.BattleArea.AddPlayer( Pl )   ##!!!!!!!!!! TEST battle_area
 

    def AddBattleArea( self, CreatePlayer ):
        BattleArea = battle_area( self )
        BattleArea.InitByPlayer( CreatePlayer ) 
        self.BattleAreas.append( BattleArea )
                         

    def Init( self ):
        Port = 8082
        MaxCounn = 99
        print "----SERV INIT----   Port:", Port, "MaxConnect:", MaxCounn
        self.Net = net( Port, MaxCounn, self.AddNewUser )
        
        from config_class import g_Configs
        g_Configs.Load()
        #print g_Configs.GetByIndex( g_Configs.GetIndexByName( "actions/wait" ) )  
        
        # test add npc
        SpawnPos = self.Map.SpawnTrigger.Pos

        BotCount = 0
        I = 0
        while I < BotCount:
            I = I + 1

            self.PlayerCounter += 1
            Id = self.GetId( object_class.PLAYER, self.PlayerCounter )

            Pl = npc( self, Id )        
            Pl.SetMap( self.Map ) 
            Pl.SetPos( SpawnPos ) 
            Pl.MoveTarget = SpawnPos
            Pl.ModelIndex = 1#2

            self.Players.append( Pl )
            print 'test add npc'



        

        

        
        

 

