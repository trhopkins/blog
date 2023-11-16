# Packet capture file analysis with Tshark

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

## Methodology and resources

After downloading the Pluralsight course exercises at the [Exercise files
tab](https://app.pluralsight.com/library/courses/wireshark-analyzing-network-protocols/exercise-files),
my typical workflow when completing the labs looked something like this:

1. Open the capture file comments with `capinfos lab.pcap`, or
   Control+Alt+Shift+C.
1. Check if I can solve the issue by just checking options in Wireshark, and
   try to find a solution in the Tshark manual if I got it immediately.
1. Search the internet for a solution for anything I don't know, or read the
   Tshark manual if it still seems doable locally.
1. browse some primary sources like [tshark.dev](https://tshark.dev/) and the
   [Wireshark online manual](https://www.wireshark.org/docs/wsug_html_chunked/)
   if the first few solutions don't obviously contain the solution.

I found that many [Stack
Overflow](https://superuser.com/questions/904786/tcpdump-rotate-capture-files-using-g-w-and-c)
questions would ask a somewhat related question to mine, then get an expansive
answer that taught me more about the tool than I expected to learn. Reading the
conversations of expert professionals offering their help is incredibly useful,
even years after the question was asked. Of course, Chris Greer's Pluralsight
videos immediately answered the question in Wireshark, so I could re-scan the
Tshark manual or website for related solutions. Sometimes I would be headed in
the right direction, but only slightly off, with the video to guide me to a
cleaner and more concise answer to my issue.

[Tshark.dev](https://tshark.dev/) was a surprisingly thorough resource for
building up my "recipe book" of tricks for solving common problems. Often my
specific issue would be alluded to in a page somewhere, alongside some ideas on
how to take the solution a step further with

## Lab 1: Configuring Profiles

There aren't any capture comments available in the exercise files for lab 1,
but in the demos for Module 2, Chris Greer covers the basics of configuring
Wireshark profiles to simplify configuration. Here's a summary:

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

Coloring rules are saved in the 'colorfilters' file in a configuration profile,
and look something like this:

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
reading. I like to open a separate tab in tmux for viewing tmux's extended
output in less so I can jump between both views without compromising on output.
If I only care about specific protocols I will go back with the `-O` flag with
the proper option(s) to follow it, separated with commas.

```bash
tshark -r lab2.pcap -Y 'frame.number == 2' -O arp,tcp | less
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
scripting to get more precise numerical results, as we shall see. I didn't find
all the answers in Tshark to differ drastically from Wireshark, so I will only
include the questions that led to unique answers.

1. How many unique IP stations are transmitting in this trace file?

   I initially figured `ip.src` field would contain everything I needed, but
   Wireshark's *Statistics->Endpoints->IPv4* menu disagrees with me. Here's my
   first attempt:

   ```bash
   tshark -r lab03_ip_ttl.pcap -T fields -e ip.dst | sort | uniq | wc -l # answer: 34?
   ```

   Wireshark says 34. We can look at Tshark's statistics page for the Ipv4
   conversations and filter the results for another way of answering with the
   `-z` flag:

   ```bash
   tshark -r lab03_ip_ttl.pcap -z conv,ip -q | grep '^[0-9]' | wc -l # answer: 33?
   ```

   Note that some endpoints were sent to with no response, so no data was received
   after opening the conversation. Filtering for `ip.src` Gives 30 results, so 4
   endpoints must not have sent any data (you can confirm this in the conversation
   summary with `-z conv,ip`).

1. What conversation is busiest, by bytes?

   ```bash
   tshark -r lab03_ip_ttl.pcap -z conv,ip -q | sort -nrk 10
   ```

   This isn't my favorite method of displaying the answer, but it gets the job
   done. I don't currently know how to format Tshark's statistics pages the same
   way you can with `-E` or the like on a normal packet trace. We should count
   ourselves lucky that Tshark includes the results in the summary and doesn't
   require us to sum the packet sizes ourselves with something like Perl or
   Awk (more on this later).

1. Is the client using incrementing IP Identification numbers? or is it
   randomizing them?

   The client is randomizing them. To figure this out, I ran a display filter
   for packets coming from 192.168.10.108 and chose json as my output format,
   then queried the results with `jq` to get the specific field in ASCII. This
   turns out to be a very flexible hammer that can hit all kinds of gnarly
   Tshark scripting nails, if you prefer to filter this stuff from the shell
   instead of dropping it into an external tool like Elasticsearch or Pandas.

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

This lab involves a lot of direct packet inspection and benefits greatly from
being able to switch quickly between the detailed view and table view of packet
details. A quick Wikipedia or ChatGPT query can do you a lot of good here.

## Lab 6: IPv6 Headers

The purpose of this lab is to show some of the distinguishing features of IPv6
and ICMPv6 at a packet level. There's not a ton of important Tshark-related
stuff that you can't just figure out with our previous packet inspection
tricks.

## Lab 7: Analyzing UDP

This lab was also relatively uneventful, but for the extra credit question, I
immediately knew it would be easier to solve this problem in Tshark:

> Extra credit - What community string is the SNMP query using?

```bash
tshark -r lab07.pcap -O snmp | grep -i community
```

The SNMPv2 protocol used in this packet trace sends the community string
unencrypted. The string is "ARIFA" which could be a hint that the router is
using a default security configuration. To do this same analysis in Wireshark,
I would need to identify which packet contains the community string in the
first place, which could mean searching for the right display filter query
(which, to be fair, is helped hugely by Wireshark's autocompletion window,
suggesting possible subfields for SNMP).

## Lab 8: Analyzing DHCP

Nothing super interesting for Tshark to do in this lab either.

## Lab 9: DHCP Decline

This lab has no questions, but demonstrates some debugging tips for DHCP
errors. The primary point of interest is in frame 20, which contains a DHCP
decline message, when a host has realized that the address assigned from the
DHCP server was already in use, from frame 18. The host then goes to ask for a
new address and has to wait for the DHCP server, which takes a couple tries
before sending two DHCP Offer packets. Tshark's `_ws.col.Info` column helpfully
keeps track of the Transaction ID, so we can see they are part of the same
"stream" of conversation in the DHCP DORA process. I appreciate that you can
search for "gratuitous" to find ARP requests for a device's own address in the
capture file.

## Lab 10: Analyzing DNS

This lab also has no questions. Chris Greer does mention one important aspect
of DNS in the Pluralsight video, which is how to measure DNS response times.
This can help explain latency issues when connecting to websites from unfamilar
networks, or for debugging DNS cache issues. In the video, he takes an existing
packet capture, searches "dns", and adds the "Time" field of the DNS protocol
as a column. The exercise is to do this with your own network traffic and
measure the DNS latency. Here is how you would capture DNS traffic with
Tshark:

```bash
tshark -i any -Y 'dns.flags.response == 1' -T fields -e dns.time -e _ws.col.Info
```

Once you've captured the traffic, you can specify an output file with the `-w`
flag, for "write", just like Tcpdump.

Note that you may get some traffic on the loopback interface with `-i any`, so
specifying your primary NIC should clear up the results greatly. Once you have
captured the traffic, you can filter it with something like this:

```bash
tshark -r dns_traffic.pcap -Y 'dns.flags.response == 1' -T fields -e dns.time -e _ws.col.Info | sort -nrk 1
```

This query will show the time and general packet info, sorted by the longest
DNS response times. Whether this is easier or more convenient than opening it
in Wireshark and clicking the column header to sort forward or reverse, is your
call.

For more real-time analysis, you can pipe raw packet captures directly to Tshark like so:

```bash
tshark -i any -Y 'dns.flags.response == 1' -T fields -e dns.time -e _ws.col.Info
```

## Lab 11: Analyzing FTP

To complete this lab on FTP traffic, you must reconstruct a TCP stream
containing a file. While this is simple in Wireshark, Tshark requires some more
finagling and fiddling with bits. Curiously, you can get an annotated
conversation view with `-z follow,tcp`, but you must reconstruct the actual
packet contents yourself after. This includes removing the extraneous Tshark
output and converting the ASCII hex output to a binary blob. In situations like
this, Ngrep seems like the ideal solution, but for the consistency I will solve
it with Tshark. First let's look at the full solution, then break it down:

```bash
tshark -r lab11_analyzing_ftp.pcap -z follow,tcp,raw,2 -q | awk -e '/\t/ { printf "%s", $1 }' | xxd -r -p - > ftp.png
```

After identifying that TCP conversation #2 was the correct one to follow by
grepping for "RETR", the FTP command for *retrieving* data, I followed the
conversation with `-z follow,tcp,raw,2` and silenced all output except the
conversation with `-q`. From there, I had to transform the data to remove all
non-hex output. The given example starts every response with a tab, so I just
grabbed the remaining characters with Awk and piped the result to Xxd to be
reconstructed. I did have to mess around with different ways of reconstructing
the image for a while, but I was reassured that the stream begins with the same
[file identifier](https://www.garykessler.net/library/file_sigs.html), `8950`,
in hex.

## Lab 12: HTTP over TLS

In this lab I was disappointed to find that you can learn a lot about an
encrypted TLSv1.3 conversation even *without* decrypting it with X.509
certificates. I figured I'd end the course by learning a cool and surprisingly
versatile hacker trick, but it turns out you can do enough sleuthing the normal
way that it can be unnecessary. So I will be focusing on Ross Bagurdes'
Pluralsight course, "Analyzing and Decrypting TLS with Wireshark", which spends
nearly an hour explaining the TLS handshake before showing the solution in two
five-minute videos, with another fifteen to decrypt and display the traffic.
I'll keep it to the point, and you'll keep this trick in your back pocket for
an obscure CTF question about packet inspection, I don't know.

To decrypt TLS traffic from your host computer, you will need a web browser as
well as your shell. This is because Firefox or Chrome can export your key logs
as you access different websites, so you can debug the Certificate Signing
Requests and such. Start by closing any open web browsers (that includes
background processes, *Firefox*) and setting the `SSLKEYLOGFILE` environment
variable to the path where you'd like to capture your keys, then open Firefox
or Chrome from your terminal and navigate to a website. Note that if you close
the terminal or open the browser from another app, your terminal won't
propagate the variable and your browser won't save your keys.

```bash
export SSLKEYLOGFILE=~/dl/keys.log # && firefox gnu.org
```

Now we can start capturing traffic with Tshark or Tcpdump and open Firefox to a
random website for a few seconds of sample input. We need to make sure the TLS
handshake is captured so we can see the initial key exchange and verify our
hashes and such.

