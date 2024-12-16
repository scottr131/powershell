# Install features for AD DS, DHCP, and DNS.  Run these on both DCs
Install-WindowsFeature -Name AD-Domain-Services, DHCP, DNS

# Configure the first (probably only) network interface - 172.16.31.32/24
New-NetIPAddress -InterfaceAlias (Get-NetAdapter)[0].InterfaceAlias -IPAddress 172.16.3.32 -DefaultGateway 172.16.3.1 -PrefixLength 24

# Set the DNS servers to this and the other DC
Set-DnsClientServerAddress -InterfaceAlias (Get-NetAdapter)[0].InterfaceAlias -ServerAddresses "127.0.0.1", "172.16.3.31"

# Set the comptuer's name
Rename-Computer -NewName VDC2