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

# Logic to check if a user with the specified UID and GID exists, and create/rename accordingly
RUN if getent passwd $UID > /dev/null && getent group $GID > /dev/null; then \
        # If user and group exist, rename the user
        usermod -l $USERNAME -d /home/$USERNAME -m $(getent passwd $UID | cut -d: -f1) && \
        groupmod -n $USERNAME $(getent group $GID | cut -d: -f1); \
    else \
        # If user and group don't exist, create a new user
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
