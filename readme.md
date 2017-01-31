Docker Proxy Server With Content Filter
===
Docker has sparked a revolution in Platform as a Service. Numerous applications have been ported to Docker containers to run applications loads, and even more so Docker is replacing even some components that have traditionally been reserved for infrastructure. Now it is possible to run things like Web Application Firewalls and even outgoing proxy servers in containers. 

This project grew out of a need to replace an aging filtering system that I had been using that wasn't being updated anymore. I had previously patched the aging system to give it a new lease on life, but it has since been deprecated. Wanting to use the same blacklists as before and also wanting to Dockerize the proxy, I built a container image to use Squid and Squidguard to proxy and filter content on my LAN and VPN.

The inherent limitation of containerized applications is that they can't do low-level. Most containers can only do OSI layer 4+ sorts of applications. Lower level applications are reserved for routers, switches, and the like. Given that Proxies are usually layer 4 or layer 7 applications, they can be containerized, but the traffic needs to be routed through the container for it to be filtered.

![Docker Proxy Server](docker-proxy.png)

1. Traffic from the LAN hits the external firewall/router.
1. HTTP/HTTPS traffic is routed to the proxy/filter container, which filters the content.
1. Passed traffic is routed back to the firewall/router.
1. The firewall/router forwards the request back to the internet.

##Prerequisites

1. The files in this repository
1. A blacklist database. A list can be [found here](http://www.squidguard.org/blacklists.html).
1. The Docker Engine installed
1. The IP or Hostname of the machine or VM running the Docker Engine. This is needed to setup redirection in the container as well as to setup forwarding on the firewall.


## Using this Proxy

1. Download/Extract as a ZIP file or clone this repository with Git

1. Download a blacklist database. Squidguard maintains a list of [available blacklists here](http://www.squidguard.org/blacklists.html).

1. Extract the list into the blacklists folder. The folder structure should be **blacklists/category/file**. Each **category** has at least one **file**, either **domains**, **urls**, and/or **expressions**. So a domains file category ads would be /blacklists/ads/domains.

1. Edit the Dockerfile in your favorite text editor. The file has a variable called **BLACKLIST** that contains a comma separated list of categories. Edit this list with the categories to filter. The category matches the name of the category in the blacklists directory.

	**Example:**

	````
	ENV BLACKLIST adult,warez,weapons
	````

1. The file also contains a variable called **IP_OR_HOSTNAME**. Edit this varible to match the IP address or hostname of the Docker Engine's external name or IP. This is where the firewall/router will forward HTTP and HTTPS traffic to, and Docker will map ports to the container's ports.

	**Example:**

	````
	ENV IP_OR_HOSTNAME 192.168.99.100
	````

1. Build the image with Docker. In a command line provisioned to use docker, change directory to the folder working folder for the repository and run docker build.

	````
	docker build --tag docker-proxy .
	````

1. Lastly, push the image to a repository or run it directly on the machine used to build it with docker run.

	````
	docker run -dit -p 3128:3128 -p 80:80 --name proxy docker-proxy
	````

	The container needs two **-p** directives. **Port 3128** is the proxy port for the container. **Port 80** is the port for the redirect for the block page. The first number in the colon pairs is the external port, and the second is the internal port. The second number shouldn't be changed, however the first name can be changed. the **--name** directive can be anything, as this is the name of the container. The last parameter is the image tag.

1. The last step is to configure the router/firewall to use the proxy. Most firewalls allow rules to be defined based on the source of the traffic and its destination. For HTTP and HTTPS traffic, two forwarding rules need to be added wherein the source IP address is a LAN IP and the destination port is port 80 (for HTTP) and 443 (for HTTPS) respectively. Squid can handle both HTTPS and HTTP on the same port, so redirect the traffic to port the IP or hostname of the Docker Engine on port 3128.

1. Enjoy the proxy/content filter on Docker.