# 🧅 Onion POAP

Onion POAP is an initiative that hands out POAP tokens to people who run a Tor exit node.

To qualify for your POAP you need to:

1. Set up an exit node (see setup script below)
1. Keep your node running for at least one month
1. Claim your POAP at poap.delivery

⚠️ If you do not know what the following words mean, we recommend you do not continue: `shell`, `VPS`, `Tor`.

## Requirements

You should run your Tor exit node in a data center, probably as a VPS. The requires specs are:

1. Any modern CPU
1. 1.5 GB RAM
1. 256MB available for Tor

For details see [the official documentation]( https://community.torproject.org/relay/relays-requirements/ ).

## Setup TL;DR

Are you in a rush?

1. Buy a VPS with 1.5GB ram
2. Run `curl -sS https://raw.githubusercontent.com/actuallymentor/onion-poap/main/setup.sh | sudo bash`
3. Follow on screen instructions
4. Tweet your node IP to `@actuallymentor` (mentor.eth)

## Setup (the long version)

In order to qualify for an Onion POAP, you need to run a Tor exit node. Ideally, you do so at a datacenter. We're going to assume you are using a VPS (virtual private server) with Ubuntu `20.04 LTS`.

### Step 1: purchase a VPS

Not all VPS providers like it if you run a Tor exit node. The Tor community keeps a [ list of exit node friendly providers here ]( https://gitlab.torproject.org/legacy/trac/-/wikis/doc/GoodBadISPs ), and a community member hosts a list of [ those accepting Bitcoin here ]( https://torbitcoinvps.github.io/ ).

Most VPS providers have different VPS options. Choose one that has at least 1.5GB RAM. When asked about an operating system, choose Ubuntu `20.04 LTS`.

Your provider should send you a username, password and ip address. `Ssh` into your server now.

### Step 2: run the install script

You can run the automated install script on your VPS with:

```
curl -sS https://raw.githubusercontent.com/actuallymentor/onion-poap/main/setup.sh | sudo bash
```

If you want to inspect the file locally, you can:

```
git clone https://github.com/actuallymentor/onion-poap.git
cd onion-poap
cat setup.sh
sudo bash setup.sh
```

### Step 3: Tweet your node IP to @actuallymentor

The final step in the setup script will send you a recommended message.

### Step 4: keep it running for a month

After a month, the POAPs will de distributed through poap.delivery.
