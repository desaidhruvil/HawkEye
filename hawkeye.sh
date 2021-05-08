#!/bin/bash
#
#
#
#
#
# Colors
red='\033[1;31m'
yellow='\033[1;33m'
blue='\033[1;34m'
purple='\033[1;35m'
cyan='\033[1;36m'
green='\033[1;32m'
reset='\033[0m'

# Configuration
resolvers="dns-resolvers.txt"
amasswordlist="path of wordlist"
dirsearchwordlist="wordlist for hidden dir"
config="config.ini"

# Path Variables
date=$(date +"%Y-%m-%d")
path="~/Recon/${target}-${date}"
spath="Subdomain/tmp/"
currentdir=$(pwd)





resolve() {
	echo -e "$blue Resolving live subdomains. $reset"
	shuffledns -d $target -list $path/${spath}tmp-domains.txt -r $resolvers -o $path/Subdomain/domains.txt
	echo -e "${green}Resolved subdomains saved in $reset\'${orange}domains.txt $reset\'."
	echo -e "${green}path$reset :\'$orange$path/Subdomain/domains.txt $reset\'."
	livehosts
}
subdomain() {
	echo "Finding subdomains for $"
	subfinder -d $target -all -o $path/${spath}subfinder.list
	assetfinder -subs-only $target | tee $path/${spath}assetfinder.list
	sublist3r -d $target -o $path/${spath}sublist3r.list
	curl -s https://api.certspotter.com/v1/issuances\?domain=$target\&expand=dns_names\&expand=issuer\&expand=cert | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $target >> $path/${spath}certspotter.list
	amass enum -active -d $target -dir $path/$spath -o $path/${spath}amass.list -rf $resolvers -config $config

	cd $path/${spath}
	echo "">>*.list;cat *.list>>tmp.txt
	cat tmp | sort -u > tmp-domains.txt
	echo -e "${green}All subdomains saved in $reset\'${orange}tmp-domains.txt $reset\'."
	echo -e "${green}path$reset :\'$orange$path/${spath}tmp-domains.txt $reset\'."
	cd $currentdir
	resolve
}

livehosts() {
	echo -e "$blue Checking for web hosting domains.$reset"
	cat $path/Subdomain/domains.txt | httprobe -c 50 -t 3000 >> $path/Subdomain/web-domains.txt
	echo -e "${green}Web hosted subdomains saved in $reset\'${orange}web-domains.txt $reset\'."
	echo -e "${green}path$reset :\'$orange$path/Subdomain/web-domains.txt $reset\'."
}

check() {
	if [[ ! -d "Recon" ]]; then
		mkdir Recon
	fi

	if [[ ! -d "Recon/${target}-${date}" ]]; then
		mkdir Recon/${target}-${date}
	fi
	if [[ ! -d "Recon/${target}-${date}/Subdomain/tmp" ]]; then
		mkdir -p Recon/${target}-${date}/Subdomain/tmp
	fi
}

main() {
	check
	subdomain
}