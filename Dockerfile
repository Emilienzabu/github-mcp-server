FROM ghcr.io/github/github-mcp-server:v1.0.0
EXPOSE 8080
CMD ["/server/github-mcp-server", "http", "--port", "8080"]
