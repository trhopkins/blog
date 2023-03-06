#!/usr/bin/python3

import sys

a = "47656c6c6f20776f726c640a"

s = sys.argv[1]
hex_chars = [a[i:i+2] for i in range(0, len(s), 2)]

chars = "".join([chr(int(i, 16)) for i in hex_chars])
print(chars)

def hex_to_ascii(s):
    return "".join([chr(int(s[i:i+2], 16)) for i in range(0, len(s), 2)])

#print(hex_to_ascii(sys.argv[1]))

