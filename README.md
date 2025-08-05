# Podman Deb Builder

A toolkit for building Podman and its dependencies as Debian packages for Debian-like distro.

## Overview

Podman Debian Builder is a project designed to automate the building of [Podman](https://podman.io/) and its dependencies (conmon, crun, runc) as Debian packages for Debian-like distro. It uses Docker containers to provide a consistent build environment and includes scripts for building, packaging, and uploading the resulting packages to a repository.

## Components

The project builds the following components:

- **Podman** (v5.5.2): A daemonless container engine for developing, managing, and running OCI Containers
- **Conmon** (v2.1.13): A lightweight container monitor for OCI containers
- **Crun** (v1.23.1): A fast and lightweight container runtime for OCI containers
- **Runc** (v1.3.0): A lightweight, portable container runtime

## Requirements

- Docker
- Git
- Bash
- Internet connection (for downloading sources)

## Project Structure

```
podman-deb-builder/
├── docker/               # Docker-related files
│   └── podman-builder.Dockerfile  # Dockerfile for the build environment
├── docs/                 # Documentation
│   └── tasks.md          # Improvement tasks checklist
├── scripts/              # Build and utility scripts
│   ├── build/            # Component-specific build scripts
│   │   ├── conmon.sh     # Script for building conmon
│   │   ├── crun.sh       # Script for building crun
│   │   ├── podman.sh     # Script for building podman
│   │   └── runc.sh       # Script for building runc
│   ├── build_all.sh      # Script to build all components
│   ├── resolve_dependencies.sh  # Script to download dependencies
│   └── upload.sh         # Script to upload packages to a repository
└── .gitlab-ci.yml        # GitLab CI/CD configuration
```

## Build Process

The build process follows these steps:

1. A Docker container is created using the `podman-builder.Dockerfile`
2. The container includes all necessary build dependencies
3. Component build scripts fetch the latest version from GitHub
4. Each component is built and packaged as a Debian package
5. Optionally, dependencies can be downloaded using the `resolve_dependencies.sh` script
6Optionally, packages can be uploaded to a Nexus repository using the `upload.sh` script

## Usage

### Building All Components

```bash
# Clone the repository
git clone https://github.com/yourusername/podman-deb-builder.git
cd podman-deb-builder

# Build the Docker image
docker build -t podman-builder -f docker/podman-builder.Dockerfile .

# Build all components
docker run --rm -v $(pwd)/build_output:/build_output podman-builder bash /src/scripts/build_all.sh
```

### Building a Specific Component

```bash
# Build only podman
docker run --rm -v $(pwd)/build_output:/build_output podman-builder bash /src/scripts/build/podman.sh

# Build only conmon
docker run --rm -v $(pwd)/build_output:/build_output podman-builder bash /src/scripts/build/conmon.sh
```

### Downloading Dependencies

```bash
# Download dependencies
docker run --rm -v $(pwd)/deps:/deps podman-builder bash /src/scripts/resolve_dependencies.sh
```

### Uploading Packages to a Nexus Repository

```bash
# Upload packages to Nexus
bash scripts/upload.sh nexus "https://your-nexus-url" "username" "password" "repository-name"
```

## CI/CD Integration

The project includes a GitLab CI/CD configuration that automates the build, dependency resolution, and upload processes. The pipeline consists of three stages:

1. **Build**: Builds the Podman package
2. **Resolve**: Downloads dependencies
3. **Upload**: Uploads all packages to a Nexus repository

## Contributing

Contributions are welcome! Please see the [tasks.md](docs/tasks.md) file for a list of improvement tasks that need to be addressed.

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Maintainers

- Mohammad Mostafavi <mohammad@Mohammadmostafavi.com>