# PyGMTSAR Docker Quick Reference

## Essential Commands

### Build and Run
```bash
# Build image
docker build . -f docker/pygmtsar.Dockerfile -t pygmtsar:latest --no-cache

# Run container
docker run -dp 8888:8888 --name pygmtsar pygmtsar:latest

# Check logs for JupyterLab URL
docker logs pygmtsar
```

### Container Management
```bash
# Start/Stop/Restart
docker start pygmtsar
docker stop pygmtsar
docker restart pygmtsar

# Remove container
docker rm pygmtsar

# Remove image
docker rmi pygmtsar:latest
```

### Monitoring
```bash
# List containers
docker ps -a

# View logs
docker logs pygmtsar

# Resource usage
docker stats pygmtsar

# Execute commands
docker exec -it pygmtsar bash
```

### Data Persistence
```bash
# Run with volume mounts
docker run -dp 8888:8888 \
  -v $(pwd)/data:/home/jovyan/data \
  -v $(pwd)/notebooks:/home/jovyan/notebooks \
  --name pygmtsar pygmtsar:latest
```

### Resource Limits
```bash
# Memory and CPU limits
docker run -dp 8888:8888 \
  --memory=8g \
  --cpus=4 \
  --name pygmtsar pygmtsar:latest
```

### Troubleshooting
```bash
# Clean up Docker
docker system prune -a

# Check port usage
sudo netstat -tulpn | grep :8888

# Interactive debugging
docker run -it pygmtsar:latest bash
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Port 8888 in use | Use different port: `-p 9999:8888` |
| Out of memory | Add `--memory=4g` |
| Build fails | Run `docker system prune -a` |
| Can't access JupyterLab | Check `docker logs pygmtsar` |

## Performance Tips

- **2-4GB RAM**: Use `n_jobs=1` for downloads
- **8GB+ RAM**: Use default settings
- **SSD Storage**: Recommended for better I/O performance
- **Multiple CPUs**: Set `--cpus=$(nproc)` for full utilization
