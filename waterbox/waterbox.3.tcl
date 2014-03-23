# To load this file in the vmd console/tk con type
# 'source waterbox.3.tcl' 

## Requires routines for building the waterbox
source waterbox.1.tcl

## A gaussian random number generator
source rand.tcl

# Attempt crude Monte-Carlo optimization of
# water using non-bonded interactions.
# optimize flag 
proc optimize {{dump 0}} {

    set molid [makebox] 

    ## Get all of our residue numbers
    ## "residue" is a unique number corresponding
    ## to each residue assigned by vmd automatically
    set sel [atomselect $molid "all"]
    set waters [$sel get residue]
    set indices [$sel get index]
    set natoms [$sel num]

    ## Get the unique residues
    set unqwaters [lsort -unique -integer $waters]
    set nwaters [llength $unqwaters]

    ## Apply nonbonded parameters to all atoms using the
    ## empty occupancy and beta properties

    # !TIP3P LJ parameters
    # HT       0.0       -0.046     0.2245
    # OT       0.0       -0.1521    1.7682

    foreach name {OH H1 H2}\
        rmin {1.7682 0.2245 0.2245}\
        epsilon {-0.1521 -0.046 -0.046} {
            set sel1 [atomselect $molid "name $name"]
            $sel1 set occupancy $rmin
            $sel1 set beta $epsilon
        }

    ## Build a crude bonded exclusion list
    set bonds {}
    set bl [topo -molid $molid getbondlist]
    foreach i $indices {
        set ids {}
        foreach b [lsearch -integer -inline -all -index 0 $bl $i] {
            lappend ids [lindex $b 1]
        }
        foreach b [lsearch -integer -inline -all -index 1 $bl $i] {
            lappend ids [lindex $b 0]}
        lappend bonds [concat $ids]
    }

    ## Get per-atom vdw properties
    set rmin [$sel get occupancy]
    set eps  [$sel get beta]
    $sel delete
    unset sel

    ## Calculate initial non-bonded energies on a per-residue basis
    array unset Er
    foreach i $indices r1 $rmin e1 $eps b $bonds w $waters {
        foreach j $indices r2 $rmin e2 $eps {
            if {$i == $j || [lsearch -integer $b $j] >= 0} {continue}; # Exclude bonded atoms and self

            lappend Er($w) [measure energy vdw [list $i $j]\
                                rmin1 $r1 rmin2 $r2 eps1 $e1 eps2 $e2]; #lj
            lappend Er($w) [measure energy elect [list $i $j]]
        }
    }

    ## Sum up our energies for each water and calculate our systems total energy
    set Et 0.0
    foreach w $waters {
        set Er($w) [vecsum $Er($w)]
        set Et [expr {$Et + $Er($w)}]
    }

    ## Create an array of selections for each residue
    foreach w $unqwaters {
        set sel($w) [atomselect $molid "residue $w"]
    }

    puts "optimizing..."
    for {set iter 0} {$iter < 5000} {incr iter} {

        ## generate a random number between 0 and nwaters-1
        set n [expr {int(rand() * $nwaters)}]

        ## get our random water's residue id
        set w [lindex $unqwaters $n]

        ## Pick a random point on a sphere with radius 1A
        set v [vecnorm [list [nordev] [nordev] [nordev]]]

        ## generate a random angle about which to rigidly rotate our
        ## water molecule
        set theta [expr {floor(rand() * 360) - 180.00}]

        ## save our water molecules coordinates before rotation
        set xyz [$sel($w) get {x y z}]

        ## Rotate the water molecule about vector $v an amount $theta
        $sel($w) move [trans center [lindex $xyz 0]\
                           offset [lindex $xyz 0] axis $v $theta deg]

        ## Calculate new energy involving only the atoms from the new configuration
        ## we use VMD's "measure energy" command to calculate the vdw and coulomb interactions
        ## between our randomly selected molecule and all it's neighbors.
        set E {}
        foreach i [$sel($w) get index]\
            r1 [$sel($w) get occupancy]\
            e1 [$sel($w) get beta] {
                foreach j $indices r2 $rmin e2 $eps b $bonds {
                    if {$i == $j || [lsearch -integer $b $i] >= 0 } {continue}

                    lappend E [measure energy vdw [list $i $j]\
                                   rmin1 $r1 rmin2 $r2 eps1 $e1 eps2 $e2]; #lj
                    lappend E [measure energy elect [list $i $j]]; #coul

                }
            }

        set E [vecsum $E]
        set dE [expr $E - $Er($w)]

        ## If our new configuration lowers the energy, accept it
        ## otherwise accept it with probability consistent with a
        ## Boltzman distribution.
        if { $dE < 0 || [expr {exp(-0.25*$dE) > rand()}]} {
            set Er($w) $E
            set Et [expr {$Et + $dE}]
            if {$dump} {animate dup $molid}
        } else {$sel($w) set {x y z} $xyz}
    }

    ## Cleanup our selections
    foreach w $unqwaters {
        $sel($w) delete
    }

    ## Write out our trajectory, pdb and optimized lammps data file
    if {$dump} {animate write dcd tip3_opt.dcd}
    set nframes [expr {[molinfo $molid get numframes] - 1}]
    animate write pdb tip3_opt.pdb beg $nframes end $nframes $molid

    topo -molid $molid writelammpsdata tip3_opt\.data full
}
