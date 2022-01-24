--
-- Spy Plane Launched Sonar Buoy Creator
--   This will create a temporary sonar buoy unit when it hits the water, nothing more.
--   This projectile is not intended to do damage.
--
local TTorpedoShipProjectile = import('/lua/terranprojectiles.lua').TTorpedoShipProjectile

TIMSonarBuoyCreator01 = Class(TTorpedoShipProjectile) {
    FxSplashScale = 0.2,
    FxTrailScale = 3,
    FxExitWaterEmitter = {
        '/effects/emitters/destruction_water_splash_ripples_01_emit.bp',
        '/effects/emitters/destruction_water_splash_wash_01_emit.bp',
        '/effects/emitters/destruction_water_splash_plume_01_emit.bp',
    },


	OnCreate = function(self)
		TTorpedoshipProjectile.OnCreate(self)
		-- creates collision shape on creation since that's how it used to work
		-- before collision shapes got moved to creation OnEnterWater for torpedos
		-- to prevent them from being shot out of the sky
		self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
	end,
	
    OnEnterWater = function(self)
        for i in self.FxExitWaterEmitter do --splash
            CreateEmitterAtEntity(self,self:GetArmy(),self.FxExitWaterEmitter[i]):ScaleEmitter(self.FxSplashScale)
        end

        local x,y,z = unpack(self:GetPosition())
        CreateUnit('ueb5208', self:GetArmy(), x, y, z, 0, 0, 0, 0)

        self:Destroy()
    end,
}

TypeClass = TIMSonarBuoyCreator01