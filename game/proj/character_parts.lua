
conf_PartTable = {	
	{	
		OriginalPartName = 
		{
			"Dummy_head_1"
		},
		ObjName = "head",
		Parts = {
			"head",
		},
		Count = 7,
		CurrentIndex = 1,
	},
	{		
		OriginalPartName = 
		{
			"Dummy_hand_1_fistBack",
			"Dummy_hand_2_fistPalm"
		},
		ObjName = "hands",
		Parts = {
			"palm_near",
			"palm_far",
		},
		Count = 5,
		CurrentIndex = 1,
	},
}


conf_Models = {}	
conf_Models[ model_type.PLAYER ] = 	
{	
	{
		--1
		Patch = "res/main_char_1",
		Name = "MainChar1",
		Size = 0.2,-- original size =x5		
	},
	{
		--2
		Patch = "res/test_kaktus",
		Name = "skeleton",
		Size = 0.6,
	},
}

