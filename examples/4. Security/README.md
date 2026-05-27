## Security Without Compromise (Connext Secure)
IT departments are often hesitant to allow data bridging because of "lateral movement" risks (the fear that a breach in one device leads to the whole network).
* **The Problem:** Standard network security (like a VPN) is "all or nothing"—once you're in, you can see everything.

```mermaid
graph LR
    Attacker((Attacker)) -->|Breach Wall| Network["Internal Network"]
    Network --> Appliance["Connext Appliance"]
    Network --> DB[("Sensitive Database")]
    Appliance -.->|"Lateral Movement Risk"| DB

    style Network fill:#fff5f5,stroke:#ff9999,stroke-width:1px
    style Appliance fill:#fff5f5,stroke:#ff9999,stroke-width:1px
    style DB fill:#fff5f5,stroke:#ff9999,stroke-width:1px
```

* **The Appliance Solution:** **Connext Secure** provides fine-grained, data-centric security. It encrypts and authenticates individual "Topics" (specific data streams).

```mermaid
graph LR
    App_A["Connext Appliance"] ===|"Topic: 'Heart Rate' / Encrypted & Allowed"| App_B["Remote Network"]
    App_A -.-x|"Topic: 'Unauthorized Command' / BLOCKED"| App_B

    style App_A fill:#f5fff5,stroke:#99ff99,stroke-width:1px
    style App_B fill:#f5fff5,stroke:#99ff99,stroke-width:1px
```
* **Transformative Impact:** Even though your appliance is bridging the network, it enforces a **Zero-Trust** model. You can prove to IT that the appliance *only* forwards "Heart Rate" data and strictly blocks any unauthorized commands, satisfying even the most rigid cybersecurity audits.

Example 3 focused on WAN reachability (RT/WAN transport + CDS-assisted discovery through NAT/firewall).
Example 4 keeps that same connectivity model and adds authentication, authorization, signing, and encryption across all participants.


### What Example 4 adds over Example 3

```mermaid
graph TD
    subgraph Discovery [Discovery Plane: Cloud Discovery Service]
        App_A[Local Participant: App_A] <-->|RTPS Pre-Shared Key PSK Protection| CDS[Cloud Discovery Service CDS]
        CDS <-->|RTPS Pre-Shared Key PSK Protection| App_B[Remote Participant: App_B]
    end

    subgraph DataPlane [Data Plane: Peer-to-Peer Data Path]
        App_A <-->|Authenticated, Authorized & Encrypted Streams| App_B
    end

    classDef secure fill:#e6f7ff,stroke:#1890ff,stroke-width:2px;
    class App_A,App_B,CDS secure;
```

- Example 3: participants can discover each other over WAN using CDS and then communicate peer-to-peer.
- Example 4: all participants use security plugins and signed security artifacts so connectivity is not only reachable, but trusted and policy-controlled.
- Security also covers participant discovery via CDS: CDS-relayed discovery traffic is protected with RTPS PSK settings, not left in plaintext.

### Security Model in this example

- Local participant and remote participant use DDS Security identity/auth/access-control artifacts:
        - identity CA/certificate/private key
        - signed governance file
        - signed permissions file
- CDS discovery path is also protected with RTPS PSK properties:
        - same passphrase on CDS and participants
        - same algorithm on CDS and participants
        - same protection kind on CDS and participants

This means both endpoint communication and participant discovery are protected.

### Governance and permissions: how policy is defined

The governance file defines domain-level and topic-level protection requirements. In this example:

- Unauthenticated participants are rejected.
- Join access control is enabled.
- RTPS protection is applied.
- RTPS PSK protection is enabled for CDS-assisted discovery/WAN binding traffic.
- Topic rules specify what is encrypted and what is access-controlled.

Permissions files define who is allowed to do what:

- `Local_Participant` (App_A): publish + subscribe on domains 0-10.
- `Remote_Participant` (App_B): publish only on domain 1, and only to Square/Triangle.
- Default action is DENY.

```mermaid
graph TD
    Request([Incoming Connection or Data Packet]) --> Gov{1. Governance File Rules <br> Global Domain Policy}
    
    Gov -->|Unauthenticated| Reject[REJECT PARTICIPANT]
    Gov -->|Meets Security Profile| Perm{2. Permissions File Rules <br> Individual Identity Rights}

    Perm -->|App_A: Publish + Subscribe| AllowA[ALLOW Access to Domains 0-10]
    Perm -->|App_B: Publish Only| AllowB[ALLOW Access to Domain 1 Square/Triangle]
    Perm -->|Any unmodeled topic or action| Deny[DEFAULT ACTION: DENY]

    style Reject fill:#ffeef0,stroke:#f97583,stroke-width:2px
    style Deny fill:#ffeef0,stroke:#f97583,stroke-width:2px
    style AllowA fill:#e1f3d8,stroke:#67c23a,stroke-width:2px
    style AllowB fill:#e1f3d8,stroke:#67c23a,stroke-width:2px
```

### Topic policy differences (threat-model illustration)

This demo uses two topics with different protections to show how threat modeling changes policy:

- `Square`:
        - payload data is encrypted
        - metadata is not encrypted
        - useful for lower-sensitivity telemetry where confidentiality is needed but metadata exposure is acceptable

- `Triangle`:
        - payload data is encrypted
        - metadata is also encrypted
        - useful for higher-sensitivity data where topic-level metadata leakage is not acceptable

A wildcard fallback rule denies access and disables protection for any topic not explicitly modeled.

```mermaid
graph LR
    subgraph Square_Topic [Topic: Square Telemetry Boundary]
        direction LR
        S_Meta[Metadata: Topic Name / Sequence #] -->|Clear Text / Readable| S_Net((Network))
        S_Pay[Payload Data] -->|ENCRYPTED| S_Net
    end

    subgraph Triangle_Topic [Topic: Triangle High-Sensitivity Boundary]
        direction LR
        T_Pack[Full Packet: Metadata + Payload] -->|Enclosed & Encrypted Together| T_Env[Outer Crypto Envelope]
        T_Env --> T_Net((Network))
    end

    style Square_Topic fill:#fafafa,stroke:#dcdfe6
    style Triangle_Topic fill:#fafafa,stroke:#dcdfe6
```

### Sign security artifacts

From the security certificates created when the router was first configured (see [top-level readme](../../router/README.md)):

- To sign the governance file
```bash
openssl smime \
        -sign \
        -in governance.xml \
        -out governance.p7s \
        -signer [enter path]/security/cert/root-ca-cert.pem \
        -inkey [enter path]/security/root-ca/private/key.pem
```

- To sign the permissions file:

```bash
openssl smime \
        -sign \
        -in permissions.xml \
        -out permissions.p7s \
        -signer [enter path]/security/cert/root-ca-cert.pem \
        -inkey [enter path]/security/root-ca/private/key.pem
```

```mermaid
graph LR
    subgraph Inputs [Raw Configuration Files]
        Gov[governance.xml]
        Perm[permissions.xml]
    end

    subgraph Keys [Root Authority]
        Key[Private Key: key.pem]
        Cert[Root CA Cert: root-ca-cert.pem]
    end

    Engine[[OpenSSL S/MIME Signing Engine]]

    subgraph Outputs [Signed Production Artifacts]
        Gov_S[(governance.p7s)]
        Perm_S[(permissions.p7s)]
    end

    Gov --> Engine
    Perm --> Engine
    Key --> Engine
    Cert --> Engine
    
    Engine --> Gov_S
    Engine --> Perm_S

    style Gov fill:#ffffff,stroke:#333
    style Perm fill:#ffffff,stroke:#333
    style Gov_S fill:#f1f8ff,stroke:#0366d6,stroke-width:2px
    style Perm_S fill:#f1f8ff,stroke:#0366d6,stroke-width:2px
```    
