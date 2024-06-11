-- name: \\#ff46a0\\Kirby \\#ffffff\\physics
-- incompatible:
-- description: Gives kirby physics.\n Fly in the air and suck up your enemies like kirby\n\nThe [CS] Kirby mod for Character Select is recommended

-----------------
-- CUSTOM VARS --
-----------------
local modstatus = false

--------------------
-- MISC FUNCTIONS --
--------------------
function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
end

function kirby_update_air(m)
    local sidewaysSpeed = 0.0
    local dragThreshold = 0
    local intendedDYaw = 0
    local intendedMag = 0

    if (check_horizontal_wind(m)) == 0 then
        dragThreshold = 64.0

        if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
            intendedDYaw = m.intendedYaw - m.faceAngle.y
            intendedMag = m.intendedMag / 32.0
            m.forwardVel = m.forwardVel + intendedMag * coss(intendedDYaw) * 1.5
            if m.forwardVel > dragThreshold then
                m.forwardVel = m.forwardVel - 1.5
            end
            sidewaysSpeed = intendedMag * sins(intendedDYaw) * dragThreshold
        else
            m.forwardVel = approach_f32(m.forwardVel, 0.0, 1, 1)
        end

        --! Uncapped air speed. Net positive when moving forward.
        if (m.forwardVel > dragThreshold) then
            m.forwardVel = m.forwardVel
        end
        if (m.forwardVel < -32.0) then
            m.forwardVel = m.forwardVel + 2.0
        end

        m.slideVelX = m.forwardVel * sins(m.faceAngle.y)
        m.slideVelZ = m.forwardVel * coss(m.faceAngle.y)

        m.slideVelX = m.slideVelX + sidewaysSpeed * sins(m.faceAngle.y + 0x4000)
        m.slideVelZ = m.slideVelZ + sidewaysSpeed * coss(m.faceAngle.y + 0x4000)

        m.vel.x = approach_f32(m.vel.x, m.slideVelX, 1, 1)
        m.vel.z = approach_f32(m.vel.z, m.slideVelZ, 1, 1)
    end
end

function kirby_common_air_action_step(m, landAction, landActionMoving, animation, stepArg, turning, keepMomentum)
    local stepResult = perform_air_step(m, stepArg)

    kirby_update_air(m)
    if turning then
        m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x1000, 0x1000)
        if m.faceAngle.y ~= m.intendedYaw and m.forwardVel > 32 then
            mario_set_forward_vel(m, approach_f32(m.forwardVel, 0, m.forwardVel/16, m.forwardVel/16))
        else
            mario_set_forward_vel(m, m.forwardVel)
        end
    end

    if (m.action == ACT_BUBBLED and stepResult == AIR_STEP_HIT_LAVA_WALL) then
        stepResult = AIR_STEP_HIT_WALL
    end

    if stepResult == AIR_STEP_NONE then
        set_mario_animation(m, animation)
    elseif stepResult == AIR_STEP_LANDED then
        if m.vel.x ~= 0 or m.vel.z ~= 0 then
            m.faceAngle.y = atan2s(m.vel.z, m.vel.x)
        end
        m.marioObj.oMarioWalkingPitch = 0x0000
        if (check_fall_damage_or_get_stuck(m, ACT_HARD_BACKWARD_GROUND_KB) == 0) then
            if m.forwardVel ~= 0 and keepMomentum then
                set_mario_action(m, landActionMoving, 0)
            else
                set_mario_action(m, landAction, 0)
            end
        end
    elseif stepResult == AIR_STEP_HIT_WALL then
        set_mario_animation(m, animation)

        if (m.forwardVel > 16.0) then
            queue_rumble_data_mario(m, 5, 40)
            mario_bonk_reflection(m, false)
            m.faceAngle.y = m.faceAngle.y + 0x8000
        else
            mario_set_forward_vel(m, 0.0)
        end
    elseif stepResult == AIR_STEP_GRABBED_LEDGE then
        set_mario_animation(m, MARIO_ANIM_IDLE_ON_LEDGE)
        drop_and_set_mario_action(m, ACT_LEDGE_GRAB, 0)
    elseif stepResult == AIR_STEP_GRABBED_CEILING then
        set_mario_action(m, ACT_START_HANGING, 0)
    elseif stepResult == AIR_STEP_HIT_LAVA_WALL then
        lava_boost_on_wall(m)
    end

    return stepResult
end

function act_air_hit_wall(m)
    if (m.heldObj ~= nil) then
        mario_drop_held_object(m)
    end

    if m.actionTimer <= 1 then
        if (m.input & INPUT_A_PRESSED) ~= 0 then
            m.vel.y = 52.0
            m.faceAngle.y = m.faceAngle.y + 0x8000
            return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
        end
    end

    if (m.forwardVel >= 69) then
        set_mario_animation(m, MARIO_ANIM_START_WALLKICK)
        m.wallKickTimer = 5
        if (m.vel.y > 0.0) then
            m.vel.y = 0.0
        end

        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, false)
        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
    else
        m.wallKickTimer = 5
        if (m.vel.y > 0.0) then
            m.vel.y = 0.0
        end

        if (m.forwardVel > 8.0) then
            mario_set_forward_vel(m, -8.0)
        end
        set_mario_action(m, ACT_SOFT_BONK, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end

--------------------
-- CUSTOM ACTIONS --
--------------------
ACT_KIRBY_SUCK = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_IDLE | ACT_FLAG_PAUSE_EXIT)
ACT_KIRBY_HOVER = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_AIR | ACT_FLAG_CONTROL_JUMP_HEIGHT | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_KIRBY_HOVER_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_AIR | ACT_FLAG_CONTROL_JUMP_HEIGHT | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_KIRBY_PUFF = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

-- Actions functions
function act_kirby_suck(m)
end

function act_kirby_hover(m)
    m.vel.y = math.max(m.vel.y - 0.2, -10.0)
    m.forwardVel = math.min(m.forwardVel, 12.0)
    kirby_common_air_action_step(m, ACT_KIRBY_PUFF, ACT_KIRBY_PUFF, MARIO_ANIM_FORWARD_SPINNING, AIR_STEP_NONE, true, true)

    if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
        set_mario_action(m, ACT_KIRBY_HOVER_JUMP, 0)
    end
    if (m.controller.buttonPressed & B_BUTTON) ~= 0 then
        set_mario_action(m, ACT_KIRBY_PUFF, 0)
    end
end

function act_kirby_hover_jump(m)
    m.vel.y = 30.0
    set_mario_action(m, ACT_KIRBY_HOVER, 0)
end

function act_kirby_puff(m)
    m.vel.y = 0.0
    m.forwardVel = math.min(m.forwardVel, 8.0)
    if m.actionTimer == 0 then
        play_character_sound_if_no_flag(m, CHAR_SOUND_YAH_WAH_HOO, MARIO_ACTION_SOUND_PLAYED)
        spawn_sync_object(id_AirPuff, E_MODEL_SMOKE, m.pos.x, m.pos.y, m.pos.z, function(o) end)
    end
    if m.actionTimer > 10 then
        if (m.input & INPUT_A_PRESSED) ~= 0 then
            set_mario_action(m, ACT_KIRBY_HOVER_JUMP, 0)
        else
            set_mario_action(m, ACT_KIRBY_FREEFALL, 0)
        end
    end
    kirby_common_air_action_step(m, ACT_KIRBY_IDLE, ACT_KIRBY_WALKING, MARIO_ANIM_AIR_KICK, AIR_STEP_NONE, true, false)
    m.actionTimer = m.actionTimer + 1
end

---------------------
-- CHARACTER SETUP --
---------------------
function kirby_command(msg)
    local m = gMarioStates[0]
    if msg == "on" then
        if modstatus == false then
            audio_sample_play(CHAR_SOUND_OKEY_DOKEY, m.marioObj.header.gfx.cameraToObject, 1)
            djui_popup_create("\\#ff46a0\\Kirby\\#ffffff\\ is \\#00C7FF\\on\\#ffffff\\!", 1)
            set_mario_action(m, ACT_KIRBY_IDLE, 0)
            modstatus = true
        end
        return true
    elseif msg == "off" then
        if modstatus == true then
            play_sound(CHAR_SOUND_OKEY_DOKEY, m.marioObj.header.gfx.cameraToObject)
            djui_popup_create("\\#ff46a0\\Kirby\\#ffffff\\ is \\#A02200\\off\\#ffffff\\!", 1)
            set_mario_action(m, ACT_IDLE, 0)
            modstatus = false
        end
        return true
    end
    return false
end

--------------------
-- HOOK FUNCTIONS --
--------------------
hook_mario_action(ACT_KIRBY_SUCK, act_kirby_suck)
hook_mario_action(ACT_KIRBY_HOVER, act_kirby_hover)
hook_mario_action(ACT_KIRBY_HOVER_JUMP, act_kirby_hover_jump)
hook_mario_action(ACT_KIRBY_PUFF, act_kirby_puff)

hook_chat_command(
    "kirby",
    "[\\#00C7FF\\on\\#ffffff\\|\\#A02200\\off\\#ffffff\\] turn \\#ff46a0\\Kirby \\#00C7FF\\on \\#ffffff\\or \\#A02200\\off",
    kirby_command
    )