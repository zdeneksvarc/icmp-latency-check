# ICMP Latency Check

Simple Bash script to ping multiple targets and sort them by average latency. Good for choosing nearest datacenter by latency.

## Usage

| Command                    | Effect                     |
|-----------------------------|----------------------------|
| `./ping.sh`                | 5 pings, use `default.txt` |
| `./ping.sh 10`             | 10 pings, use `default.txt`|
| `./ping.sh targets.txt`    | 5 pings, use `targets.txt` |
| `./ping.sh 10 targets.txt` | 10 pings, use `targets.txt`|

## Example

```bash
$ ./ping.sh upcloud-2025-08.txt
...
=================== SUMMARY ===================
Target               IP               Avg in ms
-----------------------------------------------
Germany              94.237.103.106   14.237
Finland              85.9.218.236     25.783
Netherlands          85.9.211.180     26.241
UK                   94.237.54.200    37.810
Singapore            94.237.64.180    171.157
```