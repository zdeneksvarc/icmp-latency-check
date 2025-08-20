# ICMP Latency Check

A simple Bash script that pings multiple targets and sorts them by average latency. Useful for choosing the nearest datacenter based on latency.

The IP addresses in the `examples` directory were taken from public sources (Shodan.io, RIPE NCC, web search).

## Usage

| Command                    | Effect                     |
|-----------------------------|----------------------------|
| `./ping.sh`                | 3 pings, use `default.txt` |
| `./ping.sh 10`             | 10 pings, use `default.txt`|
| `./ping.sh targets.txt`    | 3 pings, use `targets.txt` |
| `./ping.sh 10 targets.txt` | 10 pings, use `targets.txt`|

## Example

```bash
$ ./ping.sh
...
localhost            127.1            0.047
google.com           google.com       6.684
dns-opendns          208.67.222.222   7.810
dns-cloudflare       1.1              7.986
dns-quad9            9.9.9.9          11.116

$ ./ping.sh examples/upcloud.txt
...
=================== SUMMARY ==================
Target               IP               Avg (ms)
----------------------------------------------
Germany              94.237.103.106   14.237
Finland              85.9.218.236     25.783
Netherlands          85.9.211.180     26.241
UK                   94.237.54.200    37.810
Singapore            94.237.64.180    171.157
```