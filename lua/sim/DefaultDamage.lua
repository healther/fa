--****************************************************************************
--**
--**  File     :  /lua/sim/defaultdamage.lua
--**  Author(s): John Comes
--**
--**  Summary  : A common way to do damage over than direct damage, ie: Dots, area dots, etc.
--**
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- upvalue globals for performance 
Damage = Damage 
DamageArea = DamageArea
WaitTicks = coroutine.yield 

-- upvalue moho functions for performance
local EntityMethods = _G.moho.entity_methods
local EntityGetPosition = EntityMethods.GetPosition

-- Applies damage over time to a specific unit.
UnitDoTThread = function(instigator, unit, pulses, pulseTime, damage, damType, friendly)
    for i = 1, pulses do
        if unit and not unit.Dead then
            Damage(instigator, EntityGetPosition(unit), unit, damage, damType )
            WaitTicks(10 * pulseTime + 1)
        else 
            break 
        end
    end
end

-- Applies damage over time to a specific area.
AreaDoTThread = function(instigator, position, pulses, pulseTime, radius, damage, damType, friendly)
    for i = 1, pulses do
        DamageArea(instigator, position, radius, damage, damType, friendly)
        WaitTicks(10 * pulseTime + 1)
    end
end


-- SCALABLE RADIUS AREA DOT
-- - Allows for a scalable damage radius that begins with DamageStartRadius and ends
-- - with DamageEndRadius, interpolates between based on frequency and duration.

function ScalableRadiusAreaDoT(entity)
    local spec = entity.Spec.Data

    -- FIX ME
    -- Change this to get position from the entity, once we have the tech to set the entity's position
    -- local position = entity:GetPosition()
    local position = entity.Spec.Position
    local radius = spec.StartRadius or 0
    local freq = spec.Frequency or 1
    local dur = spec.Duration or 1
    if dur != freq then
        local reductionScalar = (radius - (spec.EndRadius or 1) ) * freq / (dur - freq)
        local duration = math.floor(dur / freq)

        for i = 1, duration do
            DamageArea(entity, position, radius, spec.Damage, spec.Type, spec.DamageFriendly)
            radius = radius - reductionScalar
            WaitSeconds(freq)
        end
    end
    entity:Destroy()
end