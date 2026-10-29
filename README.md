<!-- PORTFOLIO_STAR_V1 -->
# Linux Diagnostics — Bash & Networking

**Engineering case study — Situation · Task · Action · Result**

### Situation
Linux operators need quick and repeatable signals for system resources and network connectivity.

### Task
Develop a CLI toolkit with understandable output, logging and failure codes.

### Action
Created Bash system, disk and network diagnostic scripts covering input validation, disk threshold detection, DNS/ICMP/TCP checks, timestamped logging and a grading script.

### Result
Repository instructions allow syntax and behavior checks to be reproduced. This is training work, with no claim of production monitoring or cloud rollout.

**Documentation/evidence:** [System information](system-info.sh) · [Disk monitoring](disk-check.sh) · [Network diagnostics](network-check.sh)

> The results above are limited to documented implementation and verification, not inferred performance or production outcomes.

---

## Technical documentation

# DevOps Assignment 1 — Linux, Bash & Networking

## Overview
A Linux diagnostic toolkit written in Bash to collect system
information, monitor disk usage, and perform network checks.

## Requirements
- Linux operating system
- Bash
- Git
- Standard utilities: hostname, id, date, uname, uptime,
  lscpu, nproc, free, df, awk, getent, ping, ip, timeout

## Project Structure
- system-info.sh — Collect system information
- disk-check.sh — Check filesystem usage against a threshold
- network-check.sh — Check DNS, ICMP and TCP connectivity
- logs/ — Store timestamped diagnostic logs
- grade.sh — Instructor's local grading script

## Setup

Clone the repository:

    git clone <repository-url>
    cd devops-assignment-1-linux-bash-networking

Make scripts executable:

    chmod +x system-info.sh disk-check.sh network-check.sh grade.sh

## Usage

Display system information:

    ./system-info.sh

Check disk usage with a threshold:

    ./disk-check.sh 80

Check disk usage for a specific directory:

    ./disk-check.sh 80 /tmp

Check host connectivity:

    ./network-check.sh localhost

Check TCP connectivity:

    ./network-check.sh localhost 22

## Exit Codes
- 0: Successful operation
- 1: Threshold reached, connectivity failure, or runtime failure
- 2: Invalid input

## Logging
Diagnostic operations write timestamped entries to
logs/diagnostic.log.

Generated logs are excluded from Git.

## Testing

Validate Bash syntax:

    bash -n system-info.sh
    bash -n disk-check.sh
    bash -n network-check.sh

Test disk input validation:

    ./disk-check.sh 0
    ./disk-check.sh 101
    ./disk-check.sh abc

Test network input validation:

    ./network-check.sh localhost
    ./network-check.sh localhost 0
    ./network-check.sh localhost 65536
    ./network-check.sh localhost abc

Run the instructor's grader:

    ./grade.sh

## Assumptions and Limitations
- Scripts execute in a Linux environment.
- Disk usage is calculated for the filesystem containing the path.
- ICMP ping may be blocked by firewalls even when TCP works.
- Network checks depend on local network configuration.
- TCP connection tests do not verify application-layer responses.
- System information describes the machine executing the script.

## Version Control
Development uses feature branches merged into main with
meaningful Git commit messages.

## Deployment
No cloud deployment is required for this assignment.
