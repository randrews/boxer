-- Example config file for Boxer

--------------------------------------------------------------------------------
-- Introduction:
--
-- This config file is loaded by Boxer to define the dimensions / layout of a
-- box. Boxer will generate a DXF based on this file that can be used to laser
-- cut a box out of plywood / acrylic.
--
-- All measurements are in millimeters. The boxes are all the same basic form:
-- a tray with compartments separated by internal dividers, consisting of a base
-- plate, two side walls for the +y and -y edges, and two plates that slot on to
-- the base and sides on the +x and -x edges, held on by zip ties. Optionally a
-- lid will be generated that will slide through slots on the +x and -x plates.
--
-- All of the geometry is customizable. No provision is made for arranging or
-- plating the pieces, you need to open the file in a CAD program to arrange
-- them to fit on to a work piece.

----------------------------------------
-- Basic parameters --------------------
----------------------------------------

-- Width is the X dimension. Inner width is the distance between the inner edges of the
-- +x and -x plates, outer_width is the distance between their outer edges. Geometry
-- check will raise an error if the inner width is too great for the outer width. You
-- only need to specify one of these, the other will be auto-calculated.
inner_width = 150

-- Outer width of a box is:
-- inner_width + 2 * (material.thickness + material.zip_slot_width + material.margin)
outer_width = 168

-- Height is the same thing as width, but in the Y direction: specify one of inner or
-- outer, and an error is raised if the geometry doesn't work:
inner_height = 80

-- Outer height of a box is:
-- inner_height + 2 * (material.thickness + material.margin)
outer_height = 92

-- Depth works the same way but in Z:
inner_depth = 30

-- Outer depth of a box depends on whether there's a lid or not. Without a lid, the
-- outer depth is material.thickness + material.margin more than the inner depth (room
-- for the base plate of the box and margin on the sides). With a lid, it's:
-- inner_depth + 2 * (material.thickness + material.margin)
outer_depth = 42

-- Whether to generate a lid (and slots, etc to hold it) or not
has_lid = true

-- The widths of the columns. These (and their dividers) need to sum to inner_width
columns = {
    40, 20, 20, 61
}

-- Heights of the rows. These (and their dividers) need to sum to inner_height
rows = {
    20, 20, 34
}

-- How many columns (from the left) the horizontal dividers split.
split_columns = 2

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
