require "class"
local spine = require "lib.spine-love.spine"

local	PartTypeToOriginalName = {}
PartTypeToOriginalName[ "head" ] = "Dummy_head_1"
PartTypeToOriginalName[ "torso" ] = "Dummy_torso"
PartTypeToOriginalName[ "arm_upper_far" ] = "Dummy_arm_upper_far"
PartTypeToOriginalName[ "arm_upper_near" ] = "Dummy_arm_upper_near"
PartTypeToOriginalName[ "waist" ] = "Dummy_waist"
PartTypeToOriginalName[ "leg_lower_far" ] = "Dummy_leg_lower_far"
PartTypeToOriginalName[ "leg_lower_near" ] = "Dummy_leg_lower_near_1"
PartTypeToOriginalName[ "leg_upper_far" ] = "Dummy_leg_upper_far"
PartTypeToOriginalName[ "leg_upper_near" ] = "Dummy_leg_upper_near"
PartTypeToOriginalName[ "foot_far" ] = "Dummy_foot_far_1"
PartTypeToOriginalName[ "foot_near" ] = "Dummy_foot_near_1"


character_class = class(function( self, Path, File )
	self.LoadScale = 0.3
	self.AttachmentTable = {}
	self.Skeleton = nil
	self.SkeletonData = nil
	self.DefaultTexAtlas = nil
	self.Animations = {}
	self.AnimationsParam = nil
	self.CurrentAnimation = nil
	self.CurrentAnimationSpeedK = 1
	self.NextAnimation = nil
	self.NextAnimTimelapse = 0
	self.NextBlendK = 0
	self.ClothConfigsTable = {}	

	if Path and File then
		self:SkeletonInit( Path, File )
	end

	if ResMgr:HasAtlas( "parts.png" ) then
		local HeadParts = conf_PartTable[ 1 ]
		local Atlas = ResMgr:GetAtlas( "parts.png" )
		local PartName = HeadParts.Parts[ 1 ] .. '_' .. HeadParts.CurrentIndex
		self.PlayerHead = { Image = Atlas.Image, Quad = Atlas.SubTexTable[ PartName ].Quad }
	end	
end)


function character_class:SkeletonInit( Path, File, AnimationsParamTable )
	self.AnimationsParam = AnimationsParamTable
	
	local PosX, PosY, Scale, FlipX, FlipY ,DebugBones, DebugSlots = 110, 110, self.LoadScale, false, false, false, false

	self.Skeleton, self.Animations, self.SkeletonData = spine.new( Path,  File .. ".json"
		, "ALL_ANIM_TABLE", PosX, PosY, Scale, FlipX, FlipY ,DebugBones, DebugSlots )
			
	for Key, Anim in ipairs( self.SkeletonData.animations ) do	--TODO optimaze
		self.Animations[ Anim.name ].AnimationTime = 0
	end
	self.CurrentAnimation = self.Animations[ "idle" ] -- TODO Get name from AnimationsParamTable
	
	if not ResMgr:HasAtlas( File .. ".png" ) then
		ResMgr:LoadAtlas( Path .. "/" , File .. ".atlas" )
	end
	
	DefaultTexAtlas = ResMgr:GetAtlas( File .. ".png" )

	for I, Slot in ipairs( self.Skeleton.drawOrder ) do
		local AttName = Slot.attachment.name
		self.AttachmentTable[ AttName ] = {}
		self.AttachmentTable[ AttName ].Image = DefaultTexAtlas.Image
		self.AttachmentTable[ AttName ].SubTexData = DefaultTexAtlas.SubTexTable[ AttName ]
	end

	self.Skeleton.imageSubTexTable = self.AttachmentTable
end


function character_class:ResetPartsToDefault()
	for Key, Slot in ipairs( self.Skeleton.drawOrder ) do
		local AttName = Slot.attachment.name
		self.AttachmentTable[ AttName ].Image = DefaultTexAtlas.Image
		self.AttachmentTable[ AttName ].SubTexData = DefaultTexAtlas.SubTexTable[ AttName ]		
	end
end


function character_class:SetPartByName( PartTypeName, PartName )
	for Key, Slot in ipairs( self.Skeleton.drawOrder ) do	--TODO optimaze ???
		local Name = Slot.attachment.name
		local ImageSubTexTable = self.Skeleton.imageSubTexTable
		local SubTex = ImageSubTexTable[ Name ]
				
		if Name:find( PartTypeToOriginalName[ PartTypeName ] ) then
			local Atlas = ResMgr:GetAtlas( "parts.png" )			
			SubTex.Image = Atlas.Image			
			SubTex.SubTexData = Atlas.SubTexTable[ PartName ]
			
			if PartTypeName == 'head' then
				self.PlayerHead = { Image = Atlas.Image, Quad = SubTex.SubTexData.Quad }
			end
		end
	end
end


function character_class:SetPart( PartType, PartIndex )		
	if g_SelfPlayer and g_SelfPlayer.Character == self then
		conf_PartTable[ PartType ].CurrentIndex = PartIndex
	end

	local Parts = conf_PartTable[ PartType ].Parts
	local ImageSubTexTable = self.Skeleton.imageSubTexTable
			
	for Key, Slot in ipairs( self.Skeleton.drawOrder ) do	--TODO optimaze ???
		local Name = Slot.attachment.name
		local SubTex = ImageSubTexTable[ Name ]
		
		for I= 1, #Parts do
			if Name:find( conf_PartTable[ PartType ].OriginalPartName[ I ] ) then
				local Atlas = ResMgr:GetAtlas( "parts.png" )
				local PartName = Parts[ I ] .. '_' .. PartIndex
		
				SubTex.Image = Atlas.Image
				--Logf( PartName )
				
				SubTex.SubTexData = Atlas.SubTexTable[ PartName ]

				if PartType == 1 then
					self.PlayerHead = { Image = Atlas.Image, Quad = SubTex.SubTexData.Quad }
				end
			end
		end
	end
end


function character_class:SetClothConf( SlotIndex, ConfigIndex )	
	assert( SlotIndex ~= 0 )	
	self.ClothConfigsTable[ SlotIndex ] = ConfigIndex

	if ConfigIndex ~= 0 then
		local ClothConfig = Game.Configs:GetByIndex( ConfigIndex )		
		if ClothConfig.Type == "CLOTHES" then
			for K, V in pairs( ClothConfig.Parts ) do
				self:SetPartByName( K, V )
			end
		end	
	else
		self:ResetPartsToDefault()
		self.ClothConfigsTable[ SlotIndex ] = nil
		for K, V in pairs( self.ClothConfigsTable ) do
			self:SetClothConf( K, V )				
		end
	end
end


function character_class:SetCurrentAnim( Name, AnimTime )
	assert( type( Name ) == 'string', 'Parameter "Name" must be a string.' )
	assert( self.Animations[ Name ], 'No anim ' .. Name )

	self.CurrentAnimation = self.Animations[ Name ]
	if AnimTime then
		self.CurrentAnimation.AnimationTime = AnimTime
	else
		self.CurrentAnimation.AnimationTime = 0
	end
end


function character_class:SetNextAnim( Name, Timelapse )
	assert( type( Name ) == 'string', 'Parameter "Name" must be a string.' )
	assert( self.Animations[ Name ], 'No anim ' .. Name )

	self.NextAnimation = self.Animations[ Name ]
	self.NextAnimTimelapse = Timelapse
	self.NextAnimation.AnimationTime = 0
	self.NextBlendK = 0
end


function character_class:SetNextMovementState( MovementState )	
	self.CurrentAnimationSpeedK = self.AnimationsParam[ MovementState ].SpeedK
	self:SetNextAnim( self.AnimationsParam[ MovementState ].Name, self.AnimationsParam[ MovementState ].ChangeTime )
end


function character_class:SetPos( Pos )	
	self.Skeleton.x = Pos[ 1 ]
	self.Skeleton.y = Pos[ 2 ]
end


function character_class:SetFlipX( State )	
	self.Skeleton.flipX = State
end


function character_class:Update( delta )
	local Animation = self.CurrentAnimation
	local Skeleton = self.Skeleton

	Animation.AnimationTime = Animation.AnimationTime + delta * self.CurrentAnimationSpeedK
	Animation:apply( Skeleton, Animation.AnimationTime, true )

	if self.NextAnimation then
		local NextAnimation = self.NextAnimation		
		NextAnimation.AnimationTime = NextAnimation.AnimationTime + delta * self.CurrentAnimationSpeedK
		
		local ElapsedTime = GetMax( 0, self.NextAnimTimelapse - love.timer.getDelta() )
		local TimeK = ElapsedTime / self.NextAnimTimelapse
		self.NextBlendK = 1 + ( ( self.NextBlendK - 1 ) * TimeK ) 
		self.NextAnimTimelapse = ElapsedTime	

		NextAnimation:mix( Skeleton, NextAnimation.AnimationTime, true, self.NextBlendK )	

		if self.NextBlendK >= 1 then
			self:SetCurrentAnim( NextAnimation.name, NextAnimation.AnimationTime )
			self.NextAnimation = nil
		end
	end

	Skeleton:updateWorldTransform()
end


function character_class:Draw()
	--self.Skeleton.debugSlots = true
	self.Skeleton:draw()
end