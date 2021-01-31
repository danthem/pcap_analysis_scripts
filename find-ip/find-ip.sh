#!/bin/bash
#Author: Daniel Elf | https://github.com/danthem
#Syntax: find-ip <ip> [<pcapfile(s)>]
#You can add multiple pcap files at once or even use wildcard
#If no pcap file specified, run on all files matching pattern *.pcap* in pwd that are larger than 24bytes (empty pcap)
#Example syntax: $ find-ip 10.32.45.32 / $ find-ip 10.32.45.32 file_1.pcap / $ find-ip 10.32.45.32 *vlan0*.pcap

#Colors for nicer output:
blue=$(tput setaf 6)
white=$(tput setaf 7)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
normal=$(tput sgr0) # default color


#### HELP SECTION #####
help () {
    echo "Looks for an IP within one or many PCAP files and prints some stats for the IP"
    echo ""
    echo "Usage: find-ip [-h] <ip> [pcap file(s)]"
    echo "If no pcap file is specified, run on all \".pcap\" files in directory."
    echo "Multiple files or wildcards are allowed (example: *vlan0*.pcap)"
    echo ""
    echo "Options:"
    echo "-h    Show this help message and exit"
}

while getopts ":h" OPTION; do
case "$OPTION" in
h)
    help
    exit 0
    ;;
?)
    help 1>&2
    exit 1
    ;;
esac
done

#Syntax check
if [[ -z $1 ]]; then
	printf "${red}Error:${normal}: You must provide the IP that you're looking for.\n${yellow}Example:${normal} $ find-ip 10.10.10.10 vlan0.pcap\n"
	exit 1
else
	ip="$1"
	# We call "shift" to move all args one step left (effectively removing $1, but we've already assigned this to $ip so that's grand)
	shift
fi

# Define the function that actually looks for IP in the pcap file.. This function expects an argument to be passed (pcap file)
check_ip() {
	pcapfile="$1"
	printf "\n========= ${white}%s${normal} =========\n" "$pcapfile"
	output=$(tshark -r "$pcapfile" -qz conv,ip | awk -v ip="$ip" '{if ($0 ~ ip)print $1 " <-> " $3 " | " $8 " frames (" $9 ")"}')
	if [[ -n $output ]]; then 
		printf "%s\n" "$output" | grep --color $ip
	else 
		printf "${yellow} >> No matches for %s in file${normal}\n\n" "$ip"
	fi 	
} 


#Execution start:
printf "Looking for IP conversations involving ${blue}%s${normal} in requested PCAP file(s).\n" "$ip"
#Did user specify a PCAP file or are we just going to check all of them?
#Remember that we called 'shift' earlier, so $1 != the IP 
if [[ -n $1 ]]; then
	# We create a for-loop here to allow users to add multiple pcap files at once (but not all)
	# Example: $ find-ip 1.2.3.4 *vlan0*.pcap*
	for infile in "$@"; do 
		# Call check_ip function and pass 1 argument (pcap file(s))
		check_ip "$infile"
	done
else
	# If there's no $1 it means that no pcap file was specified. We use find to find all non-empty pcaps in current directory
	printf " >> No PCAP file(s) provided, searching through all non-empty pcaps in current directory...\n"
	find . -maxdepth 1 -type f -size +24c -iname "*.pcap*"  -printf "%f\n" | while read -r infile; do
		#We call the check_ip function with 1 argument at the time (each non-empty pcap file in dir)
		check_ip "$infile"
	done
fi



