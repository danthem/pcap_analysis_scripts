# pcap_analysis_scripts
A collection of PCAP analysis scripts, some more basic than others.

## find-ip:
**Syntax**: `find-ip.sh <ip> [pcap file(s)]`  
**Example**: `find-ip.sh 10.43.58.201` | `find-ip.sh 10.43.58.201 *vlan*.pcap`  
**Description**: If you have a lot of PCAP files and want to know if IP x.x.x.x appears in the PCAP. Will tell you about every IP level conversation that the provided IP is in (along with number of frames and data sent).

You can run it on a single pcap file, multiple (either provide many or use wildcard) or, if you don't provide any pcap file at all, it will run on every pcap file in pwd that is >24bytes (=not empty)
***
