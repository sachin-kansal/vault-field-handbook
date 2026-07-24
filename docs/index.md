# HashiCorp Vault — A Practical Guide

Welcome! This guide is built from hands-on experience running Vault in real environments — from a Raspberry Pi homelab to production clusters with Kubernetes, Prometheus, and auto-unseal. Whether you are just getting started or looking to go beyond basic KV storage, you will find opinionated, working configurations here.

> Most teams use Vault only as a key-value store. This guide shows what Vault actually is: a complete security platform covering identity, dynamic secrets, certificate issuance, SSH access, and encryption — all with audit trails and Prometheus metrics.

---

## What's Covered

### Introduction
- [Why Vault](00-Intro/Why_Vault.md) — why KV-only Vault is leaving most of the value on the table
- [Architecture Internals](00-Intro/architecture.md) — how Vault's core components fit together

### Installation & Configuration
- [Production Setup on Linux](01-Configuration_and_installation/install-vault-on-pi.md) — install, harden, configure TLS, telemetry, and systemd
<!-- - [Auto-Unseal with AWS KMS](01-Configuration_and_installation/vault-auto-unseal-aws.md) -->
- [Auto-Unseal with GCP KMS](01-Configuration_and_installation/vault-auto-unseal-gcp.md)

### Token Management

- [Introduction](02-Tokens\Intro.md) - Everything happens with a token
- [Root Token](02-Tokens\Root_token.md) - Most privilege Handle with Care
- [Service and Batch Tokens](02-Tokens\ServicevsBatch.md)  - Tokens used on daily basis

### Authentication Methods
- [Username & Password](04-auth-methods/userpass.md) — moving away from root tokens for human users
- [Kubernetes Agent Injector](04-auth-methods/agentinjector.md) — pod-level identity and sidecar secret injection

### Secret Engines
- [KV (Key/Value)](06-secret-engines/kv.md) — the most common engine; storing and versioning static secrets
- [SSH Engine](06-secret-engines/ssh.md) — short-lived signed certificates instead of static SSH keys

### Operations
- [Migrating Storage Backend](07-Operations/migrating-backened.md) — moving from filesystem to a production-grade backend

---

## Where to Start

If you are new to Vault, read [Why Vault](00-Intro/Why_Vault.md) first, then follow the [Production Setup](01-Configuration_and_installation/install-vault-on-pi.md) guide to get a running instance. From there, pick the auth method and secret engines that match your use case.