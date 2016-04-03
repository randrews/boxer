-- Default config file for Boxer

-- Whether to generate a lid (and slots, etc to hold it) or not
has_lid = true

----------------------------------------
-- Material parameters -----------------
----------------------------------------

-- You probably don't need to change these, but if you have a different material you can
-- set it up here.
material = {
    -- Thickness of the material, in mm. Note that what's commonly
    -- sold as 1/8" is actually 3mm.
    thickness = 3,

    -- The margin is the distance between the edge of a slot and the edge of the material.
    -- This should probably be equal to thickness.
    margin = 3,

    -- Some corners are rounded, this says how rounded.
    corner_radius = 3,

    -- Zip tie geometry: the X plates are held on by zip ties fitting through slots.
    -- This determines the geometry of those slots.
    zip_slot_width = 3,
    zip_slot_height = 2,
    zip_slot_separation = 2,

    -- Height of finger hole in lid
    finger_height = 15
}
