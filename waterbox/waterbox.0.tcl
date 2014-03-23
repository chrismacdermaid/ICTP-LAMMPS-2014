#!/usr/bin/tclsh

# To load this file in the vmd console/tk con type
# 'source waterbox.0.tcl' 

# Create a TIP3 water molecule
# build_tip3
proc build_tip3 {} {

    # Create a new molecule that holds three "empty" atoms
    # return the molecule id and store in molid
    set molid [mol new atoms 3]

    # Add a frame to hold atomic data
    animate dup $molid

    # Define O-H bond length in angstroms and H-O-H angle in degrees
    set r 0.9572; set theta 104.52

    # Use VMDs vector/matrix routines to move the atoms into their
    # equilibrium positions and assign their coordinates
    set o {0.0 0.0 0.0};      # coordinate of Oxygen atom
    set h1 [list $r 0.0 0.0]; # coordinate of first hydrogen atom

    # We need to calculate the position of the second hydrogen atom
    # by rotating the v = {h1-o} vector a value $theta in the xy-plane
    set v [vecsub $h1 $o]

    # Create rotation matrix corresponding to a rotation about the
    # z axis a value $theta
    set R [transabout {0.0 0.0 1.0} $theta deg]

    # Multiply the vector v with R, this is the new position of atom h2
    set h2 [vectrans $R $v]

    # Create a selection of the three "empty" atoms so we can
    # set their coordinates and their molecular properties
    set sel [atomselect $molid "all"]
    set xyz [list $o $h1 $h2]
    $sel set {x y z} $xyz

    # Now we need to set the atomic mass, charge radius, and name of each
    # of the atoms. We create a list-of-sublists, where each sublist
    # contains the properties of each atom. The order of the properties
    # in each sublist must be consistent across the sublists
    # { {o_mass  o_charge  o_radius  o_name  o_type}\
        #   {h1_mass h1_charge h1_radius h1_name h1_type}\
        #   {h2_mass h2_charge h2_radius h2_name h2_type}}
    # Properties available here: http://lammps.sandia.gov/doc/Section_howto.html#howto_8
    set props { {15.9994 -0.830 1.299 OH OT}\
                    {1.008    0.415 1.00  H1 HT}\
                    {1.008    0.415 1.00  H2 HT} }
    $sel set {mass charge radius name type} $props

    # reanalyze the mol to let vmd know the atoms have their properties set
    mol reanalyze $molid

    # Delete our selection (always a good idea)
    $sel delete

    # Have the procedure return our new molecules ID
    return $molid
}
