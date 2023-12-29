# VS Code Server / NGINX Docker Image

An Open-VSCode Server proxied via NGINX.

PLAYWITHDOCKERBUTTONHERE?

## Docker Compose

```yaml
version: "3.9"
services:
  openvscode-nginx:
    image: ghcr.io/hudsonm62/nginx-vscode-docker:main # never use `latest`
    container_name: vscode-server
    restart: unless-stopped
    volumes:
      - vscode-config:/config
      - path/to/cert.crt:/etc/nginx/certs/localhost.crt:ro     # cert file name defined in nginx.default.conf
      - path/to/private.key:/etc/nginx/certs/localhost.key:ro  # cert file name defined in nginx.default.conf
      - ./nginx.default.conf:/etc/nginx/conf.d/default.conf:ro # provide your own or update and mount the default one
    ports:
      - "443:443"   # Proxied-HTTPS
      - "80:8080"   # Proxied-HTTP
    # - "3000:3000" # Direct to VS Code
    networks:
      - vscode-net
volumes:
  vscode-config:
networks:
  vscode-dnet:
```

## Why use this instead of [gitpod-io/openvscode-server](https://github.com/gitpod-io/openvscode-server)?

One or more reasons:

1. Proxied over NGINX in 1 container
2. Easy HTTPS/TLS configuration
3. Smaller Image size with [Slim]
4. Rootless nginx base image
5. Options for different base images
6. Relatively simple to customize or manipulate
   1. with a well commented `Dockerfile`
7. Automated weekly rebuilds to stay up to date.
8. Compatible with your existing open-vscode config volume.

## Securing your deployment

Depending on your use case, this is probably an internet facing deployment.
Even if you're only exposing internally- you should still try and check off what you are able to.

Here are a few tips to keep your environment safe:

- Always use the `:main` or `:main-noslim` tags instead of version-specific tags.
  - Base images update for security/vulnerability patches all the time, sometimes multiple times a week.
  - See the `Dockerfile`s in their respective directory for the _current_ exact versions
  - Only use a specific version if the latest `main`s presents an immediate issue.
- [NGINX has a lot good documentation](https://docs.nginx.com/nginx/admin-guide/security-controls/)
- [Run Docker Engine in Rootless Mode](https://docs.docker.com/engine/security/rootless/)
  - This image uses the [nginx-unprivileged](https://hub.docker.com/r/nginxinc/nginx-unprivileged/) base image.
- Use a [Tunnel](https://www.cloudflare.com/products/tunnel/), private [VPN](https://www.cloudflare.com/learning/access-management/what-is-a-vpn/) and/or [external reverse proxy](https://www.cloudflare.com/learning/cdn/glossary/reverse-proxy/) to restrict public access, and only allow communications via TLS.
- Use firewalls and/or ACLs at every level possible (container, host, vm host (if applicable), network, cloudflare or other external proxy)
- Use a separate container for managing your Git CLI and repositories instead of the host, preferably inside a shared Docker volume.
  - With a separate SSH keypair!
  - This allows you to easily trash any existing access or files in a security event.
- Use a separate Docker network if using a stack or cloudflared proxy with unrelated containers.
- Host in the cloud if you don't need any internal access.

## Slimming with [DockerSlim](https://github.com/slimtoolkit/slim)

The command used to slim images:

```shell
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock dslim/slim build \
  --include-bin /home/.openvscode-server/bin --include-path /home/.openvscode-server \
  --include-bin /usr/lib/x86_64-linux-gnu/libutil.so.1 --include-exe git --include-shell \
   customvscode:main
```

This works for me, however depending on use cases or other factors you may need to adjust as needed. This cuts the image down by 3.5x! You can also pull the `:main-noslim` tag and slim it yourself with your own parameters.

The `-noslim` tag is available if you don't want or can't use the [Slim] version - `:main-noslim`. Please report any issues with the slim version.

## Disclaimer

While this image doesn't necessarily fit in with the 1 service 1 container rule, this was created with the pure intention of being able to serve this application over HTTPS from within the same container. There are many reasons why someone might need to do this, consider your own situation and requirements.

[Slim]: https://github.com/slimtoolkit/slim