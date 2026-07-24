# Why Vault

Many organisations use Vault exclusively for the KV secrets engine —
storing certificates, environment files, and static database credentials.
When asked why they chose Vault, most engineers give the same answers:
security, reusability of secrets, and prevention of secret sprawl.
These are genuine and important reasons.

But using Vault only for KV is like using an AI agent to do third grade
maths. You are paying the full cost of complexity and getting a fraction
of the value.

Vault provides authentication integrations with almost every major
platform — AWS, GCP, Azure, Kubernetes, Okta, GitHub, and more. Beyond
KV, its secrets engines include:

- **PKI** — issue and rotate TLS certificates automatically
- **SSH** — short-lived signed certificates instead of static keys
- **Database** — dynamic credentials that expire after use
- **Kubernetes** — pod-level identity and secret injection
- **And More** 
![default_engines](../assets/listof%20secretengines.png)

We can also create our own custom Secret Engine if the requrements are not met by the provided ones.

Add to this just-in-time cloud access, audit logs, Prometheus telemetry,
and automatic failover — and the picture changes completely.

Used together, these features transform Vault from a password manager
into a complete security platform — one that handles identity, access,
encryption, and audit across your entire infrastructure.

We are gonna explore the each of these system and what are thier caveats