
# id = ( 8bit object_class ) + ( 16bit object index )
class ts:
    PING                = 1     ## only cmd
    PLAYER_INIT_DONE    = 2     ## only cmd   
    PRESS_KEY           = 3		## 8bit key
    RELEASE_KEY         = 4     ## 8bit key
    GET_OBJECT          = 5     ## 24bit Id
    MOVE_VEC			= 6		## 8sign_8bit X, 8sign_8bit Y
    SELF_NAME			= 7		## string Name
    SELF_CHAR_PART		= 8		## 8bit part type, 8bit part index
    CHAT_SEND_MSG 		= 9		## 8bit msg_len, msg_text
    CHANGE_STAT         = 10    ## 8bit stat_id, 8sign_16bit Param
    DRAG_SLOT			= 11	## 8bit start_storage_type, 8bit target_storage_type 8bit StarSlotIndex, 8bit TargetSlotIndex, 8bit Count       
    STEP_CMD            = 12	## 24bit Id, 8bit StepCmdIdIndex, 8bit Add_param

    COUNT               = 12
    '''end'''

class tc:
    PING                = 1     ## 8bit value
    PLAYER_INIT_SELF    = 2		## 24bit Id, string Name
    PRE_INIT_DONE       = 3     ## only cmd  
    PLAYER_IN_GAME      = 4		## 24bit Id
    OBJECT_POS          = 5		## 24bit Id, 8sign_16bit X, 8sign_16bit Y
    OBJECT_LOOK_DIR     = 6		## 24bit Id, 8sign_16bit X, 8sign_16bit Y
    INIT_OBJECT         = 7		## 24bit Id, string Name
    OBJECT_STATE        = 8		## 24bit Id, 8bit object_logic_state
    DELETE_OBJECT       = 9		## 24bit Id
    OBJECT_HEALS        = 10	## 24bit Id, 16bit heals
    MOVEMENT_STATE      = 11	## 24bit Id, 8bit movement_state
    CHAR_PART           = 12	## 24bit Id, 8bit part type, 8bit part index
    OBJECT_STAMINA      = 13	## 24bit Id, 8bit stamina
    OBJECT_SIZE 		= 14	## 24bit Id, 8sign_8bit X, 8sign_8bit Y   
    TARGET_RECT 		= 15	## 24bit Id, 8sign_8bit X, 8sign_8bit Y, 8sign_8bit H, 8sign_8bit W   
    CHAT_SEND_MSG 		= 16	## 24bit Id, 8bit msg_len, msg_text
    PLAYER_STAT         = 17    ## 24bit Id, 8bit stat_id, 8sign_16bit Param
    OBJECT_HIT          = 18	## 24bit Id, 8bit hit_type, 8sign_16bit Hit
    OBJECT_MODEL        = 19	## 24bit Id, 8bit type, 8bit index     
    STORAGE_SLOT        = 20	## 8bit storage_type, 8bit SlotIndex, 8bit ConfigIndex, 8bit Count 
    CHAR_CLOTH          = 21	## 24bit Id, 8bit slot index, 8bit cloth id index
    STEP_CMD            = 22	## 24bit Id, 8bit StepCmdIdIndex, 8bit Add_param
    NEXT_BATTLE_STEP    = 23	## 8bit SelfAreaInd
    INIT_BATTLE_AREA    = 24	## 8bit AreaInd, 8sign_16bit X, 8sign_16bit Y, 8sign_16bit H, 8sign_16bit W 
    DEL_BATTLE_AREA     = 25	## 8bit AreaInd
                                             
    COUNT               = 25
    '''end'''

class player_state:
    NONE                = 0     ## 
    CONNECT             = 1     ##
    DISCONNECT          = 2     ##
    INIT                = 3     ##
    IN_GAME             = 4     ##
      
    COUNT               = 4
    '''end'''

class object_class:
    NONE                = 0     ##
    PLAYER              = 1	    ##	
    NPC                 = 2	    ##
              
    COUNT               = 2
    '''end'''
 
    
class object_logic_state:
    NONE                = 0     ##
    INVALID             = 1     ##
    VALID               = 2	    ##
    INVISIBLE           = 3	    ##   	
                  
    COUNT               = 3
    '''end'''
  
class movement_state:
    NONE                = 0     ##
    WAIT                = 1     ##
    MOVE                = 2	    ##
    STRIKE_OWER         = 3	    ##   
    PUNCH               = 4	    ##   	
    PUNCH_HEAWY         = 5	    ##   	
    BLOCK               = 6	    ##   	
    GET_HIT             = 7	    ##   	
    ON_GROUND           = 8	    ##   	
    FAST_MOVE           = 9	    ##   	
    RUN_KICK            = 10    ##   	
              
    COUNT               = 10
    '''end'''

class player_stats:
    NONE                = 0     ##
    POWER               = 1     ##
    AGILITY             = 2	    ##
    WEIGH               = 3	    ##
    ACCURACY            = 4     ##
    DURABILITY          = 5     ##
    SPEED               = 6     ##
    HEALTH				= 7		##
    RESPECT             = 8     ##  
    STAT_POINT			= 9		##  
    MAX_HEALTH          = 10    ##
    MAX_STAMINA         = 11	##
    RESPECT             = 12	##
    RANK                = 13	##
            
    COUNT               = 13
    '''end'''    
 
class client_key:
    NONE                = 0     ##
    PUNCH1              = 1     ##
    PUNCH2              = 2	    ##
    BLOCK               = 3	    ##
    EXIT                = 4	    ##
                  
    COUNT               = 4
    '''end'''

class hit_type:
    NONE                = 0     ##
    DAMAGE              = 1     ##
    CRIT_DAMAGE         = 2	    ##
    SELF_DAMAGE         = 3	    ##
                  
    COUNT               = 3
    '''end''' 

class storage_type:
    NONE                = 0     ##
    INVENTORY           = 1     ##
    EQUIP               = 2	    ##
                  
    COUNT               = 2
    '''end''' 
           
class game_constant:
    MAX_CLIENT_QUIET    = 250    ## server frame count before close sokcet
    BTL_AREA_STEP_TIME  = 2      ## second

    COUNT               = 2
    '''end'''
        
class model_type:
    PLAYER              = 1    ## model player

    COUNT               = 1
    '''end'''    


