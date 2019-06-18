from helper_class import *
from lib_slpp import slpp as lua



# Start config index = 1
class config_set:
    Configs = None    
    ConfigNames = None
    ConfigNameToIndexTab = None

    def __init__( self ):
        self.Configs = []
        self.ConfigNames = []    
        self.ConfigNameToIndexTab = {}   
        

    def Load( self ):
        ConfigPatch = '../game/proj/res/items/'
  
        print "load configs ----------------"  
               
        with open( ConfigPatch + 'items.lua' ) as data_file: 
            data = lua.decode( '{' + data_file.read() + '}' )            
            Index = 0
            for Patch in data[ 'configs_list' ]:
                 with open( ConfigPatch + Patch + '.lua' ) as config_file: 
                    Config = lua.decode( '{' + config_file.read() + '}' )
                    self.ConfigNames.append( Patch )                    
                    self.Configs.append( Config )
                    print "load config:", Patch 
                    self.ConfigNameToIndexTab[ Patch ] = Index
                    Index += 1
        
        print "load configs done, count:", Index


    def GetByIndex( self, Index ):
        ASSERT( Index > 0 )
        return ( self.Configs[ Index - 1 ] )[ 'item_config' ]


    def GetByName( self, Name ):
        return ( self.Configs[ self.ConfigNameToIndexTab[ Name ] ] )[ 'item_config' ]


    def GetIndexByName( self, Name ):
        return self.ConfigNameToIndexTab[ Name ] + 1


    def GetNameByIndex( self, Index ):
        return self.ConfigNames[ Index - 1 ]


g_Configs = config_set()
