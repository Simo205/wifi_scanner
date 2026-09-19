#!/bin/bash

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}     WiFi Network & Device Inspector      ${NC}"
echo -e "${CYAN}==========================================${NC}"

# Step 1: Scan l-Network kaml باش t-l9a ga3 l-devices
read -p "Enter Network Subnet (e.g. 192.168.1.0/24): " SUBNET

echo -e "\n${YELLOW}[*] Scanning active devices on $SUBNET...${NC}"
sudo arp-scan --localnet | grep -E "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" > devices.txt

echo -e "${GREEN}[+] Active Devices Found:${NC}"
cat devices.txt | awk '{print "IP: " $1 " | MAC: " $2 " | Vendor: " $3 " " $4}'

# Step 2: Inspection dyal Target IP wa7d
echo -e "\n------------------------------------------"
read -p "Enter Target IP to inspect: " TARGET_IP

if [ -z "$TARGET_IP" ]; then
    echo -e "${RED}[!] No IP entered. Exiting.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}[*] Inspecting Target: $TARGET_IP...${NC}"

# Detailed Nmap Scan
# Detailed Nmap Scan (Strong Scan with Ping Bypass)
nmap -Pn -sS -O -sV --script default $TARGET_IP > target_info.txt

# Extracting Info
MAC_ADDR=$(grep "MAC Address:" target_info.txt | awk '{print $3}')
VENDOR=$(grep "MAC Address:" target_info.txt | cut -d '(' -f2 | tr -d ')')
OS_INFO=$(grep "OS details:" target_info.txt | cut -d ':' -f2)
HOSTNAME=$(nmblookup -A $TARGET_IP 2>/dev/null | grep "<00>" | head -n 1 | awk '{print $1}')

echo -e "\n${GREEN}=== TARGET DETAILS ===${NC}"
echo -e "IP Address : ${CYAN}$TARGET_IP${NC}"
echo -e "MAC Address: ${CYAN}${MAC_ADDR:-N/A}${NC}"
echo -e "Vendor     : ${CYAN}${VENDOR:-Unknown}${NC}"
echo -e "Hostname   : ${CYAN}${HOSTNAME:-Unknown}${NC}"
echo -e "OS Info    : ${CYAN}${OS_INFO:-Undetected}${NC}"

echo -e "\n${YELLOW}[*] Open Ports & Services:${NC}"
grep -E "^[0-9]+/(tcp|udp)" target_info.txt
