# Translating Wireshark skills to Tshark

Chris Greer's excellent Pluralsight course, "Analyzing Network Protocols with
Wireshark", introduces network traffic analysis with the GUI-based tooling
provided by Wireshark. The strongest aspect of the course is the exercises,
presented as capture file comments in several attached .pcap files. Many of
these exercises highlight the ease of using Wireshark's numerous filters and
visual display tricks to solve problems, but how necessary are these GUI
niceties? Wireshark graciously provides a CLI alternative, Tshark, which
attempts to bring the power of Wireshark to the Terminal.

In this post, I will show alternative solutions to Chris Greer's exercises in
Tshark, so you can extend your bag of tricks and potentially move faster with
your favorite traffic analysis tool! Perhaps other networking tools will make
an appearance...

## Methodology and Resources

After downloading the Pluralsight course exercises at the [Exercise files
tab](https://app.pluralsight.com/library/courses/wireshark-analyzing-network-protocols/exercise-files),
my typical workflow when completing the labs looked something like this:

1. Open the capture file in Wireshark with `wireshark 'Lab 2_ARP
   Protocol.pcapng' &` or similar.
2. View the lab comments with control+alt+shift+c or *Statistics->Capture File
   Properties* (alt+s+enter in the menu).
3. In a separate terminal, rename the file for convenience to `lab2.pcap` or
   similar. Note that Tshark doesn't tab-complete `.pcapng` files in bash, only
   `.pcap` files. I am running Tshark version 4.0.8 in nix-shell, but this may
   not be the case in other versions. We will come back to versioning later.
4. `capinfos lab2.pcap` to read the lab comments and any other capture file
   metadata. Note you can read the same data with `head lab2.pcap` if your
   package manager doesn't include `capinfos` with Wireshark, and you don't
   mind some occasionally poor formatting. I find it neat that the metadata is
   almost directly prepended to the actual file contents.
5. Open [tshark.dev](https://tshark.dev/) in Firefox and search for the
   relevant documentation if it exists.
6. For technical minutiae of Tshark like command line arguments and formatting
   tricks try, `man tshark` and search for relevant keywords and flags.
7. If the question cannot be trivially solved with the current tools at hand,
   look it up in Firefox. The solution tends to come up in [Wireshark's
   documentation](https://www.wireshark.org/docs/wsug_html_chunked/)
   also.

I found Wireshark's man page to be difficult to compare to the GUI, so I went
to [Chris Greer's Youtube channel](https://www.youtube.com/@ChrisGreer) for
visual demonstrations of the tool at work. Now, onto the solutions.

## Lab 1: Configuring Profiles

There aren't any capture comments available in this file, but in the demos for
Module 2, Chris Greer covers the basics of configuring Wireshark profiles to
simplify configuration. Here's a summary:

> control+shift+a brings up the Configuration Profiles menu. Copy the Default
> profile to "Pluralsight" and all your changes will be saved to it.

I found these under `~/.config/wireshark/profiles/` and
`/usr/share/wireshark/profiles/`, with an additional directory inside for each
configuration profile. The "Default" configuration is stored in
`~/.config/wireshark/`, mixed with other configuration files for some reason.
Wireshark's [official
documentation](https://www.wireshark.org/docs/wsug_html_chunked/ChAppFilesConfigurationSection.html)
has more on this. The names and contents of the files are a bit difficult to
decipher at first glance, so I will revisit them later.

You can copy a sample profile folder and change the name/files independently,
and see the results in Wireshark as well.

> *Help->About Wireshark->Folders* will show the locations where Wireshark stores
> configuration data, including system- and user-specific profiles, plugins,
> Lua scripts, and so on.

`tshark -G folders` brings up a report of the folders read by Wireshark/Tshark
with the same information as above. For some reason this was sorted under
["Wireshark
Arcana"](https://tshark.dev/packetcraft/arcana/profiles/#finding-the-folders)
on Tshark.dev.

> You can add columns in the *Edit->Preferences->Appearance->Columns* menu by
> clicking the +, naming the column, and choosing a pre-defined type or by
> setting it to custom and choosing a custom field matching an attribute in
> Wireshark's display filters.

Tshark chooses what columns to display based on its command line arguments and
selected profile. Here's a simple invocation with the 'Pluralsight' profile
applied:

```bash
tshark -r lab01.pcap -C Pluralsight
```

Notice that the input file is specified with the `-r` flag, like how Tcpdump
reads capture file arguments. Display filters can be used to refine the output
fields like so:

```bash
tshark -r lab01.pcap -T fields -e frame.time -e ip.src -e ip.dst -e _ws.col.Info
```

Here, `-T fields` specifies the familiar line-wise format you see in Wireshark.
The available output formats are ek, json, fields, and pdml (more on those
later). Next, `-e frame.time` and so on specify what fields to add as columns
to the output. `-e _ws.col` is a special column of wireshark info that
summarizes the packet's metadata. In this case we are interested in the 'Info'
field. If a supplied configuration profile has additional fields, they will not
be displayed.

> Add filter buttons by entering a display filter, then clicking the '+' on the
> right of the filter bar and giving it a name. Clicking that button will apply
> the filter immediately.

To my knowledge, Tshark doesn't have any special tools for saving capture or
display filters other than through profile configurations. You can find
Wireshark buttons in the "dfilter_buttons" file. You can, however, scrub
through your command history with control+r or write a bash script aliases in
your `~/.bashrc` like so:

```bash
alias ts_dns_failed=tshark -Y 'dns.flags.rcode != 0' -C Default
```

> Change your coloring rules by following *View->Coloring Rules...* and add a
> new coloring rule with '+', choose a display filter, choose a
> foreground/background color, then click and drag it to the top of the
> coloring rules list.

Coloring rules are saved in the 'colorfilters' file in a configuration profile, and look something like this:

```txt
# This file was created by Wireshark. Edit with care.
@Bad TCP@tcp.analysis.flags && !tcp.analysis.window_update && !tcp.analysis.keep_alive && !tcp.analysis.keep_alive_ack@[4626,10023,11822][63479,34695,34695]
@TCP SYN@tcp.flags.syn == 1@[63993,61680,27499][0,0,0]
@HSRP State Change@hsrp.state != 8 && hsrp.state != 16@[4626,10023,11822][65535,64764,40092]
@Spanning Tree Topology  Change@stp.type == 0x80@[4626,10023,11822][65535,64764,40092]
@OSPF State Change@ospf.msg != 1@[4626,10023,11822][65535,64764,40092]
@ICMP errors@icmp.type in { 3..5, 11 } || icmpv6.type in { 1..4 }@[4626,10023,11822][47031,63479,29812]
@ARP@arp@[64250,61680,55255][4626,10023,11822]
@ICMP@icmp || icmpv6@[64764,57568,65535][4626,10023,11822]
@TCP RST@tcp.flags.reset eq 1@[42148,0,0][65535,64764,40092]
@SCTP ABORT@sctp.chunk_type eq ABORT@[42148,0,0][65535,64764,40092]
@TTL low or unexpected@(ip.dst != 224.0.0.0/4 && ip.ttl < 5 && !pim && !ospf) || (ip.dst == 224.0.0.0/24 && ip.dst != 224.0.0.251 && ip.ttl != 1 && !(vrrp || carp))@[42148,0,0][60652,61680,60395]
@Checksum Errors@eth.fcs.status=="Bad" || ip.checksum.status=="Bad" || tcp.checksum.status=="Bad" || udp.checksum.status=="Bad" || sctp.checksum.status=="Bad" || mstp.checksum.status=="Bad" || cdp.checksum.status=="Bad" || edp.checksum.status=="Bad" || wlan.fcs.status=="Bad" || stt.checksum.status=="Bad"@[4626,10023,11822][63479,34695,34695]
@SMB@smb || nbss || nbns || netbios@[65278,65535,53456][4626,10023,11822]
@HTTP@http || tcp.port == 80 || http2@[58596,65535,51143][4626,10023,11822]
@DCERPC@dcerpc@[51143,38807,65535][4626,10023,11822]
@Routing@hsrp || eigrp || ospf || bgp || cdp || vrrp || carp || gvrp || igmp || ismp@[65535,62451,54998][4626,10023,11822]
@TCP SYN/FIN@tcp.flags & 0x02 || tcp.flags.fin == 1@[41120,41120,41120][4626,10023,11822]
@TCP@tcp@[59367,59110,65535][4626,10023,11822]
@UDP@udp@[56026,61166,65535][4626,10023,11822]
@Broadcast@eth[0] & 1@[65535,65535,65535][47802,48573,46774]
@System Event@systemd_journal || sysdig@[59110,59110,59110][11565,28527,39578]
```

The format appears to be a CSV file delimited by ampersands, with foreground or
background colors stored in two decimal number arrays in the third column. Many
of these rules are common error signatures, but I was surprised it also
references Sysdig's Systemd journal monitoring on the last line. You can enable
colors in Tshark with the `--color` flag, but note that the Default color
options may clash with a dark terminal background, so try creating a simpler
profile with only one or two coloring rules to pick out the traffic you care
about. Or better yet, why not just apply another display filter? Maybe you
could add special colors that jump out only for very suspicious packet
signatures, and just leave it on all the time with a bash alias? Having too
many broad coloring rules at the start can hide more specific rules below, so
make sure the order makes sense for your priorities. This is another place
where Wireshark makes a lot more sense to use than Tshark for exploratory
analysis.

## Lab 2: ARP traffic

> Inspect the ARP packet contents by clicking on frame 2, then read the Packet
> Details in the bottom left window pane.

To read a specific packet's contents, try filtering for a specific packet
number or protocol, and then use the `-V` flag and pipe to a pager for easier
reading.

```bash
tshark -r lab2.pcap -Y 'arp' -V | less
```

You can filter this traffic down further with the `-O` flag, followed by the
protocol(s) you would like to read, separated by commas:

```bash
tshark -r lab2.pcap -Y 'frame.number == 7' -O arp
```

To identify ARP replies from hosts, we can check the ARP arpcode, or check if
it is a unicast message.

```bash
tshark -r lab2.pcap -Y 'arp.opcode == 2'
```

## Lab 3: IPv4, IPv6, and ICMP

From here, the lab exercises are more about digging through Wireshark's deep
library of statistics and creating a recipe book for effective capture file
spelunking. The good news is, Tshark's status as a terminal application grants
us access to a host of Unix-y scripting tools that can aid us in discovering
things about our capture files, without having to learn the ins and outs of
Wireshark configuration. The `-z` flag provides plenty of information on
conversations and general protocol information, but requires some extra
scripting to get more precise numerical results, as we shall see.

1. How many unique IP stations are transmitting in this trace file?

   I initially figured `ip.src` field would contain everything I needed, but
   Wireshark's *Statistics->Endpoints->IPv4* menu disagrees with me. Here's my
   first attempt:

   ```bash
   tshark -r lab03_ip_ttl.pcap -T fields -e ip.dst | sort | uniq | wc -l # answer: 34?
   ```

   Wireshark says 34. We can look at Tshark's statistics page for the Ipv4
   conversations and filter the results for another way of answering:

   ```bash
   tshark -r lab03_ip_ttl.pcap -z conv,ip -q | grep '^[0-9]' | wc -l # answer: 33?
   ```

   Note that some endpoints were sent to with no response, so no data was received
   after opening the conversation. Filtering for `ip.src` Gives 30 results, so 4
   endpoints must not have sent any data (you can confirm this in the conversation
   summary with `-z conv,ip`).

2. What conversation is busiest, by bytes?

   ```bash
   tshark -r lab03_ip_ttl.pcap -z conv,ip -q | sort -nrk 10
   ```

   This isn't my favorite method of displaying the answer, but it gets the job
   done. I don't currently know how to format Tshark's statistics pages the same
   way you can with `-E` or the like on a normal packet trace.

3. Set a filter for the conversations including address 104.19.162.127. How many packets match that filter?

   ```bash
   tshark -r lab03_ip_ttl.pcap -Y 'ip.addr == 104.19.162.127' | wc -l
   ```

4. What side of the conversation was this trace file captured on? Client or server? How can you tell?

   The device sending data from port 80 is probably an HTTP server, and the device
   sending from 50122/50123 is probably a client behind NAT. Plus, according to
   `capinfos`, this file was captured on Mac OS X with the Wi-Fi interface. The
   second packet is a DNS query response which says that the [www.pluralsight.com](www.pluralsight.com)
   domain name matches the IPv4 address 104.19.162.127.

5. How far away in router hops is the server?

   The first SYN packet has a TTL of 64, with a returning TTL of 51, so there are
   13 router hops between the client and server.

6. Is there any prioritization in traffic coming from the server? What priority marking is used?

   ```bash
   tshark -r lab03_ip_ttl.pcap -Y 'frame.number == 7' -O ip
   ```

   In the return messages from the server on port 80, in the IPv4 header, the
   Differentiated Services Field has Assured Forwarding 11 set. This only comes
   into play when QoS or traffic policing comes into play, when the network is
   stressed.

7. What IP flags are set on traffic coming from the server?

   ```bash
   tshark -r lab03_ip_ttl.pcap -Y 'frame.number == 23' -O ip
   ```

   The "Don't fragment" bit is set.

8. Is the client using incrementing IP Identification numbers? or is it randomizing them?

   The client is randomizing them. To figure this out, I ran a display filter for
   packets coming from 192.168.10.108 and chose json as my output format, then
   queried the results with `jq` to get the specific field in ASCII.

   ```bash
   tshark -r lab3.pcap -Y 'ip.src == 192.168.10.108' -T json | jq '.[]._source.layers.ip."ip.id"'
   ```

## Lab 4: IP Fragmentation

This lab demonstrates some facts about fragmenting packets, specified with the
Differentiated Services Field bits, which can be read with the `jq` strategy.
It's neat that the fragment offset is byte-addressed, since so many networking
protocols deal with individual bits within a header, but actual data transfer
typically deals with much larger payloads.

## Lab 5: ICMP Messages

1. How many ICMP packets are in this trace file

   ```bash
   tshark -r lab05.pcap -Y 'icmp' | wc -l
   ```

   There are two ICMP packets in this trace file.

2. What is the Type of ICMP message?

   ```bash
   tshark -r lab5.pcap -Y 'icmp' -T json | jq '.[]._source.layers.icmp."icmp.type"'
   ```

   The type is "3", which corresponds to "Destination unreachable" according to
   Wikipedia.

3. What is the code value?

   ```bash
   tshark -r lab5.pcap -Y 'icmp' -T json | jq '.[]._source.layers.icmp."icmp.code"'
   ```

   The code value is also "3", which means "Destination port unreachable".

4. What is the source IP of the sending station of these packets?

   ```bash
   tshark -r lab5.pcap -Y 'icmp' -T fields -e ip.src
   ```

   The source IP is 192.168.1.4.

5. Why is this ICMP message being sent? Is something broken? If so, what?

   The ICMP message sent from 216.230.139.8 actually contains the packet that
   triggered the error, in this case saying that the endpoint wasn't able to talk
   on that port. Looking back at the previous traffic, it appears that two DNS
   conversations were started, and the host just chose the other endpoint whose
   name was resolved first.

6. Will the user experience any application problems from this behavior?

   According to Chris Greer's video explanation in Pluralsight, sometimes web
   browsers will query multiple DNS servers just in case one of the servers fails,
   or the referred address fails. In this case, the DNS server that sent the ICMP
   message caused the failure. The user would be able to access the website just
   fine.

## Lab 6: IPv6 Headers

The purpose of this lab is to show some of the distinguishing features of IPv6 and ICMPv6 at a packet level. There's not a ton of important Tshark-related stuff that you can't just figure out with our previous packet inspection tricks.

## Lab 7: Analyzing UDP

1. What Applications are using UDP in this trace file?

   ```bash
   tshark -r lab07.pcap -O udp | less
   ```

   Since each packet has a UDP field in the results, and searching for TCP reveals nothing, then all the protocols in this capture file use UDP. That includes DNS, and SNMP.

2. What UDP port number does the DNS server use?

   DNS uses UDP port 53. As far as I know no TCP protocols use that port number, even if they are technically distinct from a protocol perspective.

3. Why do we see the ICMP message in packet 5?

   The router or default gateway has blocked SNMP traffic, so it replies with ICMP type 3 code 3, meaning the port is blocked.

4. What kind of service is SNMP? What does it do?

   SNMP stands for Simple Network Management Protocol. It allows hosts and servers to manage configuration details of other hosts, query for information on configurations, and send passwords in plaintext over the wire. The latest version, SNMPv3, uses encryption, but could still be vulnerable to brute force and dictionary attacks for community strings, which is what SNMP calls a master password.

5. Extra credit - What community string is the SNMP query using?

   ```bash
   tshark -r lab07.pcap -O snmp | grep community
   ```

   The SNMPv2 protocol used in this packet trace sends the community string unencrypted. The string is "ARIFA" which could be a hint that the router is using a default security configuration.

## Lab 8: Analyzing DHCP

1. In the DHCP Discover, what options is the client requesting?

   The host on the NIC named NetAlly_a1:17:9f is broadcasting to request the default gateway, DNS endpoint, and an IP address from the router. Note according to Chris Greer: This endpoint is assuming whatever routers are in this broadcast domain can either act as a DHCP server or do DHCP routing if it is not in this broadcast domain.

2. Is this a broadcast packet?

   Since this is going to MAC address ff:ff:ff:ff:ff:ff, yes this is a broadcast packet for the discover request. This is being sent from IPv4 "0.0.0.0" to 255.255.255.255, so it is attempting to broadcast there as well, with an unknown broadcast or address in its subnet.

3. What is the function of the ARPs in packets 2-4?

   Frame 2: The Belkin router (presumably) is looking for the physical address of any device with the IP of 192.128.10.120. If such a device exists, it would respond, but nothing happened, so the router knows that address is free to assign to the device that sent the DHCP Discover request.

4. What is the server host name of the DHCP server?

   The server host name, from the frame 5 DHCP Offer response, is "ecosystem.home.cisco.com".

5. The server goes above and beyond. What options are offered to the client that did not appear in the discover packet?

   The server offers Options 53 (Offer), 54 (DHCP Server Identifier), 51 (IP Address Lease Time), 58 (Renewal Time), 59 (Rebinding Time), 1 (Subnet Mast), 28 (Broadcast Address), 6 (Domain Name Server), 3 (Router), and 255 (End).

6. In the request packet, why is there no relay agent?

   Since the router is typically the one communicating to a relay agent, and the request packet is coming from the host, there is no need to use one.

7. In the request packet, how does the client identify which server it wants an address from?

   Multiple DHCP servers could be present in the network, so the Server Identifier option in the Request packet specifies a DHCP server that the host would like to be tracked from.

8. In the DHCP ACK - is this packet a broadcast?

   The DHCP server's ACK packet is directed only to the host it is acknowledging as having a newly assigned address.

9. What is the lease time of the accepted address?

   In the ACK packet's Option 51, IP Address Lease Time, we can see that it has 86400 seconds, or one day of lease time.

10. After how long can the client renew the lease?

    The Renewal Time Value (option 58) is 12 hours.

11. What is the function of packets 8 and 9?

    In frame 8, the host sends an ARP probe asking if any other hosts have the address it was just given by the DHCP server. Half a second later, in the following packet, it announces its newly allocated address.

## Lab 9: DHCP Decline

This lab has no questions, but demonstrates some debugging tips for DHCP errors. The primary point of interest is in frame 20, which contains a DHCP decline message, when a host has realized that the address assigned from the DHCP server was already in use, from frame 18. The host then goes to ask for a new address and has to wait for the DHCP server, which takes a couple tries before sending two DHCP Offer packets. Tshark's `_ws.col.Info` column helpfully keeps track of the Transaction ID, so we can see they are part of the same "stream" of conversation in the DHCP DORA process. I appreciate that you can search for "gratuitous" to find ARP requests for a device's own address in the capture file.

## Lab 10: Analyzing DNS

This lab also has no questions. Chris Greer does mention one important aspect of DNS in the Pluralsight video, which is how to measure DNS response times. This can help explain latency issues when connecting to websites from unfamilar networks, or for debugging DNS cache issues. In the video, he takes an existing packet capture, searches "dns", and adds the "Time" field of the DNS protocol as a column. The exercise is to do this with your own network traffic and measure the DNS latency. Here is how you would capture DNS traffic with Tcpdump:

```bash
tcpdump -i any port 53 -w dns_traffic.pcap
```

Note that you may get some traffic on the loopback interface with `-i any`, so specifying your primary NIC should clear up the results greatly. Once you have captured the traffic, you can filter it with something like this:

```bash
tshark -r dns_traffic.pcap -Y 'dns.flags.response == 1' -T fields -e dns.time -e _ws.col.Info | sort -n -r -k 1
```

This query will show the time and general packet info, sorted by the longest DNS response times. Whether this is easier or more convenient than opening it in Wireshark and clicking the column header to sort forward or reverse, is your call.

## Lab 11: Analyzing FTP

1. What port does the client connect to on the server to start the command connection?

   ```bash
   tshark -r lab11.pcap -Y 'ftp' -T fields -e tcp.port
   ```

   This shows that port 21 is used for FTP communication.

2. What initial Login does it use?

   ```bash
   tshark -r lab11.pcap -Y ftp -O ftp | less
   ```

   Searching for "Login" shows the server response in Frame 10, so we have to work back through the conversation to Frame 8 to see the "USER" field written as "anonymous".

3. What password does it use?

   the PASS field is given in Frame 9: "<chrome@example.com>". This may be a default value from the user's web browser to attempt to access publicly-available materials. Note to self: see what user/password is used for GNU's FTP server for downloading GNU source code.

4. Is the initial login successful? What server response code does the server use?

   Frame 10 suggests the login or password is incorrect, and gives a response code of 530.

5. Does this connection stay open for long?

   One major upside Wireshark has over Tshark is its ease of conversation tracking with the right-click menu. In Tshark, you first have to identify the TCP stream index, and then do the following:

   ```bash
   tshark -r lab11.pcap -q -z follow,tcp,ascii,0 # 'tcp.stream == 0' as a display filter
   ```

   You can also get a similar effect with a display filter: `tcp.stream == 0`, or try `ftp` and look through the packets manually with `-O ftp`. Looking at the Frame delta information, this automated conversation amusingly made only one attempt at connecting and then sent the "QUIT" request.

6. Look at the next connection to the same port. What packet does this connection start on?

   `tcp.stream == 1` Reveals the next connection on Frame 18, right after the last connection closed. It's unfortunate that the client couldn't stay on the same TCP connection to reduce traffic overhead, but at least it is easier to distinguish the FTP conversations by ephemeral port or TCP stream.

7. What username and password does the client use to connect?

   The "chris" user is tried, with an empty password after typing PASS.

8. Is this connection successful? Which response code does the server use?

   The server response code is 230, "Logged on".

9. What directory does the client have access to?

   The client starts in the root directory, written as "/", of the fileshare.

10. What file is requested from the server?

    the file "/Pluralsight Logo.PNG" is requested with RETR for "retrieve", but only after attempting to change directory with CWD.

11. What is the size of this file in bytes?

    In Frame 38, the "SIZE" command is sent, and the server responds with "5817", which is the number of bytes in the file, converted to

12. Does the client want to transfer this file in passive or active mode?

    In Frame 44 we can see the PASV command is sent from the client, which means passive mode.

13. What port does the server tell the client to use for file transfer?   Transfering the File:

    In Frame 45, the server's response gives response code 227 to enter passive mode, and then the octets (192, 168, 10, 196, 227, 188). The first four are the IPv4 address of the server to connect to for the data, and the last two give the port number: Multiply 227 by 256, then add 188 to get port 58300. It's convoluted bits of trivia like this that remind me why I am not a network engineer.

14. What port does the client connect to?

    The client connects to port 58300 in a new TCP session.

15. How many packets does the server need to actually transfer the file?

    ```bash
    tshark -r lab11.pcap -Y 'ftp-data' | wc -l
    ```

    There are 4 total packets transferred to the client. I was surprised at the existence of the "ftp-data" filter, which I only would have discovered with Wireshark.

16. Without further direction, can you work out how to extract this file from Wireshark?  What kind of file is transfered? Can you reassemble it?

    Wireshark wins again in terms of simplicity. For this problem, I started by identifying the TCP stream number and writing this query:

    ```bash
    tshark -r lab11.pcap -q -z follow,tcp,raw,2 > ftp.png
    ```

    This only gives us the UTF-8 representation of the stream's hex contents, with one line per packet of information. A tool like `ngrep` would be much better suited for this purpose, but I'm going to do my best to reconstruct the file with Tshark anyway.

    We can clean up the file with a quick bash script to remove unnecessary lines and characters that aren't hex digits:

    ```bash
    tshark -r lab11_analyzing_ftp.pcap -z follow,tcp,raw,2 -q | awk -e '/\t/ { printf "%s", $1 }' | xxd -r -p - > ftp.png
    ```
