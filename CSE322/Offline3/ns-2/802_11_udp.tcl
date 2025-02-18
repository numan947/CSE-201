################################################################802.11 in Grid topology with cross folw
set cbr_size 64 ; #[lindex $argv 2]; #4,8,16,32,64
set cbr_rate 11.0Mb
set cbr_pckt_per_sec [lindex $argv 3]; #numan947
set cbr_interval [expr 1.0/$cbr_pckt_per_sec] ;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second
#set cbr_interval 0.00005 ; #[expr 1/[lindex $argv 2]] ;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second
set num_row [lindex $argv 0] ;#number of row
set num_col [lindex $argv 0] ;#number of column
set x_dim 150 ; #[lindex $argv 1]
set y_dim 150 ; #[lindex $argv 1]
set time_duration 25 ; #[lindex $argv 5] ;#50
set start_time 50 ;#100
set parallel_start_gap 0.0
set cross_start_gap 0.0

set number_of_nodes [lindex $argv 1] ; #numan947
set node_speed [lindex $argv 4] ; #numan947


#############################################################ENERGY PARAMETERS
set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules

set val(idlepower_11) 869.4e-3			;#LEAP (802.11g) 
set val(rxpower_11) 1560.6e-3			;#LEAP (802.11g)
set val(txpower_11) 1679.4e-3			;#LEAP (802.11g)
set val(sleeppower_11) 37.8e-3			;#LEAP (802.11g)
set val(transitionpower_11) 176.695e-3		;#LEAP (802.11g)	??????????????????????????????/
set val(transitiontime_11) 2.36			;#LEAP (802.11g)

#set val(idlepower_11) 900e-3			;#Stargate (802.11b) 
#set val(rxpower_11) 925e-3			;#Stargate (802.11b)
#set val(txpower_11) 1425e-3			;#Stargate (802.11b)
#set val(sleeppower_11) 300e-3			;#Stargate (802.11b)
#set val(transitionpower_11) 200e-3		;#Stargate (802.11b)	??????????????????????????????/
#set val(transitiontime_11) 3			;#Stargate (802.11b)

#puts "$MAC/802_11.dataRate_"
Mac/802_11 set dataRate_ 11Mb

#CHNG
set num_parallel_flow 0 ;#[lindex $argv 0]	# along column
set num_cross_flow 0 ;#[lindex $argv 0]		#along row
set num_random_flow [lindex $argv 2]
set num_sink_flow 0;#sink
set sink_node 100 ;#sink id, dummy here; updated next

set grid 0
set extra_time 10 ;#10

#set tcp_src Agent/TCP/Vegas ;# Agent/TCP or Agent/TCP/Reno or Agent/TCP/Newreno or Agent/TCP/FullTcp/Sack or Agent/TCP/Vegas
#set tcp_sink Agent/TCPSink ;# Agent/TCPSink or Agent/TCPSink/Sack1

set tcp_src Agent/UDP
set tcp_sink Agent/Null


# TAHOE:	Agent/TCP		Agent/TCPSink
# RENO:		Agent/TCP/Reno		Agent/TCPSink
# NEWRENO:	Agent/TCP/Newreno	Agent/TCPSink
# SACK: 	Agent/TCP/FullTcp/Sack	Agent/TCPSink/Sack1
# VEGAS:	Agent/TCP/Vegas		Agent/TCPSink
# FACK:		Agent/TCP/Fack		Agent/TCPSink
# LINUX:	Agent/TCP/Linux		Agent/TCPSink

#	http://research.cens.ucla.edu/people/estrin/resources/conferences/2007may-Stathopoulos-Lukac-Dual_Radio.pdf

#set frequency_ 2.461e+9
#Phy/WirelessPhy set Rb_ 11*1e6            ;# Bandwidth
#Phy/WirelessPhy set freq_ $frequency_



set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
#set val(prop) Propagation/FreeSpace ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
#set val(mac) SMac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(rp) AODV ; #[lindex $argv 4] ;# routing protocol

Mac/802_11 set syncFlag_ 1

Mac/802_11 set dutyCycle_ cbr_interval

set nm multi_radio_802_11_random.nam
#set tr /home/ubuntu/ns2\ programs/raw_data/multi_radio_802_11_random.tr
set tr multi_radio_802_11_random.tr
set topo_file topo_multi_radio_802_11_random.txt

#set topo_file 5.txt
# 
# Initialize ns
#
set ns_ [new Simulator]

set tracefd [open $tr w]
$ns_ trace-all $tracefd

#$ns_ use-newtrace ;# use the new wireless trace file format

set namtrace [open $nm w]
$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim

#set topofilename "topo_ex3.txt"
set topofile [open $topo_file "w"]

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim
#$topo load_flatgrid 1000 1000

if {$num_sink_flow > 0} { ;#sink
	create-god [expr $number_of_nodes + 1 ] ;#numan947
} else {
	create-god [expr $number_of_nodes ] ;#numan947
}


#remove-all-packet-headers
#add-packet-header DSDV AODV ARP LL MAC CBR IP



#set val(prop)		Propagation/TwoRayGround
#set prop	[new $val(prop)]

$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF \
			 -energyModel $val(energymodel_11) \
			 -idlePower $val(idlepower_11) \
			 -rxPower $val(rxpower_11) \
			 -txPower $val(txpower_11) \
          		 -sleepPower $val(sleeppower_11) \
          		 -transitionPower $val(transitionpower_11) \
			 -transitionTime $val(transitiontime_11) \
			 -initialEnergy $val(initialenergy_11)


#          		 -transitionTime 0.005 \
 

puts "start node creation"
# for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
# 	set node_($i) [$ns_ node]
# #	$node_($i) random-motion 0
# }


#numan947

for {set i 0} {$i < $number_of_nodes} {incr i} {
	set node_($i) [$ns_ node]
#	$node_($i) random-motion 0
}


#numan947 create random motion
for {set i 0} {$i < $number_of_nodes} {incr i} {
    set x_pos [expr rand()*$x_dim]
    set y_pos [expr rand()*$y_dim]
    set random_time [expr rand()* ([expr $start_time + $time_duration ])]
    $ns_ at $random_time "$node_($i) setdest $x_pos $y_pos $node_speed";
}



if {$num_sink_flow > 0} { ;#sink
	
	# set sink_node [expr $num_row*$num_col] ;#sink id

	set sink_node $number_of_nodes ;#numan947  

	set node_($sink_node) [$ns_ node]
	$node_($sink_node) set X_ $x_dim
	$node_($sink_node) set Y_ $y_dim;
	$node_($sink_node) set Z_ 0.0
	puts -nonewline $topofile "SINK NODE $sink_node : at $x_dim $y_dim \n"
	# if {$sink_node < $num_row*$num_col} {
	# 	puts "*********ERROR: SINK NODE id($sink_node) is too LOW********"		
	# }

	if {$sink_node < $number_of_nodes} {
		puts "*********ERROR: SINK NODE id($sink_node) is too LOW********"		
	}

	set sink_start_gap [expr 1.0/$num_sink_flow]
}



#FULL CHNG
set x_start [expr $x_dim/($num_col*2)];
set y_start [expr $y_dim/($num_row*2)];
set i 0;




#RANDOMLY PLACE THE NODES, #numan947
if {$grid == 0} {
	while {$i < $number_of_nodes } {

		set m $i

		set x_pos [expr int($x_dim*rand())] ;#random settings
		set y_pos [expr int($y_dim*rand())] ;#random settings

		$node_($m) set X_ $x_pos;
		$node_($m) set Y_ $y_pos;
		$node_($m) set Z_ 0.0
		puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"

		incr i ;

	}
};





# while {$i < $num_row } {
# #in same column
#     for {set j 0} {$j < $num_col } {incr j} {
# #in same row
# 	set m [expr $i*$num_col+$j];
# #	$node_($m) set X_ [expr $i*240];
# #	$node_($m) set Y_ [expr $k*240+20.0];
# #CHNG
# 	if {$grid == 1} {
# 		set x_pos [expr $x_start+$j*($x_dim/$num_col)];#grid settings
# 		set y_pos [expr $y_start+$i*($y_dim/$num_row)];#grid settings
# 	} else {
# 		set x_pos [expr int($x_dim*rand())] ;#random settings
# 		set y_pos [expr int($y_dim*rand())] ;#random settings
# 	}
# 	$node_($m) set X_ $x_pos;
# 	$node_($m) set Y_ $y_pos;
# 	$node_($m) set Z_ 0.0
# #	puts "$m"
# 	puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
#     }
#     incr i;
# }; 




if {$grid == 1} {
	puts "GRID topology"
} else {
	puts "RANDOM topology"
}
puts "node creation complete"
#CHNG
if {$num_parallel_flow > $num_row} {
	set num_parallel_flow $num_row
}

#CHNG
if {$num_cross_flow > $num_col} {
	set num_cross_flow $num_col
}

#CHNG
for {set i 0} {$i < [expr $num_parallel_flow + $num_cross_flow + $num_random_flow  + $num_sink_flow]} {incr i} { ;#sink
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]

	set udp_($i) [new $tcp_src]
	$udp_($i) set class_ $i
	set null_($i) [new $tcp_sink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}

} 

################################################PARALLEL FLOW

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set udp_node $i
	set null_node [expr $i+(($num_col)*($num_row-1))];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"
} 

#  $ns_ attach-agent $node_(0) $udp_(0)
#  $ns_ attach-agent $node_(6) $null_(0)

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}
#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
} 

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns_ at [expr $start_time+$i*$parallel_start_gap] "$cbr_($i) start"
}
####################################CROSS FLOW
#CHNG
set k $num_parallel_flow 
#for {set i 1} {$i < [expr $num_col-1] } {incr i} {
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set udp_node [expr $i*$num_col];#CHNG
	set null_node [expr ($i+1)*$num_col-1];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($k)
  	$ns_ attach-agent $node_($null_node) $null_($k)
	puts -nonewline $topofile "CROSS: Src: $udp_node Dest: $null_node\n"
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns_ connect $udp_($k) $null_($k)
	incr k
}
#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set cbr_($k) [new Application/Traffic/CBR]
	$cbr_($k) set packetSize_ $cbr_size
	$cbr_($k) set rate_ $cbr_rate
	$cbr_($k) set interval_ $cbr_interval
	$cbr_($k) attach-agent $udp_($k)
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns_ at [expr $start_time+$i*$cross_start_gap] "$cbr_($k) start"
	incr k
}
#######################################################################RANDOM FLOW
set r $k
set rt $r
# set num_node [expr $num_row*$num_col]

set num_node $number_of_nodes

for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set udp_node [expr int($num_node*rand())] ;# src node
	set null_node $udp_node
	while {$null_node==$udp_node} {
		set null_node [expr int($num_node*rand())] ;# dest node
	}
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	$ns_ connect $udp_($rt) $null_($rt)
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval
	$cbr_($rt) attach-agent $udp_($rt)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	$ns_ at [expr $start_time] "$cbr_($rt) start"
	incr rt
}

#######################################################################SINK FLOW
set r $rt
set rt $r
# set num_node [expr $num_row*$num_col]

set num_node $number_of_nodes

for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	set udp_node [expr $i-1] ;#[expr int($num_node*rand())] ;# src node
	set null_node $sink_node
	#while {$null_node==$udp_node} {
	#	set null_node [expr int($num_node*rand())] ;# dest node
	#}
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
	puts -nonewline $topofile "SINK:  Src: $udp_node Dest: $null_node\n"
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	$ns_ connect $udp_($rt) $null_($rt)
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval
	$cbr_($rt) attach-agent $udp_($rt)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	$ns_ at [expr $start_time+$i*$sink_start_gap+rand()] "$cbr_($rt) start"
	incr rt
}

puts "flow creation complete"
##########################################################################END OF FLOW GENERATION

# Tell nodes when the simulation ends
#
# for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
#     $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";
# }

for {set i 0} {$i < $number_of_nodes } {incr i} {
    $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";
}


$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"
#$ns_ at [expr $start_time+$time_duration +20] "puts \"NS Exiting...\"; $ns_ halt"
$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"

$ns_ at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns_ at [expr $start_time+$time_duration] "puts \"end of simulation duration\""

proc finish {} {
	puts "finishing"
	global ns_ tracefd namtrace topofile nm
	#global ns_ topofile
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	close $topofile
        #exec nam $nm &
        exit 0
}

#set opt(mobility) "position.txt"
#source $opt(mobility)
#set opt(traff) "traffic.txt"
#source $opt(traff)

# for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
# 	$ns_ initial_node_pos $node_($i) 4
# }


for {set i 0} {$i < $number_of_nodes } { incr i} {
	$ns_ initial_node_pos $node_($i) 4
}



puts "Starting Simulation..."
$ns_ run 
#$ns_ nam-end-wireless [$ns_ now]

