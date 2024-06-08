#Dockerfile to build image for jenkins slave which can run docker and kubectl commands

FROM jenkins/inbound-agent:alpine

USER root

# Install Docker
RUN apk add --no-cache \
    docker \
    openrc

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Add Jenkins user to docker group
RUN addgroup jenkins docker

USER jenkins

