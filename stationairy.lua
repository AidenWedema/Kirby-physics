ACT_KIRBY_IDLE = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_IDLE | ACT_FLAG_ALLOW_FIRST_PERSON | ACT_FLAG_PAUSE_EXIT)
-- ACT_KIRBY_START_SLEEPING = allocate_mario_action()
-- ACT_KIRBY_SLEEPING = allocate_mario_action()
-- ACT_KIRBY_WAKING_UP = allocate_mario_action()
-- ACT_KIRBY_PANTING = allocate_mario_action()
-- ACT_KIRBY_HOLD_PANTING_UNUSED = allocate_mario_action()
-- ACT_KIRBY_HOLD_IDLE = allocate_mario_action()
-- ACT_KIRBY_HOLD_HEAVY_IDLE = allocate_mario_action()
-- ACT_KIRBY_IN_QUICKSAND = allocate_mario_action()
-- ACT_KIRBY_STANDING_AGAINST_WALL = allocate_mario_action()
-- ACT_KIRBY_COUGHING = allocate_mario_action()
-- ACT_KIRBY_SHIVERING = allocate_mario_action()
-- ACT_KIRBY_CROUCHING = allocate_mario_action()
-- ACT_KIRBY_START_CROUCHING = allocate_mario_action()
-- ACT_KIRBY_STOP_CROUCHING = allocate_mario_action()
-- ACT_KIRBY_START_CRAWLING = allocate_mario_action()
-- ACT_KIRBY_STOP_CRAWLING = allocate_mario_action()
-- eCT_KIRBY_SLIDE_KICK_SLIDE_STOP = allocate_mario_action()
-- eCT_KIRBY_SHOCKWAVE_BOUNCE = allocate_mario_action()
-- ACT_KIRBY_FIRST_PERSON = allocate_mario_action()
-- ACT_KIRBY_JUMP_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_DOUBLE_JUMP_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_FREEFALL_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_SIDE_FLIP_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_HOLD_JUMP_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_HOLD_FREEFALL_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_AIR_THROW_LAND = allocate_mario_action()
-- ACT_KIRBY_LAVA_BOOST_LAND = allocate_mario_action()
-- ACT_KIRBY_TWIRL_LAND = allocate_mario_action()
-- ACT_KIRBY_TRIPLE_JUMP_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_BACKFLIP_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_LONG_JUMP_LAND_STOP = allocate_mario_action()
-- ACT_KIRBY_GROUND_POUND_LAND = allocate_mario_action()
-- ACT_KIRBY_BRAKING_STOP = allocate_mario_action()
-- ACT_KIRBY_BUTT_SLIDE_STOP = allocate_mario_action()
-- ACT_KIRBY_HOLD_BUTT_SLIDE_STOP = allocate_mario_action()


function mario_drop_held_object(m)
    if m.heldObj ~= nil then
        if m.heldObj.behavior == segmented_to_virtual(bhvKoopaShellUnderwater) then
            stop_shell_music();
        end

        obj_set_held_state(m.heldObj, bhvCarrySomething4);

        -- ! When dropping an object instead of throwing it, it will be put at Mario's
        -- y-positon instead of the HOLP's y-position. This fact is often exploited when
        -- cloning objects.
        m.heldObj.oPosX = m.marioBodyState.heldObjLastPosition[0];
        m.heldObj.oPosY = m.pos[1];
        m.heldObj.oPosZ = m.marioBodyState.heldObjLastPosition[2];

        m.heldObj.oMoveAngleYaw = m.faceAngle[1];

        m.heldObj = nil;
    end
end

function check_common_idle_cancels(m)
    mario_drop_held_object(m)

    -- if m.floor.normal.y < 0.29237169 then
    --     return mario_push_off_steep_floor(m, ACT_KIRBY_FREEFALL, 0)
    -- end

    -- if (m.input & INPUT_STOMPED) ~= 0 then
    --     return set_mario_action(m, ACT_KIRBY_SHOCKWAVE_BOUNCE, 0)
    -- end

    -- if (m.input & INPUT_A_PRESSED) ~= 0 then
    --     return set_jumping_action(m, ACT_KIRBY_JUMP, 0)
    -- end

    -- if (m.input & INPUT_OFF_FLOOR) ~= 0 then
    --     return set_mario_action(m, ACT_KIRBY_FREEFALL, 0)
    -- end

    -- if (m.input & INPUT_ABOVE_SLIDE) ~= 0 then
    --     return set_mario_action(m, ACT_KIRBY_BEGIN_SLIDING, 0)
    -- end

    -- if (m.input & INPUT_FIRST_PERSON) ~= 0 then
    --     return set_mario_action(m, ACT_KIRBY_FIRST_PERSON, 0)
    -- end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        m.faceAngle[1] = m.intendedYaw
        return set_mario_action(m, ACT_KIRBY_WALKING, 0)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_KIRBY_PUNCHING, 0)
    end

    if (m.input & INPUT_Z_DOWN) ~= 0 then
        return set_mario_action(m, ACT_KIRBY_START_CROUCHING, 0)
    end

    return false
end

-- Actions functions
function act_kirby_idle(m)
    stationary_ground_step(m)

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_KIRBY_JUMP, 0)
    end 

    if m.quicksandDepth > 30.0 then
        return set_mario_action(m, ACT_KIRBY_IN_QUICKSAND, 0)
    end

    if (m.input & INPUT_IN_POISON_GAS) ~= 0 then
        return set_mario_action(m, ACT_KIRBY_COUGHING, 0)
    end

    if ((m.actionArg & 1) == 0 and m.health < 0x300) then
        return set_mario_action(m, ACT_KIRBY_PANTING, 0)
    end

    if check_common_idle_cancels(m) ~= 0 then
        return 1
    end
end

-- Hook functions
hook_mario_action(ACT_KIRBY_IDLE, act_kirby_idle)
