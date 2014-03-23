# movie03.tcl
# To run, in the vmd tckon type: 'source movie03.tcl'   

# Load a LAMMPS data file, a trajectory,
# set some representations to the liking,
# adjust the display size and rotate/zoom,
# loop over frames and render

# Script requires TopoTools and pbctools
package require topotools
package require pbctools

# Load the data file and trajectory dcd
set molid [topo readlammpsdata data.ab]
mol addfile 03.dcd type dcd waitfor all -molid $molid 

# Set the representation, delete the initial representation
# created by vmd

mol delrep 0 top 
mol representation CPK 2.0 0.30 10.0 10.0
mol color Name
mol selection {all}
mol material AOEdgy
mol addrep top

# Set the scene: adjust display height
# and rotate axes a bit, set the background
# to white
display resetview
display projection orthographic
display depthcue off
display height 5 
rotate x by -45; rotate y by 45; rotate z by 45
color Display Background white

# Draw the periodic box centered at the origin
pbc box_draw -center origin

# Get the number of frames
animate delete beg 0 end 0; # Delete first frame from topotools 
set nframes [molinfo $molid get numframes] 

# Loop over frames, calling render.
# Format the output filename as 03.snap.00001.tga
# Skip the first "junk" frame from lammpsdata
for {set i 0} {$i < $nframes} {incr i} {
      molinfo top set frame $i	
      render TachyonInternal\
        [format "snap-03.%04d.tga" $i]
}

## Encode the movie by calling an external script
vmdcon -info "Encoding ..."
exec /bin/sh 03-encode-vmd.sh
