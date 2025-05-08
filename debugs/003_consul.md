### Verify the consul server

Confirm members (if others have joined)
```bash
consul members
```
Expected Output Example:

```shell
Node                     Address        Status  Type    Build   Protocol  DC   Partition  Segment
myp-dev-consul-server-1  10.0.1.3:8301  alive   server  1.20.6  2         dc1  default    <all>
```

### Debug services
Check listening ports (optional)
```bash
sudo netstat -tulnp | grep consul
```
Look for:
8500 → HTTP UI / API
8300 → RPC server (leader election)
8301 → LAN gossip (used by agents)
8302 → WAN gossip (if enabled)
8600 → DNS server

Verify agent mode is server
```bash
consul info | grep 'server ='
```
Expected:
```shell
server = true
```
Access Web UI
If Consul UI is enabled, visit:

```shell
http://<your-server-ip>:8500/ui
```

Logs for troubleshooting
```bash
sudo journalctl -u consul -f
```

Check the DNS access it 
```shell
dig _myapp._tcp.service.consul SRV @127.0.0.1 -p 8600
```