## Navigating Complex Firewalls (Real-Time WAN Transport)
Hospitals often use Network Address Translation (NAT) and strict firewalls that block incoming connections, preventing remote monitoring or telemedicine.
* **The Problem:** Even if you have the IP, the firewall will drop packets that it didn't specifically "ask for."
* **The Appliance Solution:** The **RT/WAN transport** uses UDP hole punching. It allows the appliance to establish a peer-to-peer connection through the firewall by "punching" a path out that the remote side can then use to talk back.
* **Transformative Impact:** It provides **VPN-like connectivity without the overhead or latency of a VPN**, allowing real-time data to flow across different network segments securely and reliably.


This example shows Real-Time WAN Transport (UDPv4_WAN), Cloud Discovery Service (CDS), and Shapes Demo to demonstrate a hospital-hosted deployment where:

 - CDS runs inside Hospital A
 - one Shapes Demo instance also runs inside Hospital A
 - a remote console / teleoperator runs outside the hospital at a remote center

### Scenario

A hospital wants to allow a remote telesurgery console to access hospital systems from outside the network without requiring a VPN in the data path.

### The problem

Hospital networks often use:

 - NAT
 - strict firewalls
 - blocked unsolicited inbound traffic

This prevents a remote console from directly reaching internal DDS participants unless the network is configured carefully.

### The solution

Use:

 - Real-Time WAN Transport
 - Cloud Discovery Service
 - a static NAT mapping for CDS at Hospital A

This allows:

 - The remote consol to contact CDS at a known public address
 - CDS to assist discovery and public-address resolution
 - The hospital participant and remote participant to communicate peer-to-peer over WAN transport

### Topology
```text
            Cloud VM (Remote Publisher)
      +--------------------------------------+
      | Shapes Demo (Publish Square)         |
      | Profile: RemoteMonitorBase           |
      +------------------+-------------------+
                         |
                         | UDPv4_WAN to rtps@udpv4_wan://HUB_PUBLIC_IP:HUB_PUBLIC_PORT
                         v
========================= Internet / WAN =========================
                         ^
                         |
          Home Router Public NAT / Firewall (Hospital edge)
          WAN HUB_PUBLIC_PORT -> LAN 10.101.0.190:7400 (UDP)
                         |
------------------------------------------------------------------
|                        Hospital A LAN                           |
|                                                                 |
|   +----------------------------+    +-------------------------+  |
|   | Cloud Discovery Service    |    | Shapes Demo (Subscriber)|  |
|   | Host: 10.101.0.190:7400    |    | Profile: HospitalInternalBase |
|   | public_address=HUB_PUBLIC_IP|   | Subscribe Square        |  |
|   +----------------------------+    +-------------------------+  |
|                                                                 |
------------------------------------------------------------------
```

### Interaction model

 - Hospital A Shapes instance is an internal participant
 - CDS is also inside Hospital A, but exposed publicly through static NAT
 - Remote console is the external participant
 - Both participants use Real-Time WAN Transport (UDPv4_WAN)
 - Both participants use the public CDS address as their initial peer
 - CDS helps discovery and public-address resolution
 - After discovery, communication is peer-to-peer over WAN transport, not through CDS for user data

That peer-to-peer behavior after CDS-assisted discovery is described in the RT/WAN NAT traversal documentation.

### Important Note
Both participants point to the public CDS address:

`<element>rtps@udpv4_wan://HUB_PUBLIC_IP:HUB_PUBLIC_PORT</element>`

Even the internal hospital participant can use the public CDS address in this WAN-oriented demo model. RTI’s WAN documentation describes CDS as being identified by its publicly reachable address for WAN participants.

If the firewall does not support hairpin NAT / loopback NAT, the internal participant may need a different deployment approach. 
For this simple demo, the assumption is that Hospital A can reach the CDS public address.

### How discovery works in this topology
#### Step 1: CDS starts inside Hospital A

CDS listens on:
 - private host: 192.168.1.1
 - UDP port: 7400

Hospital A firewall/NAT exposes it publicly as:
- HUB_PUBLIC_IP:HUB_PUBLIC_PORT

#### Step 2: Hospital A Shapes Demo starts

The internal participant:

 - uses UDPv4_WAN
 - sends discovery traffic to: `rtps@udpv4_wan://HUB_PUBLIC_IP:HUB_PUBLIC_PORT`

#### Step 3: Remote console starts

The external participant:

 - also uses UDPv4_WAN
 - also sends discovery traffic to: `rtps@udpv4_wan://HUB_PUBLIC_IP:HUB_PUBLIC_PORT`

#### Step 4: CDS resolves reachable addresses

CDS inspects the received WAN discovery traffic and extends participant announcements with service-reflexive/public address information so the peers can learn how to reach each other.

#### Step 5: Peer-to-peer communication begins

After discovery and address resolution:

 - Hospital A Shapes Demo and the remote console communicate directly over WAN transport
 - CDS is not the steady-state user-data relay

That direct communication step is explicitly described in the CDS NAT traversal documentation.

### Running the demo
#### Start CDS inside Hospital A

On the CDS host:

rticlouddiscoveryservice -cfgFile cds.xml -cfgName HospitalCDS

#### Start Shapes Demo inside Hospital A

 - Configure a UDP port-forward rule on your internet router so WAN HUB_PUBLIC_IP:HUB_PUBLIC_PORT forwards to LAN 192.168.1.1:7400 (the CDS host).
 - Place USER_RTI_SHAPES_DEMO_QOS_PROFILES.xml in the Shapes Demo workspace

 - Start Shapes Demo
 - Use Domain 0
 - Open Controls / Configuration
 - Press Stop
 - Select profile HospitalInternalBase
 - Press Start
 - Subscribe to Square

#### Start Shapes Demo at the remote center

 - Place the same QoS file in the Shapes Demo workspace
 - Edit the QoS file to set the HUB_PUBLIC_IP and HUB_PUBLIC_PORT
 - Start Shapes Demo
 - Use Domain 0
 - Open Controls / Configuration
 - Press Stop
 - Select profile RemoteMonitorBase
 - Press Start
 - Publish a Square shape 
