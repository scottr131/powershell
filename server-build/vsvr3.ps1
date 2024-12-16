# Install features for remote administration of ADDS, DHCP, DNS, and group policy
Install-WindowsFeature -Name GPMC, RSAT-AD-Tool, RSAT-DHCP, RSAT-DNS-Server, Telnet-Client

# Configure the first (probably only) network interface - 172.16.31.33/24
New-NetIPAddress -InterfaceAlias (Get-NetAdapter)[0].InterfaceAlias -IPAddress 172.16.3.33 -DefaultGateway 172.16.3.1 -PrefixLength 24

# Set the DNS servers to this and the other DC
Set-DnsClientServerAddress -InterfaceAlias (Get-NetAdapter)[0].InterfaceAlias -ServerAddresses "172.16.3.32", "172.16.3.31"

# Set the comptuer's name
Rename-Computer -NewName VSVR3