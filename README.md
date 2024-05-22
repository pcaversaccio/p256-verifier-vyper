# `P256Verifier` 🐍Vyper Contract

[![🕵️‍♂️ Test smart contracts](https://github.com/pcaversaccio/p256-verifier-vyper/actions/workflows/test.yml/badge.svg)](https://github.com/pcaversaccio/p256-verifier-vyper/actions/workflows/test.yml)
[![License: AGPL-3.0-only](https://img.shields.io/badge/License-AGPL--3.0--only-blue)](https://www.gnu.org/licenses/agpl-3.0)

<img src=https://github-production-user-asset-6210df.s3.amazonaws.com/25297591/275336509-62178250-58e7-4c27-9c1e-1f92f401dbc0.png width="650"/>

> [!TIP]
> A fully optimised and thoroughly tested `P256` verifier using the latest Vyper version `0.4.0` is implemented in 🐍 snekmate: https://github.com/pcaversaccio/snekmate/pull/243.

`P256` (a.k.a. `secp256r1` elliptic curve) signature verification [🐍Vyper contract](./src/P256Verifier.vy). These functions can be used to verify a `P256` signature. The implementation is inspired by [dcposch](https://github.com/dcposch)'s and [nalinbhardwaj](https://github.com/nalinbhardwaj)'s implementation [here](https://github.com/daimo-eth/p256-verifier/blob/master/src/P256Verifier.sol). Also, for more technical details, please refer to [EIP-7212](https://eips.ethereum.org/EIPS/eip-7212).

> [!WARNING]
> This is **experimental software** and is provided on an "as is" and "as available" basis. We **do not give any warranties** and **will not be liable for any losses** incurred through any use of this code base.

## Deployments

- Sepolia: [`0xD99D0f622506C2521cceb80B78CAeBE1798C7Ed5`](https://sepolia.etherscan.io/address/0xD99D0f622506C2521cceb80B78CAeBE1798C7Ed5)
- Holešky: [`0xD99D0f622506C2521cceb80B78CAeBE1798C7Ed5`](https://holesky.etherscan.io/address/0xD99D0f622506C2521cceb80B78CAeBE1798C7Ed5)

## Further References

- Daimo's GitHub Repository: [daimo-eth/p256-verifier](https://github.com/daimo-eth/p256-verifier)
- Daimo's Blog: [blog/p256verifier](https://daimo.com/blog/p256verifier)
- Daimo's Website: [p256.eth.limo](https://p256.eth.limo)
- Daimo's `P256Verifier` Deployment: [`0xc2b78104907F722DABAc4C69f826a522B2754De4`](https://etherscan.io/address/0xc2b78104907F722DABAc4C69f826a522B2754De4)
