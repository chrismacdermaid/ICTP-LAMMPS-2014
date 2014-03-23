 proc nordev {} {
     variable last
     if { [info exists last] } {
         set retval $last
         unset last
         return $retval
     }
     set v1 [expr { 2. * rand() - 1 }]
     set v2 [expr { 2. * rand() - 1 }]
     set rsq [expr { $v1*$v1 + $v2*$v2 }]
     while { $rsq > 1. } {
         set v1 [expr { 2. * rand() - 1 }]
         set v2 [expr { 2. * rand() - 1 }]
         set rsq [expr { $v1*$v1 + $v2*$v2 }]
     }
     set fac [expr { sqrt( -2. * log( $rsq ) / $rsq ) }]
     set last [expr { $v1 * $fac }]
     return [expr { $v2 * $fac }]
 }
