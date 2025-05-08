
## SSH into HAProxy VM in the GCP console
1. Verify haproxy configuration and checking internal IP configure of k8s backend service
```shell
cat /etc/haproxy/haproxy.cfg
```
Following information will be added in the configuration, Output:
```shell
frontend http_front
        bind *:80
        mode http
        default_backend haproxy_ingress_backend
backend haproxy_ingress_backend
    mode http
    balance roundrobin
    server-template app 3 _k8s-worker-node._tcp.service.consul check maxconn 32
```

2. Verify the tcp connection 30080 port 
```shell
sudo apt install telnet -y
telnet 10.142.0.39 30080
```

3. Verify the dig the consul dns
```shell
sudo apt install dnsutils
dig _k8s-worker-node._tcp.service.consul SRV @127.0.0.1 -p 8600
```

```shell

; <<>> DiG 9.18.30-0ubuntu0.22.04.2-Ubuntu <<>> _k8s-worker-node._tcp.service.consul SRV @127.0.0.1 -p 8600
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12109
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 4
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;_k8s-worker-node._tcp.service.consul. IN SRV

;; ANSWER SECTION:
_k8s-worker-node._tcp.service.consul. 0 IN SRV  1 1 30080 myp-dev-k8s-worker-node-1.node.dc1.consul.

;; ADDITIONAL SECTION:
myp-dev-k8s-worker-node-1.node.dc1.consul. 0 IN A 10.0.1.6
myp-dev-k8s-worker-node-1.node.dc1.consul. 0 IN TXT "consul-network-segment="
myp-dev-k8s-worker-node-1.node.dc1.consul. 0 IN TXT "consul-version=1.20.6"

;; Query time: 3 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1) (UDP)
;; WHEN: Thu May 01 06:40:55 UTC 2025
;; MSG SIZE  rcvd: 212
```

✅ ANSWER SECTION
```shell
_k8s-worker-node._tcp.service.consul. 0 IN SRV  1 1 30080 myp-dev-k8s-worker-node-1.node.dc1.consul.
```

Service name: k8s-worker-node
Protocol: _tcp
Port: 30080 – this is the NodePort exposed by your K8s app
Target node: myp-dev-k8s-worker-node-1
Node IP: 10.0.1.6 (from the A record in the Additional Section)
This tells HAProxy or any client that it should connect to 10.0.1.6:30080 to reach the k8s-worker-node service.

4. Confirm members (if others have joined)
```bash
consul members
```
Output
```shell
myp-dev-consul-server-1    10.0.1.2:8301  alive   server  1.20.6  2         dc1  default    <all>
myp-dev-haproxy-lb-1       10.0.0.3:8301  alive   client  1.20.6  2         dc1  default    <default>
myp-dev-k8s-worker-node-1  10.0.1.6:8301  alive   client  1.20.6  2         dc1  default    <default>
```

1. Verify the proxy connection to wroker node connection
```shell
curl -v http://localhost
```