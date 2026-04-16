# GitHub MCP Server on Render

A self-hosted deployment of [GitHub's official MCP server](https://github.com/github/github-mcp-server) on Render, giving Claude.ai persistent remote access to GitHub from any device — including mobile. One deployment covers any repository the Personal Access Token has permission to reach.

---

## Prerequisites

- A [Render](https://render.com) account
- A GitHub Personal Access Token (PAT) — fine-grained recommended
- A GitHub repository to host this config (public or private)

---

## Required PAT Scopes

Fine-grained PATs scoped to specific repositories are strongly preferred over classic tokens.

**Minimum for read-only Claude access:**

| Permission | Access |
|---|---|
| `contents` | Read |
| `metadata` | Read |
| `pull_requests` | Read |

**Optional for write access (issues, PRs, code):**

| Permission | Access |
|---|---|
| `contents` | Write |
| `pull_requests` | Write |
| `issues` | Write |

---

## Deploy to Render

1. **Fork or clone this repo** to your GitHub account.

2. **Connect the repo to Render:**
   - Go to [dashboard.render.com](https://dashboard.render.com) → New → Web Service
   - Select "Connect a repository" and pick this repo
   - Render detects `render.yaml` automatically and pre-fills the settings

3. **Set the secret environment variable:**
   - In the Render dashboard go to your service → Environment
   - Add `GITHUB_PERSONAL_ACCESS_TOKEN` with your PAT value
   - Never commit the real token to this file

4. **Deploy** — click "Create Web Service" and wait for the build to complete.

5. **Note your service URL:**
   ```
   https://github-mcp-server.onrender.com
   ```
   (The exact subdomain is assigned by Render; find it in the service dashboard.)

---

## Connector URL

The server runs in **Streamable HTTP** mode (MCP transport spec 2025-03-26). The MCP endpoint is served at the root path.

Paste this URL into Claude.ai:

```
https://your-service-name.onrender.com/
```

Replace `your-service-name` with your actual Render subdomain.

---

## Add to Claude.ai

1. Open [claude.ai](https://claude.ai) → Settings → Integrations
2. Click **Add custom connector** (or "Add MCP server" depending on your plan)
3. Paste your connector URL: `https://your-service-name.onrender.com/`
4. Claude will connect and list available GitHub tools

---

## Transport Details

> **Note:** This server uses the newer **Streamable HTTP** transport (not the older SSE/stdio transports). If Claude.ai reports a connection error, verify your Claude plan supports remote MCP connectors and that the service is awake (first request after a cold start may take ~30 seconds).

The server registers MCP routes at these paths:

| Path | Description |
|---|---|
| `/` | Default MCP endpoint |
| `/readonly` | Read-only tool subset |
| `/insiders` | Experimental tools |
| `/x/{toolset}` | Specific toolset only |

---

## Security Notes

- The PAT is stored only as a Render environment secret — never committed to this repo
- Use a fine-grained PAT scoped to only the repositories Claude needs
- Rotate the PAT periodically; update the value in Render → Environment
- **The Render service URL is effectively a credential** — anyone with the URL can invoke GitHub actions on your behalf. Treat it like a secret and do not share it publicly

---

## Updating the Server Version

To update to a newer release of the GitHub MCP server:

1. Edit `render.yaml` and change the image tag:
   ```yaml
   url: ghcr.io/github/github-mcp-server:vX.Y.Z
   ```
2. Commit and push — Render redeploys automatically.

Available tags: [ghcr.io/github/github-mcp-server](https://github.com/github/github-mcp-server/pkgs/container/github-mcp-server)

---

## Cost

The `render.yaml` uses the **Starter plan** (~$7/month as of writing). The free plan is not suitable because Render free web services sleep after inactivity, causing Claude.ai connection timeouts.

Verify current pricing at [render.com/pricing](https://render.com/pricing).

---

## Local Testing

```bash
cp .env.example .env
# Edit .env and set your real GITHUB_PERSONAL_ACCESS_TOKEN

docker run -i --rm \
  --env-file .env \
  -p 8080:8080 \
  ghcr.io/github/github-mcp-server:v0.33.1 \
  http --port 8080
```

The server will be available at `http://localhost:8080/`.
