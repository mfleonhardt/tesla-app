# Requirements

- NodeJS v22
- mkcert

Run `mkcert -install` as root to create a CA on your dev system if you don't already have one.

# Setup

## Generate certificates
Run `./dev-setup.sh` to set up local certificates for your dev environment.

## /etc/hosts entries required for local dev

```
127.0.0.1 [your dev app domain]
127.0.0.1 [your dev api domain]
```
