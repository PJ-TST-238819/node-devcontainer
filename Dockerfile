# Use an official Node.js image as a base
FROM node:23.3.0-bullseye-slim

# Define build arguments for UID, GID, and USERNAME
ARG UID=1000
ARG GID=1000
ARG USERNAME=dev

# Set a working directory
WORKDIR /workspace

# Install additional packages, including sudo
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Logic to rename or create the user and add to sudo group
RUN if [ "$(id -u node)" = "$UID" ] && [ "$(id -g node)" = "$GID" ]; then \
        usermod -l $USERNAME -d /home/$USERNAME -m node && groupmod -n $USERNAME node; \
    else \
        groupadd -g $GID $USERNAME && useradd -m -u $UID -g $GID $USERNAME; \
    fi && \
    mkdir -p /workspace && chown -R $UID:$GID /workspace && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -aG sudo $USERNAME

# Switch to the new user
USER $USERNAME

# Set Node environment to development by default
ENV NODE_ENV=development

# Expose common Node.js ports
EXPOSE 3000
