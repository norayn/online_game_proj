from helper_class import *
from protocol import *
from combat_class import *


class player_param:
    StepOffset = None    
    MovementsCoolDown = None  

    def __init__( self ):
        self.HealsMax = 120
        self.HealsRegen = 10            
        self.StaminaMax = 100
        self.StaminaRegen = 4
        self.StepOffset = vec2( 12, 6 )
        self.FastRunStaminaUse = 10
        self.MovementsCoolDown = {}
        self.MovementsCoolDown[ movement_state.MOVE ] = 100
        self.MovementsCoolDown[ movement_state.FAST_MOVE ] = 100
        self.MovementsCoolDown[ movement_state.PUNCH ] = 200
        self.MovementsCoolDown[ movement_state.PUNCH_HEAWY ] = 300
        self.MovementsCoolDown[ movement_state.RUN_KICK ] = 100
        
        self.AttackDamage = {}
        self.AttackDamage[ combat_states.SMALL_PUNCH ] = 5
        self.AttackDamage[ combat_states.HEAWY_PUNCH ] = 25
        self.AttackDamage[ combat_states.RUN_KICK ] = 20
        self.AttackStaminaUse = {}
        self.AttackStaminaUse[ combat_states.SMALL_PUNCH ] = 14
        self.AttackStaminaUse[ combat_states.HEAWY_PUNCH ] = 35
        self.AttackStaminaUse[ combat_states.RUN_KICK ] = 28
        self.BlockStaminaUse = {}       
        self.BlockStaminaUse[ combat_states.SMALL_PUNCH ] = 5
        self.BlockStaminaUse[ combat_states.HEAWY_PUNCH ] = 20

        self.BlockPersent = 1 / 20

        self.PlayerStats = {}
        self.PlayerStats[ player_stats.POWER        ] = 10
        self.PlayerStats[ player_stats.AGILITY      ] = 10
        self.PlayerStats[ player_stats.WEIGH        ] = 10
        self.PlayerStats[ player_stats.ACCURACY     ] = 10
        self.PlayerStats[ player_stats.DURABILITY   ] = 10
        self.PlayerStats[ player_stats.SPEED        ] = 10
        self.PlayerStats[ player_stats.HEALTH       ] = 10
        self.PlayerStats[ player_stats.STAT_POINT   ] = 30


    def ReCalcParams( self ):
        _POWER      = self.PlayerStats[ player_stats.POWER        ]
        _AGILITY    = self.PlayerStats[ player_stats.AGILITY      ]
        _WEIGH      = self.PlayerStats[ player_stats.WEIGH        ]
        _ACCURACY   = self.PlayerStats[ player_stats.ACCURACY     ]
        _DURABILITY = self.PlayerStats[ player_stats.DURABILITY   ]
        _SPEED      = self.PlayerStats[ player_stats.SPEED        ]
        _HEALTH     = self.PlayerStats[ player_stats.HEALTH       ]
       
        self.HealsMax = int( _WEIGH * 5.0 + _HEALTH * 5.0 )
        self.HealsRegen = int( 3 + _HEALTH / 5.0 + _DURABILITY / 2.0 )
        self.StaminaMax = int( 50.0 + _DURABILITY * 5.0 )
        self.StaminaRegen = int( ( 12.5 + _DURABILITY / 2.0 + _AGILITY / 4.0 ) / 5.0  )
        
        UseStaminaK = 1.1 - _AGILITY / 100.0
        SpeedK = 1.0 + _SPEED / 20.0 - _WEIGH / 20.0 
        self.StepOffset = vec2( int( 12.0 * SpeedK ), int( 6.0 * SpeedK ) ) 
        self.FastRunStaminaUse = int( UseStaminaK * 10.0 )

        print "HealsMax", self.HealsMax, "StaminaMax", self.StaminaMax, "HealsRegen", self.HealsRegen, 
        "StaminaRegen", self.StaminaRegen

        DamageK = 0.8 + _POWER / 100.0 + _ACCURACY / 100.0
        self.AttackDamage[ combat_states.SMALL_PUNCH ] = int( 5.0 * DamageK )
        self.AttackDamage[ combat_states.HEAWY_PUNCH ] = int( 25.0 * DamageK )
        self.AttackDamage[ combat_states.RUN_KICK ] = int( 20.0 * DamageK )
        UseStaminaDamageK = 0.9 + _POWER / 100.0
        self.AttackStaminaUse[ combat_states.SMALL_PUNCH ] = int( 14.0 * UseStaminaK * UseStaminaDamageK )
        self.AttackStaminaUse[ combat_states.HEAWY_PUNCH ] = int( 35.0 * UseStaminaK * UseStaminaDamageK )
        self.AttackStaminaUse[ combat_states.RUN_KICK ] = int( 28.0 * UseStaminaK * UseStaminaDamageK )

        self.BlockStaminaUse[ combat_states.SMALL_PUNCH ] = int( 5.0 / UseStaminaDamageK )
        self.BlockStaminaUse[ combat_states.HEAWY_PUNCH ] = int( 20.0 / UseStaminaDamageK )
        BlockDmagePersent = _AGILITY / 500.0 + _WEIGH / 20.0 + 94.48
        self.BlockPersent = ( 100.0 - BlockDmagePersent ) / 100.0
        print "SMALL_PUNCH dmg", self.AttackDamage[ combat_states.SMALL_PUNCH ],
        "HEAWY_PUNCH dmg", self.AttackDamage[ combat_states.HEAWY_PUNCH ],
        "RUN_KICK dmg", self.AttackDamage[ combat_states.RUN_KICK ]

        print "SMALL_PUNCH StaminaUse", self.AttackStaminaUse[ combat_states.SMALL_PUNCH ],
        "HEAWY_PUNCH StaminaUse", self.AttackStaminaUse[ combat_states.HEAWY_PUNCH ],
        "RUN_KICK StaminaUse", self.AttackStaminaUse[ combat_states.RUN_KICK ]

        print "SMALL_PUNCH BlockStamina", self.BlockStaminaUse[ combat_states.SMALL_PUNCH ],
        "HEAWY_PUNCH BlockStamina", self.BlockStaminaUse[ combat_states.HEAWY_PUNCH ],
        "BlockPersent", self.BlockPersent