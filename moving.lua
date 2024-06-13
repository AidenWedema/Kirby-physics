ACT_KIRBY_WALKING = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_FIRST_PERSON | ACT_FLAG_PAUSE_EXIT)
ACT_KIRBY_HOLD_WALKING = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_FIRST_PERSON | ACT_FLAG_PAUSE_EXIT)
-- ACT_KIRBY_HOLD_HEAVY_WALKING = allocate_mario_action()
-- ACT_KIRBY_TURNING_AROUND = allocate_mario_action()
-- ACT_KIRBY_FINISH_TURNING_AROUND = allocate_mario_action()
-- ACT_KIRBY_BRAKING = allocate_mario_action()
-- ACT_KIRBY_RIDING_SHELL_GROUND = allocate_mario_action()
-- ACT_KIRBY_CRAWLING = allocate_mario_action()
-- ACT_KIRBY_BURNING_GROUND = allocate_mario_action()
-- ACT_KIRBY_DECELERATING = allocate_mario_action()
-- ACT_KIRBY_HOLD_DECELERATING = allocate_mario_action()
-- ACT_KIRBY_BUTT_SLIDE = allocate_mario_action()
-- ACT_KIRBY_STOMACH_SLIDE = allocate_mario_action()
-- ACT_KIRBY_HOLD_BUTT_SLIDE = allocate_mario_action()
-- ACT_KIRBY_HOLD_STOMACH_SLIDE = allocate_mario_action()
-- ACT_KIRBY_DIVE_SLIDE = allocate_mario_action()
-- ACT_KIRBY_MOVE_PUNCHING = allocate_mario_action()
-- ACT_KIRBY_CROUCH_SLIDE = allocate_mario_action()
-- ACT_KIRBY_SLIDE_KICK_SLIDE = allocate_mario_action()
-- ACT_KIRBY_HARD_BACKWARD_GROUND_KB = allocate_mario_action()
-- ACT_KIRBY_HARD_FORWARD_GROUND_KB = allocate_mario_action()
-- ACT_KIRBY_BACKWARD_GROUND_KB = allocate_mario_action()
-- ACT_KIRBY_FORWARD_GROUND_KB = allocate_mario_action()
-- ACT_KIRBY_SOFT_BACKWARD_GROUND_KB = allocate_mario_action()
-- ACT_KIRBY_SOFT_FORWARD_GROUND_KB = allocate_mario_action()
-- ACT_KIRBY_GROUND_BONK = allocate_mario_action()
-- ACT_KIRBY_DEATH_EXIT_LAND = allocate_mario_action()
-- ACT_KIRBY_JUMP_LAND = allocate_mario_action()
-- ACT_KIRBY_FREEFALL_LAND = allocate_mario_action()
-- ACT_KIRBY_DOUBLE_JUMP_LAND = allocate_mario_action()
-- ACT_KIRBY_SIDE_FLIP_LAND = allocate_mario_action()
-- ACT_KIRBY_HOLD_JUMP_LAND = allocate_mario_action()
-- ACT_KIRBY_HOLD_FREEFALL_LAND = allocate_mario_action()
-- ACT_KIRBY_TRIPLE_JUMP_LAND = allocate_mario_action()
-- ACT_KIRBY_BACKFLIP_LAND = allocate_mario_action()
-- ACT_KIRBY_QUICKSAND_JUMP_LAND = allocate_mario_action()
-- ACT_KIRBY_HOLD_QUICKSAND_JUMP_LAND = allocate_mario_action()
-- ACT_KIRBY_LONG_JUMP_LAND = allocate_mario_action()


-- Actions functions
function act_kirby_walking(m)
    local startYaw = m.faceAngle.x

    m.actionState = 0
    update_walking_speed(m)
    local stepResult = perform_ground_step(m)

    if stepResult == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_KIRBY_FREEFALL, 0)
        set_mario_animation(m, MARIO_ANIM_GENERAL_FALL)
    elseif stepResult == GROUND_STEP_NONE then
        if m.heldObj ~= nil then
            set_mario_anim_with_accel(m, MARIO_ANIM_WALK_WITH_LIGHT_OBJ, m.forwardVel * 0x4000)
            play_step_sound(m, 12, 62)
        end
        if (m.intendedMag - m.forwardVel) > 16 then
            set_mario_particle_flags(m, PARTICLE_DUST, false)
        end
    elseif stepResult == GROUND_STEP_HIT_WALL then
        if m.heldObj == nil then
            push_or_sidle_wall(m, m.pos)
        else
            if m.forwardVel > 5 then mario_set_forward_vel(m, 5) end
        end
        m.actionTimer = 0
    end

    check_ledge_climb_down(m)
    tilt_body_walking(m, startYaw)

    if should_begin_sliding(m) ~= 0 then
        if m.heldObj == nil then
            return set_mario_action(m, ACT_KIRBY_BEGIN_SLIDING, 0)
        else
            return set_mario_action(m, ACT_KIRBY_HOLD_BEGIN_SLIDING, 0)
        end
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return drop_and_set_mario_action(m, ACT_KIRBY_CROUCH_SLIDE, 0)
    end

    if (m.input & INPUT_FIRST_PERSON) ~= 0 then
        return begin_braking_action(m)
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return do_kirby_jump(m)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        if m.heldObj ~= nil then
            set_mario_action(m, ACT_KIRBY_THROWING, 0)
        else
            do_kirby_suck(m)
        end
    end

    if (m.input & INPUT_ZERO_MOVEMENT) ~= 0 then
        mario_set_forward_vel(m, approach_f32(m.forwardVel, 0, 3, 3))
        if math.abs(m.forwardVel) < 2 then
            if m.heldObj ~= nil then
                return set_mario_action(m, ACT_KIRBY_HOLD_IDLE, 0)
            else
                return set_mario_action(m, ACT_KIRBY_IDLE, 0)
            end
        end
    end

    if analog_stick_held_back(m) ~= 0 and m.heldObj == nil then
        m.faceAngle.y = m.intendedYaw + 0x8000
        return set_mario_action(m, ACT_KIRBY_TURNING_AROUND, 0)
    end
    return 0
end

function act_kirby_hold_walking(m)local startYaw = m.faceAngle.x

    m.actionState = 0
    update_walking_speed(m)
    local stepResult = perform_ground_step(m)

    if stepResult == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_KIRBY_FREEFALL, 0)
        set_mario_animation(m, MARIO_ANIM_GENERAL_FALL)
    elseif stepResult == GROUND_STEP_NONE then
        if m.heldObj ~= nil then
            set_mario_anim_with_accel(m, MARIO_ANIM_WALK_WITH_LIGHT_OBJ, m.forwardVel * 0x4000)
            play_step_sound(m, 12, 62)
        end
        if (m.intendedMag - m.forwardVel) > 16 then
            set_mario_particle_flags(m, PARTICLE_DUST, false)
        end
    elseif stepResult == GROUND_STEP_HIT_WALL then
        if m.heldObj == nil then
            push_or_sidle_wall(m, m.pos)
        else
            if m.forwardVel > 5 then mario_set_forward_vel(m, 5) end
        end
        m.actionTimer = 0
    end

    check_ledge_climb_down(m)
    tilt_body_walking(m, startYaw)

    if should_begin_sliding(m) ~= 0 then
        if m.heldObj == nil then
            return set_mario_action(m, ACT_KIRBY_BEGIN_SLIDING, 0)
        else
            return set_mario_action(m, ACT_KIRBY_HOLD_BEGIN_SLIDING, 0)
        end
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return drop_and_set_mario_action(m, ACT_KIRBY_CROUCH_SLIDE, 0)
    end

    if (m.input & INPUT_FIRST_PERSON) ~= 0 then
        return begin_braking_action(m)
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return do_kirby_jump(m)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        if m.heldObj ~= nil then
            set_mario_action(m, ACT_KIRBY_THROWING, 0)
        else
            if (m.controller.buttonDown & A_BUTTON) ~= 0 then
                set_mario_action(m, ACT_KIRBY_JUMP_KICK, 0)
            end
        end
    end

    if (m.input & INPUT_ZERO_MOVEMENT) ~= 0 then
        mario_set_forward_vel(m, approach_f32(m.forwardVel, 0, 3, 3))
        if math.abs(m.forwardVel) < 2 then
            if m.heldObj ~= nil then
                return set_mario_action(m, ACT_KIRBY_HOLD_IDLE, 0)
            else
                return set_mario_action(m, ACT_KIRBY_IDLE, 0)
            end
        end
    end
    return 0
end

-- Hook functions
hook_mario_action(ACT_KIRBY_WALKING, act_kirby_walking)
hook_mario_action(ACT_KIRBY_HOLD_WALKING, act_kirby_hold_walking)
