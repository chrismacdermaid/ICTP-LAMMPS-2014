# To load, in the VMD console/TKcon type
# 'source writepdb.tcl'

# Usage: writePDB $sel

## Write out a formatted p 
proc writePDB {sel} {

# Loop over each atom property in parallel  
foreach charge [$sel get charge]\
      type [$sel get type]\
      atomname [$sel get name]\
      resname [$sel get resname]\
      resid [$sel get resid]\
      X [$sel get x]\
      Y [$sel get y]\
      Z [$sel get z]\
      chain [$sel get chain]\
      occ [$sel get occupancy]\
      beta [$sel get beta]\
      segid [$sel get segid]\
      ele [$sel get element]\
      serial [$sel get serial] {

     # Display it using the PDB format  
     puts [format "%-6s%5d %4s %3s %s%4d    %8.3f%8.3f%8.3f%6.2f%6.2f       %-4s%2s"\
                  "ATOM  " $serial $atomname $resname $chain\
                  $resid $X $Y $Z $occ $beta $segid $ele]
  }
}
