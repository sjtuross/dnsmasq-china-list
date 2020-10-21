SERVER=114.114.114.114
NEWLINE=UNIX

raw:
	sed -e 's|^server=/\(.*\)/114.114.114.114$$|\1|' accelerated-domains.china.conf | egrep -v '^#' > build/accelerated-domains.china.raw.txt
	sed -e 's|^server=/\(.*\)/114.114.114.114$$|\1|' google.china.conf | egrep -v '^#' > build/google.china.raw.txt
	sed -e 's|^server=/\(.*\)/114.114.114.114$$|\1|' apple.china.conf | egrep -v '^#' > build/apple.china.raw.txt

dnsmasq: raw
	sed -e 's|\(.*\)|server=/\1/$(SERVER)|' accelerated-domains.china.raw.txt > build/accelerated-domains.china.conf
	sed -e 's|\(.*\)|server=/\1/$(SERVER)|' google.china.raw.txt > build/google.china.conf
	sed -e 's|\(.*\)|server=/\1/$(SERVER)|' apple.china.raw.txt > build/apple.china.conf
	cp bogus-nxdomain.china.conf build/bogus-nxdomain.china.conf

coredns: raw
	sed -e "s|\(.*\)|\1 {\n  forward . $(SERVER)\n}|" accelerated-domains.china.raw.txt > build/accelerated-domains.china.coredns.conf
	sed -e "s|\(.*\)|\1 {\n  forward . $(SERVER)\n}|" google.china.raw.txt > build/google.china.coredns.conf
	sed -e "s|\(.*\)|\1 {\n  forward . $(SERVER)\n}|" apple.china.raw.txt > build/apple.china.coredns.conf

smartdns: raw
	sed -e "s|\(.*\)|nameserver /\1/$(SERVER)|" accelerated-domains.china.raw.txt > build/accelerated-domains.china.smartdns.conf
	sed -e "s|\(.*\)|nameserver /\1/$(SERVER)|" google.china.raw.txt > build/google.china.smartdns.conf
	sed -e "s|\(.*\)|nameserver /\1/$(SERVER)|" apple.china.raw.txt > build/apple.china.smartdns.conf
	sed -e "s|=| |" bogus-nxdomain.china.conf > build/bogus-nxdomain.china.smartdns.conf

unbound: raw
	sed -e 's|\(.*\)|forward-zone:\n  name: "\1."\n  forward-addr: $(SERVER)\n|' accelerated-domains.china.raw.txt > build/accelerated-domains.china.unbound.conf
	sed -e 's|\(.*\)|forward-zone:\n  name: "\1."\n  forward-addr: $(SERVER)\n|' google.china.raw.txt > build/google.china.unbound.conf
	sed -e 's|\(.*\)|forward-zone:\n  name: "\1."\n  forward-addr: $(SERVER)\n|' apple.china.raw.txt > build/apple.china.unbound.conf
ifeq ($(NEWLINE),DOS)
	sed -i 's/\r*$$/\r/' build/accelerated-domains.china.unbound.conf build/google.china.unbound.conf build/apple.china.unbound.conf
endif

bind: raw
	sed -e 's|\(.*\)|zone "\1." {type forward; forwarders { $(SERVER); }; };|' accelerated-domains.china.raw.txt > build/accelerated-domains.china.bind.conf
	sed -e 's|\(.*\)|zone "\1." {type forward; forwarders { $(SERVER); }; };|' google.china.raw.txt > build/google.china.bind.conf
	sed -e 's|\(.*\)|zone "\1." {type forward; forwarders { $(SERVER); }; };|' apple.china.raw.txt > build/apple.china.bind.conf
ifeq ($(NEWLINE),DOS)
	sed -i 's/\r*$$/\r/' build/accelerated-domains.china.bind.conf build/google.china.bind.conf build/apple.china.bind.conf
endif

dnscrypt-proxy: raw
	sed -e 's|\(.*\)|\1 $(SERVER)|' accelerated-domains.china.raw.txt google.china.raw.txt apple.china.raw.txt > build/dnscrypt-proxy-forwarding-rules.txt
ifeq ($(NEWLINE),DOS)
	sed -i 's/\r*$$/\r/' build/dnscrypt-proxy-forwarding-rules.txt
endif

dnsforwarder6: raw
	{ printf "protocol udp\nserver $(SERVER)\nparallel on \n"; cat accelerated-domains.china.raw.txt; } > build/accelerated-domains.china.dnsforwarder.conf
	{ printf "protocol udp\nserver $(SERVER)\nparallel on \n"; cat google.china.raw.txt; } > build/google.china.dnsforwarder.conf
	{ printf "protocol udp\nserver $(SERVER)\nparallel on \n"; cat apple.china.raw.txt; } > build/apple.china.dnsforwarder.conf
ifeq ($(NEWLINE),DOS)
	sed -i 's/\r*$$/\r/' build/accelerated-domains.china.dnsforwarder.conf build/google.china.dnsforwarder.conf build/apple.china.dnsforwarder.conf
endif

adguardhome: raw
	cat google.china.raw.txt | tr "\n" "/" | sed -e 's|^|/|' -e 's|\(.*\)|[\1]$(SERVER)|' > build/google.china.adguardhome.conf
	cat accelerated-domains.china.raw.txt | tr "\n" "/" | sed -e 's|^|/|' -e 's|\(.*\)|[\1]$(SERVER)|' > build/accelerated-domains.china.adguardhome.conf
	cat apple.china.raw.txt | tr "\n" "/" | sed -e 's|^|/|' -e 's|\(.*\)|[\1]$(SERVER)|' > build/apple.china.adguardhome.conf
ifeq ($(NEWLINE),DOS)
	sed -i 's/\r*$$/\r/' build/accelerated-domains.china.adguardhome.conf build/google.china.adguardhome.conf build/apple.china.adguardhome.conf
endif

clean:
	rm -f build/accelerated-domains.china.raw.txt build/google.china.raw.txt build/apple.china.raw.txt
