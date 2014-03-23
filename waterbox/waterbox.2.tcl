# To load this file in the vmd console/tk con type
# 'source waterbox.2.tcl' 
# call 'randomize' to run 

# Requires routines for building the waterbox 
source waterbox.1.tcl

## A gaussian random number generator
source rand.tcl

## Randomize the orientations of the water molecules
## 'randomize 1' will produce a trajectory
proc randomize {{dump 0}} {

    set molid [makebox] 

    ## Get all of our residue numbers
    ## "residue" is a unique number corresponding
    ## to each residue assigned by vmd automatically
    set sel [atomselect $molid "all"]
    set waters [$sel get residue]

    ## Get the unique residues
    set waters [lsort -unique -integer $waters]
    set nwaters [llength $waters]

    $sel delete
    unset sel

    ## Create an array of selections for each residue
    foreach w $waters {
        set sel($w) [atomselect $molid "residue $w"]
    }

    puts "randomizing...."
    for {set iter 0} {$iter < 5000} {incr iter} {

        ## generate a random number between 0 and nwaters-1
        set n [expr {int(rand() * $nwaters)}]

        ## generate a random angle about which to rotate our water
        ## molecule
        set theta [expr {floor(rand() * 360) - 180.00}]

        ## get our random water's residue id
        set w [lindex $waters $n]

        ## save our water molecules coordinates before rotation
        set xyz [$sel($w) get {x y z}]

        ## Pick a random point on a sphere with radius 1A
        set v [vecnorm [list [nordev] [nordev] [nordev]]]

        ## Rotate the water molecule about vector $v an amount $theta
        $sel($w) move [trans center [lindex $xyz 0]\
                           offset [lindex $xyz 0] axis $v $theta deg]

        if {$dump} {
          ## Create a trajectory showing randomization
          animate dup $molid            
        }

        # Force the display to update
        display update
    }

    ## Cleanup our selections
    foreach w $waters {
        $sel($w) delete
    }
   
    set fname tip3_125_rand

    ## Write out our trajectory, pdb and lammps data file
    if {$dump} {animate write dcd $fname\.dcd}
    set nframes [expr {[molinfo $molid get numframes] - 1}]
    animate write pdb $fname\.pdb beg $nframes end $nframes $molid
    
    topo -molid $molid writelammpsdata $fname\.data full

    ## Return the randomize molecule
    return $molid 
}



