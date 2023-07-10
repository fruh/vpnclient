FROM ubuntu:20.04

RUN apt-get update && apt-get install -y vim curl net-tools tinyproxy

RUN sed -i 's/^Allow 127.0.0.1/Allow 0.0.0.0\/0/g' /etc/tinyproxy/tinyproxy.conf

RUN apt-get update && apt-get install -y openconnect
RUN apt-get update && apt-get install -y dante-server
RUN curl -o /root/kerio.deb https://cdn.kerio.com/dwn/control/control-9.3.6-5738/kerio-control-vpnclient-9.3.6-5738-linux-amd64.deb
# RUN apt-get update && apt-get install -y openfortivpn	
RUN apt-get update && apt-get install -y gcc automake autoconf libssl-dev make pkg-config git

RUN git clone https://github.com/adrienverge/openfortivpn.git /tmp/openfortivpn
RUN cd /tmp/openfortivpn && ./autogen.sh
RUN cd /tmp/openfortivpn && ./configure --prefix=/usr/local --sysconfdir=/etc
RUN cd /tmp/openfortivpn && make
RUN cd /tmp/openfortivpn && make install


RUN echo "logoutput: stderr" > /etc/danted.conf
RUN echo "internal: 0.0.0.0 port = 1080" >> /etc/danted.conf
RUN echo "external: eth0" >> /etc/danted.conf
RUN echo "clientmethod: none" >> /etc/danted.conf
RUN echo "socksmethod: none" >> /etc/danted.conf
RUN echo "user.privileged: proxy" >> /etc/danted.conf
RUN echo "user.unprivileged: nobody" >> /etc/danted.conf
RUN echo "user.libwrap: nobody" >> /etc/danted.conf
RUN echo "" >> /etc/danted.conf
RUN echo "client pass {" >> /etc/danted.conf
RUN echo "    from: 0.0.0.0/0 port 1-65535 to: 0.0.0.0/0" >> /etc/danted.conf
RUN echo "    log: connect disconnect error" >> /etc/danted.conf
RUN echo "}" >> /etc/danted.conf
RUN echo "" >> /etc/danted.conf
RUN echo "socks pass {" >> /etc/danted.conf
RUN echo "    from: 0.0.0.0/0 port 1-65535 to: 0.0.0.0/0" >> /etc/danted.conf
RUN echo "    log: connect disconnect error" >> /etc/danted.conf
RUN echo "}" >> /etc/danted.conf

RUN echo "tinyproxy" >> /root/.bash_history
RUN echo "netstat -tlnp" >> /root/.bash_history
RUN echo "openconnect --protocol=anyconnect -u <user> <server>" >> /root/.bash_history
RUN echo "openconnect --protocol=anyconnect --authgroup <group> -u <user> <server>" >> /root/.bash_history
RUN echo "dpkg-reconfigure kerio-control-vpnclient" >> /root/.bash_history
RUN echo "vim /etc/kerio-kvc.conf" >> /root/.bash_history
RUN echo "vim /etc/kerio-kvc.conf" >> /root/.bash_history
RUN echo "service kerio-kvc stop" >> /root/.bash_history
RUN echo "service kerio-kvc start" >> /root/.bash_history
RUN echo "service kerio-kvc reload" >> /root/.bash_history
RUN echo "less /var/log/kerio-kvc/" >> /root/.bash_history
RUN echo "dpkg -i /root/kerio.deb" >> /root/.bash_history
RUN echo "openfortivpn server:port -u user -p pass" >> /root/.bash_history

EXPOSE 8888
EXPOSE 1080

CMD service danted start && tinyproxy && echo "\nStart with this cmd:\n\ndocker run --privileged  -p 127.0.0.1:8888:8888 -p 127.0.0.1:1080:1080 -it vpnclient\n\n1080/tcp - socks5 proxy server\n8888/tcp - http proxy server\n" && bash
