# To load this file in the vmd console/tk con type
# 'source waterbox.1.tcl' 

source waterbox.0.tcl

proc makebox {} {

    # We require the package TopoTools to replicate our
    # water molecule, set our bonding and angle topologies,
    # and write out our input lammps data file.

    # Build our waterbox
    set molid [build_tip3] 

    # https://sites.google.com/site/akohlmey/software/topotools
    package require topotools

    # Set the edge length of our periodic box to the 2*sigma_O-O bond
    # (3.1507) length. 
    molinfo $molid set {a b c} {3.1507 3.1507 3.1507}

    # Replicate our water molecule in x,y,z 5x5x5 using topotools'
    # replicatemol command.
    set newmol [::TopoTools::replicatemol $molid 5 5 5]

    # Our new replicated molecule has 125 molecules, but they lack
    # bonding and angle connectivities required for both visualization
    # and simulation with LAMMPS. Let's set our bonds and angles using
    # topotools, using the 'topo addbond', 'topo addangle' commands.

    # Make a selection of all {O H1} atoms, and retreive their indices
    # (required by addbond/addangle command).
    set sel [atomselect $newmol "name OH H1 H2"]

    # Get our list of indices, they are returned as a list of n atom indices
    # in the order in which they were loaded into VMD:
    # { idx_O1 idx_H11 idx_H21 idx_O2 idx_H12 idx_H22 ... idx_On idx_H1n  idx_H2n}
    set ids [$sel get index]
    # Loop over tuples of atom indices and add bonds and angles
    foreach {id1 id2 id3} $ids {
        topo addbond  $id1 $id2;  # Add bond between O-H1
        topo addbond  $id1 $id3;  # Add bond between O-H2
        topo addangle $id2 $id1 $id3; # Add angle H1-O-H2
    }

    ## Updated VMDs and internal data structures
    mol reanalyze $newmol
    topo -molid $newmol retypebonds
    topo -molid $newmol retypeangles

    # write out a protein structure file (topology), pdb (coordinates)
    # and a lammps data file.
    set fname tip3_125
    animate write pdb $fname\.pdb
    animate write psf $fname\.psf
    topo -molid $newmol writelammpsdata $fname\.data full

    # Delete our selection
    $sel delete

    # Return our new waterbox
    return $newmol
}
