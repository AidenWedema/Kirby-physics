ACT_KIRBY_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING | ACT_FLAG_AIR | ACT_FLAG_CONTROL_JUMP_HEIGHT |  ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION | ACT_FLAG_SHORT_HITBOX)
-- ACT_KIRBY_DOUBLE_JUMP = allocate_mario_action()
ACT_KIRBY_FREEFALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_KIRBY_HOLD_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING | ACT_FLAG_AIR | ACT_FLAG_CONTROL_JUMP_HEIGHT | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_KIRBY_HOLD_FREEFALL = allocate_mario_action(ACT_GROUP_AIRBORNE| ACT_FLAG_MOVING | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
-- ACT_KIRBY_SIDE_FLIP = allocate_mario_action()
-- ACT_KIRBY_WALL_KICK_AIR = allocate_mario_action()
-- ACT_KIRBY_TWIRLING = allocate_mario_action()
-- ACT_KIRBY_WATER_JUMP = allocate_mario_action()
-- ACT_KIRBY_HOLD_WATER_JUMP = allocate_mario_action()
-- ACT_KIRBY_STEEP_JUMP = allocate_mario_action()
-- ACT_KIRBY_BURNING_JUMP = allocate_mario_action()
-- ACT_KIRBY_BURNING_FALL = allocate_mario_action()
-- ACT_KIRBY_TRIPLE_JUMP = allocate_mario_action()
-- ACT_KIRBY_BACKFLIP = allocate_mario_action()
-- ACT_KIRBY_LONG_JUMP = allocate_mario_action()
-- ACT_KIRBY_RIDING_SHELL_JUMP = allocate_mario_action()
-- ACT_KIRBY_RIDING_SHELL_FALL = allocate_mario_action()
-- ACT_KIRBY_DIVE = allocate_mario_action()
-- ACT_KIRBY_AIR_THROW = allocate_mario_action()
-- ACT_KIRBY_BACKWARD_AIR_KB = allocate_mario_action()
-- ACT_KIRBY_FORWARD_AIR_KB = allocate_mario_action()
-- ACT_KIRBY_HARD_FORWARD_AIR_KB = allocate_mario_action()
-- ACT_KIRBY_HARD_BACKWARD_AIR_KB = allocate_mario_action()
-- ACT_KIRBY_SOFT_BONK = allocate_mario_action()
ACT_KIRBY_AIR_HIT_WALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
-- ACT_KIRBY_FORWARD_ROLLOUT = allocate_mario_action()
-- ACT_KIRBY_SHOT_FROM_CANNON = allocate_mario_action()
-- ACT_KIRBY_BUTT_SLIDE_AIR = allocate_mario_action()
-- ACT_KIRBY_HOLD_BUTT_SLIDE_AIR = allocate_mario_action()
-- ACT_KIRBY_LAVA_BOOST = allocate_mario_action()
-- ACT_KIRBY_GETTING_BLOWN = allocate_mario_action()
-- ACT_KIRBY_BACKWARD_ROLLOUT = allocate_mario_action()
-- ACT_KIRBY_CRAZY_BOX_BOUNCE = allocate_mario_action()
-- ACT_KIRBY_SPECIAL_TRIPLE_JUMP = allocate_mario_action()
-- ACT_KIRBY_THROWN_FORWARD = allocate_mario_action()
-- ACT_KIRBY_THROWN_BACKWARD = allocate_mario_action()
-- ACT_KIRBY_FLYING_TRIPLE_JUMP = allocate_mario_action()
-- ACT_KIRBY_SLIDE_KICK = allocate_mario_action()
-- ACT_KIRBY_JUMP_KICK = allocate_mario_action()
-- ACT_KIRBY_FLYING = allocate_mario_action()
-- ACT_KIRBY_RIDING_HOOT = allocate_mario_action()
-- ACT_KIRBY_TOP_OF_POLE_JUMP = allocate_mario_action()
-- ACT_KIRBY_VERTICAL_WIND = allocate_mario_action()

-- Actions functions
function act_kirby_jump(m)
    m.vel.y = 52.0
    kirby_common_air_action_step(m, ACT_KIRBY_FREEFALL_LAND, ACT_KIRBY_WALKING, MARIO_ANIM_FORWARD_SPINNING, AIR_STEP_CHECK_LEDGE_GRAB | AIR_STEP_CHECK_HANG, true, true)

    if m.actionTimer == 0 then
        play_character_sound_if_no_flag(m, CHAR_SOUND_YAH_WAH_HOO, MARIO_ACTION_SOUND_PLAYED)
    end
    if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
        set_mario_action(m, ACT_KIRBY_HOVER_JUMP, 0)
    end
end


function act_kirby_freefall(m)
    local animation = 0
    local landAction = 0
    m.vel.y = math.max(m.vel.y - 0.5, -50.0)
    if (m.input & INPUT_A_PRESSED) ~= 0 then
        set_mario_action(m, ACT_KIRBY_HOVER_JUMP, 0)
    end
    if m.heldObj == nil then
        if m.actionArg == 0 then
            animation = MARIO_ANIM_GENERAL_FALL
        elseif m.actionArg == 1 then
            animation = MARIO_ANIM_FALL_FROM_SLIDE
        elseif m.actionArg == 2 then
            animation = MARIO_ANIM_FALL_FROM_SLIDE_KICK
        end
        landAction = ACT_FREEFALL_LAND
    else
        animation = MARIO_ANIM_FALL_WITH_LIGHT_OBJ
        landAction = ACT_HOLD_FREEFALL_LAND
    end
    kirby_common_air_action_step(m, ACT_KIRBY_IDLE, ACT_KIRBY_WALKING, animation, AIR_STEP_CHECK_LEDGE_GRAB, true, true)
end

function act_kirby_hold_jump(m)
    m.vel.y = 52.0
    kirby_common_air_action_step(m, ACT_FREEFALL_LAND, ACT_KIRBY_WALKING, MARIO_ANIM_FORWARD_SPINNING, AIR_STEP_CHECK_LEDGE_GRAB | AIR_STEP_CHECK_HANG, true, true)
end

function act_kirby_hold_freefall(m)
end


function act_air_hit_wall(m)
end

-- Hook functions
hook_mario_action(ACT_KIRBY_JUMP, act_kirby_jump)

hook_mario_action(ACT_KIRBY_FREEFALL, act_kirby_freefall)
hook_mario_action(ACT_KIRBY_HOLD_JUMP, act_kirby_hold_jump)
hook_mario_action(ACT_KIRBY_HOLD_FREEFALL, act_kirby_hold_freefall)

hook_mario_action(ACT_KIRBY_AIR_HIT_WALL, act_air_hit_wall)