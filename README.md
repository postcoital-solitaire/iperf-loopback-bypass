# iperf-loopback-bypass
A short script to enable running `iperf3` on a single device (given multiple network interfaces are available).



## How it works
If you ever ran `iperf3` on a single device and just used different IP addresses for a client and server, you might have discovered that your device is smart enough to understand that the two addresses are on the same device and bypass the physical link entirely.

This script avoids this optimization by assigning different namespaces to interfaces so that packets are routed through the physical link.

Note that this script may replace network namespaces. Use with caution if you have any set up.



## How to use
### 1. Install required packages
This script requires [`iperf3`](https://iperf.fr/) to be installed and [`bash`](https://www.gnu.org/software/bash/) to be used as a shell. The script has only been tested with `bash` on Kubuntu as of now.

### 2. Get network interfaces' names
Before running the script, identify the names of two network interfaces you will use. You can use `ip a` to know what interfaces are available on your device.

### 3. Run `main-script.sh` as the server
After cloning the repository, add running privileges to the script before running it. From the repository root, run:
```bash
chmod +x main-script.sh
```
The script can now be executed. It requires `root` privileges to set up network namespaces. In the first shell, run:
```bash
sudo ./main-script.sh firstinterface server
```
Replace `firstinterface` with the name of your first interface. This will set up the network namespaces and run `iperf3` server.

### 4. Run `main-script.sh` as the client
In another shell, from the repository root, run:
```bash
sudo ./main-script.sh secondinterface client
```
Replace `secondinterface` with the name of your second interface. You should now see `iperf3` working as usual. If you don't, please let me know.



## Additional features
### Built-in interface list
If you're unsure which interfaces to use, simply run the script without any arguments and it will list available interfaces using `ls /sys/class/net`:
```
Main script error: provided interface does not exist. Available interfaces:
eth0 eth1 lo
```

### Changing namespaces and IP addresses
By default, this script uses `10.0.0.253` and `isolated-iperf-server` for the address and namespace for the server respectively, and `10.0.0.254` and `isolated-iperf-client` for the client. If these addresses and namespaces are already in use in your network setup, you can override them like this:
```bash
sudo server_address="10.0.0.100" server_namespace="yournamespace" ./main-script.sh eth0 server
```
This will set `10.0.0.100` as an IP address for the server and `yournamespace` as the namespace. 
You can also provide additional options for the `iperf3` command directly via `iperf_args`:
```bash
sudo iperf_args="-1 -v -p 8993" ./main-script.sh eth0 server
```
Available override options:
- `server_address`: server address, default `10.0.0.253`;
- `server_namespace`: server network namespace, default `isolated-iperf-server`;
- `client_address`: client address, default `10.0.0.254`;
- `client_namespace`: client network namespace, default `isolated-iperf-client`;
- `subnet_mask`: subnet mask, default `24`;
- `iperf_args`: arguments to be passed to `iperf3`, default empty.
