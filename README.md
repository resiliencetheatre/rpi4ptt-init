# Init SecurePTT

This is initialization script for [SecurePTT](https://github.com/resiliencetheatre/rpi4ptt) demonstration. 

You need to adopt this in your environment and make sure you change /dev/urandom to 
proper TRNG in script. By default this uses [udp2raw](https://github.com/wangyu-/udp2raw)
encapsulation on traffic and you need to have VPS capable to terminate that 
encapsulation before using Wireguard as routing layer. Other option is to use 
[rtptun](https://github.com/me-asri/rtptun) and you are free to onboard anything else to hide
Wireguard meta data on wire. 

If you have flat layer2/3 MESH/MANET network you can skip using wireguard with encapsulation
because nodes can reach each other without being routed through VPS. VPS is needed only
if you want to have communication from [CGNAT](https://en.wikipedia.org/wiki/Carrier-grade_NAT)
enabled networks, like cellular and some satellite networks.

You can run solution on Raspberry Pi or PC. Created configuration artifacts with .pc ending 
are modified to be used with Debian 12 distribution.

Before running, you need to create initparams.txt file with following variables:

```
GEN_SERVER_ADDRESS=[IP]
GEN_RTPTUN_KEY=[BASE64_ENCODED_KEY]
GEN_UDP2RAW_PASSWORD=[TXT_STRING_PASSWORD]
SERVER_PUBKEY="[SERVER_PUBKEY]"
```

Generate [rtptun](https://github.com/me-asri/rtptun) key with:

```
rtptun genkey
```

Server public key for wireguard (SERVER_PUBKEY) is copied from gateway
server.

## Links

* https://github.com/raspberrypi/Pi-Codec
* https://github.com/wangyu-/udp2raw
* https://github.com/me-asri/rtptun
