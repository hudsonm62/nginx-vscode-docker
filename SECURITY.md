# Security Policy

## Introduction

This document outlines the security policy for the VS Code Server / NGINX Docker Image project. Our project focuses on providing Dockerfiles for building Docker images. We strive to maintain the security of these Dockerfiles to the best of our abilities. It's crucial to understand that our scope is limited to maintaining the Dockerfile itself, and that we have limited control over the security of the base images or the software included in these images.

## Supported Versions

Users are encouraged to use the most recent versions of the Docker Images and Dockerfile's to benefit from the latest updates and security enhancements.

## Reporting a Vulnerability

Our capacity to address vulnerabilities is limited to updating our Dockerfiles. If you discover a vulnerability, please consider the following:

1. **Vulnerabilities in Base Images or Included Software**: If the vulnerability is related to the base images or software included in our Dockerfiles, it is more effective to report these directly to the maintainers of those projects.

2. **Vulnerabilities in Our Dockerfiles**: If you believe the vulnerability is directly related to our Dockerfile configurations, please report it by opening an issue in our GitHub repository.

3. **Response**: We will review reports related to our Dockerfiles and update them as necessary. However, please note that our ability to fix certain vulnerabilities is dependent on the updates and fixes provided by the upstream maintainers of the base images and software.

## Our Commitment

We commit to:

- Regularly reviewing and updating our Dockerfiles with the latest versions of base images and software.
- Providing guidance on security best practices related to our Dockerfiles where possible.

## Disclaimer

The Dockerfiles are provided "as is," without warranty of any kind. We are not responsible for damages or security breaches that occur as a result of vulnerabilities in the base images or the included software.
Users should remain vigilant and ensure their deployments are secure by using up-to-date images and following security best practices.

> Check the [README.md](README.md) for a list of tips to assist in securing your deployment of this image.
