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

> How many unique IP stations are transmitting in this trace file?

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

> What conversation is busiest, by bytes?

```bash
tshark -r lab03_ip_ttl.pcap -z conv,ip -q | sort -nrk 10
```

This isn't my favorite method of displaying the answer, but it gets the job
done. I don't currently know how to format Tshark's statistics pages the same
way you can with `-E` or the like on a normal packet trace.

> Set a filter for the conversations including address 104.19.162.127. How many
> packets match that filter?

```bash
tshark -r lab03_ip_ttl.pcap -Y 'ip.addr == 104.19.162.127' | wc -l
```

> What side of the conversation was this trace file captured on? Client or
> server? How can you tell?

The device sending data from port 80 is probably an HTTP server, and the device
sending from 50122/50123 is probably a client behind NAT. Plus, according to
`capinfos`, this file was captured on Mac OS X with the Wi-Fi interface. The
second packet is a DNS query response which says that the www.pluralsight.com
domain name matches the IPv4 address 104.19.162.127.

> How far away in router hops is the server?

The first SYN packet has a TTL of 64, with a returning TTL of 51, so there are
13 router hops between the client and server.

> Is there any prioritization in traffic coming from the server? What priority
> marking is used?

```bash
tshark -r lab03_ip_ttl.pcap -Y 'frame.number == 7' -O ip
```

In the return messages from the server on port 80, in the IPv4 header, the
Differentiated Services Field has Assured Forwarding 11 set. This only comes
into play when QoS or traffic policing comes into play, when the network is
stressed.

> What IP flags are set on traffic coming from the server?

```bash
tshark -r lab03_ip_ttl.pcap -Y 'frame.number == 23' -O ip
```

The "Don't fragment" bit is set.

> Is the client using incrementing IP Identification numbers? or is it
> randomizing them?

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

> How many ICMP packets are in this trace file

```bash
tshark -r lab05.pcap -Y 'icmp' | wc -l
```

There are two ICMP packets in this trace file.

> What is the Type of ICMP message?

```bash
tshark -r lab5.pcap -Y 'icmp' -T json | jq '.[]._source.layers.icmp."icmp.type"'
```

The type is "3", which corresponds to "Destination unreachable" according to
Wikipedia.

> What is the code value?

```bash
tshark -r lab5.pcap -Y 'icmp' -T json | jq '.[]._source.layers.icmp."icmp.code"'
```

The code value is also "3", which means "Destination port unreachable".

> What is the source IP of the sending station of these packets?

```bash
tshark -r lab5.pcap -Y 'icmp' -T fields -e ip.src
```

The source IP is 192.168.1.4.

> Why is this ICMP message being sent? Is something broken? If so, what?

The ICMP message sent from 216.230.139.8 actually contains the packet that
triggered the error, in this case saying that the endpoint wasn't able to talk
on that port. Looking back at the previous traffic, it appears that two DNS
conversations were started, and the host just chose the other endpoint whose
name was resolved first.

> Will the user experience any application problems from this behavior?

According to Chris Greer's video explanation in Pluralsight, sometimes web
browsers will query multiple DNS servers just in case one of the servers fails,
or the referred address fails. In this case, the DNS server that sent the ICMP
message caused the failure. The user would be able to access the website just
fine.

## Lab 6: IPv6 Headers

The purpose of this lab is to show some of the distinguishing features of IPv6 and ICMPv6 at a packet level. There's not a ton of important Tshark-related stuff that you can't just figure out with our previous packet inspection tricks.

## Lab 7: Analyzing UDP

> What Applications are using UDP in this trace file?

```bash
tshark -r lab07.pcap -O udp | less
```

Since each packet has a UDP field in the results, and searching for TCP reveals nothing, then all the protocols in this capture file use UDP. That includes DNS, and SNMP.

> What UDP port number does the DNS server use?

DNS uses UDP port 53. As far as I know no TCP protocols use that port number, even if they are technically distinct from a protocol perspective.

> Why do we see the ICMP message in packet 5?

The router or default gateway has blocked SNMP traffic, so it replies with ICMP type 3 code 3, meaning the port is blocked.

> What kind of service is SNMP? What does it do?

SNMP stands for Simple Network Management Protocol. It allows hosts and servers to manage configuration details of other hosts, query for information on configurations, and send passwords in plaintext over the wire. The latest version, SNMPv3, uses encryption, but could still be vulnerable to brute force and dictionary attacks for community strings, which is what SNMP calls a master password.

> Extra credit - What community string is the SNMP query using?

```bash
tshark -r lab07.pcap -O snmp | grep community
```

The SNMPv2 protocol used in this packet trace sends the community string unencrypted. The string is "ARIFA" which could be a hint that the router is using a default security configuration.

## Lab 8: Analyzing DHCP

asdf
