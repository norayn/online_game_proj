##!/usr/bin/env python

import sys
import os
RunPatch = os.path.dirname(os.path.abspath(__file__))
sys.path.append( RunPatch + "/game" )
from game_class import game

Game = game()
Game.Init()
Game.Run()
