
-- id = ( 8bit object_ ) + ( 16bit object index )
 ts = {
    PING                = 1     ,-- only cmd
    PLAYER_INIT_DONE    = 2     ,-- only cmd   
    PRESS_KEY           = 3		,-- 8bit key
    RELEASE_KEY         = 4     ,-- 8bit key
    GET_OBJECT          = 5     ,-- 24bit Id

    
    COUNT               = 5
    }

 tc = {
    PING                = 1     ,-- only cmd
    PLAYER_INIT_SELF    = 2		,-- 24bit Id, string Name
    PLAYER_INIT_DONE    = 3     ,-- only cmd  
    PLAYER_IN_GAME      = 4		,-- 24bit Id
    OBJECT_POS          = 5		,-- 24bit Id, 16bit X, 16bit Y
    OBJECT_LOOK_DIR     = 6		,-- 24bit Id, 8sign_16bit X, 8sign_16bit Y
    INIT_OBJECT         = 7		,-- 24bit Id, string Name
    OBJECT_STATE        = 8		,-- 24bit Id, 8bit object_logic_state
    DELETE_OBJECT       = 9		,-- 24bit Id
    OBJECT_HEALS        = 10	,-- 24bit Id, 8bit heals
    MOVEMENT_STATE      = 11	,-- 24bit Id, 8bit movement_state
    
    COUNT               = 11
    }

 player_state = {
    NONE                = 0     ,-- 
    CONNECT             = 1     ,--
    DISCONNECT          = 2     ,--
    INIT                = 3     ,--
    IN_GAME             = 4     ,--
      
    COUNT               = 4
    }

 object_class = {
    NONE                = 0     ,--
    PLAYER              = 1	    ,--	
          
    COUNT               = 1
    }
 
    
 object_logic_state = {
    NONE                = 0     ,--
    INVALID             = 1     ,--
    VALID               = 2	    ,--
    INVISIBLE           = 3	    ,--   	
                  
    COUNT               = 3
    }
  
 movement_state = {
    NONE                = 0     ,--
    WAIT                = 1     ,--
    MOVE                = 2	    ,--
    PUNCH               = 3	    ,--   	
                  
    COUNT               = 3
    }
     
 game_constant = {
    MAX_CLIENT_QUIET    = 250    ,-- server frame count before close sokcet

    COUNT               = 1
    }
     


