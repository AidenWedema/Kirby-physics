
ACT_WATER_IDLE = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_IDLE | ACT_FLAG_SWIMMING | ACT_FLAG_SWIMMING_OR_FLYING | ACT_FLAG_WATER_OR_TEXT)
-- ACT_HOLD_WATER_IDLE = allocate_mario_action()
-- ACT_WATER_ACTION_END = allocate_mario_action()
-- ACT_HOLD_WATER_ACTION_END = allocate_mario_action()
-- ACT_DROWNING = allocate_mario_action()
-- ACT_BACKWARD_WATER_KB = allocate_mario_action()
-- ACT_FORWARD_WATER_KB = allocate_mario_action()
-- ACT_WATER_DEATH = allocate_mario_action()
-- ACT_WATER_SHOCKED = allocate_mario_action()
-- ACT_BREASTSTROKE = allocate_mario_action()
-- ACT_SWIMMING_END = allocate_mario_action()
-- ACT_FLUTTER_KICK = allocate_mario_action()
-- ACT_HOLD_BREASTSTROKE = allocate_mario_action()
-- ACT_HOLD_SWIMMING_END = allocate_mario_action()
-- ACT_HOLD_FLUTTER_KICK = allocate_mario_action()
-- ACT_WATER_SHELL_SWIMMING = allocate_mario_action()
-- ACT_WATER_THROW = allocate_mario_action()
-- ACT_WATER_PUNCH = allocate_mario_action()
-- ACT_WATER_PLUNGE = allocate_mario_action()
-- ACT_CAUGHT_IN_WHIRLPOOL = allocate_mario_action()
ACT_METAL_WATER_STANDING = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_IDLE | ACT_FLAG_SWIMMING | ACT_FLAG_SWIMMING_OR_FLYING | ACT_FLAG_WATER_OR_TEXT)
ACT_METAL_WATER_WALKING = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING | ACT_FLAG_SWIMMING_OR_FLYING | ACT_FLAG_WATER_OR_TEXT)
ACT_METAL_WATER_FALLING = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING | ACT_FLAG_SWIMMING_OR_FLYING | ACT_FLAG_WATER_OR_TEXT)
-- ACT_METAL_WATER_FALL_LAND = allocate_mario_action()
ACT_METAL_WATER_JUMP = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING | ACT_FLAG_SWIMMING_OR_FLYING | ACT_FLAG_WATER_OR_TEXT)
-- ACT_METAL_WATER_JUMP_LAND = allocate_mario_action()
-- ACT_HOLD_METAL_WATER_STANDING = allocate_mario_action()
-- ACT_HOLD_METAL_WATER_WALKING = allocate_mario_action()
-- ACT_HOLD_METAL_WATER_FALLING = allocate_mario_action()
-- ACT_HOLD_METAL_WATER_FALL_LAND = allocate_mario_action()
-- ACT_HOLD_METAL_WATER_JUMP = allocate_mario_action()
-- ACT_HOLD_METAL_WATER_JUMP_LAND = allocate_mario_action()

function act_water_idle(m)
end


function act_metal_water_standing(m)
end

function act_metal_water_walking(m) 
end

function act_metal_water_falling(m)
end


function act_metal_water_jump(m)
end

-- Hook functions
hook_mario_action(ACT_WATER_IDLE, act_water_idle)

hook_mario_action(ACT_METAL_WATER_STANDING, act_metal_water_standing)
hook_mario_action(ACT_METAL_WATER_WALKING, act_metal_water_walking)
hook_mario_action(ACT_METAL_WATER_FALLING, act_metal_water_falling)

hook_mario_action(ACT_METAL_WATER_JUMP, act_metal_water_jump)