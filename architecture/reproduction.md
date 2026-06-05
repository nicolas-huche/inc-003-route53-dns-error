## Overview

This document describes how to manually provision, validate, break, investigate, and restore the INC-003 AWS lab environment.

## Prerequisites

The following resources must be available before starting:

- AWS Account
- Registered Domain
- AWS CLI configured

## Environment Provisioning

### Network Setup

1. Create VPC
2. Create two public subnets in different Availability Zones
3. Create Internet Gateway
4. Attach an Internet Gateway to the VPC
5. Create Route Tables
6. Configure public routing through the Internet Gateway
7. Associate both public subnets with the route table

### Security Group Setup

8. Create a Security Group for the load balancers
9. Allow inbound traffic: TCP 80 and TCP 443
10. Allow outbound traffic: All Traffic
11. Create a Security Group for the instances
12. Allow inbound traffic: TCP 22 and TCP 80
13. Allow outbound traffic: All Traffic

### DNS Setup

14. Create a public hosted zone in Route 53
15. Update the domain registrar configuration to use the Route 53 nameservers assigned to the hosted zone
16. Wait until DNS delegation is fully propagated

### Certificate Setup

17. Request a public ACM certificate for a production subdomain
18. Create the validation records provided by ACM
19. Wait until the certificate status becomes issued
20. Request a public ACM certificate for a staging subdomain
21. Create the validation records provided by ACM
22. Wait until the certificate status becomes issued

### Instances Setup

23. Launch an EC2 instance for the production environment
24. Amazon Linux, public subnet A, instances Security Group
25. Upload [prod.sh](../architecture/user-data/prod.sh) in User Data
26. Launch an EC2 instance for the staging environment
27. Amazon Linux, public subnet B, instances Security Group
28. Upload [staging.sh](../architecture/user-data/staging.sh) in User Data

### Target Groups Setup

29. Create production target group
30. Target Type: Instance, Protocol: HTTP, Port: 80
31. Register production instance
32. Create staging target group
33. Target Type: Instance, Protocol: HTTP, Port: 80
34. Register staging instance

### Load Balancer Setup

35. Create an internet-facing Application Load Balancer for production
36. Internet-facing, IPv4, Two AZs
37. Create listeners: HTTP:80 and HTTPS:443
38. Associate the certificate of production subdomain
39. Forward to production target group
40. Create an internet-facing Application Load Balancer for staging
41. Internet-facing, IPv4, Two AZs
42. Create listeners: HTTP:80 and HTTPS:443
43. Associate the certificate of staging subdomain
44. Forward to staging target group

### DNS Records Setup

45. Create the production DNS record in Route 53
46. Production Subdomain -> Production ALB
47. Record type A
48. Create the staging DNS record in Route 53
49. Staging Subdomain -> Staging ALB
50. Record type A

### Validation

51. Access production subdomain in browser
52. Access staging subdomain in browser

## Failure Injection

Run (failure injection script)

## Investigation and Recovery

See (runbook)

## Teardown

1. Delete the production DNS record from Route 53
2. Delete the staging DNS record from Route 53
3. Delete the production Application Load Balancer
4. Delete the staging Application Load Balancer
5. Delete the production target group
6. Delete the staging target group
7. Terminate the production instance
8. Terminate the staging instance
9. Delete the production ACM certificate
10. Delete the staging ACM certificate
11. Remove any remaining validation records from Route 53
12. Delete the hosted zone from Route 53
13. Delete the load balancer security group
14. Delete the instances security group
15. Disassociate route table associations
16. Delete route table routes created for the lab
17. Delete the route table
18. Detach the Internet Gateway from the VPC
19. Delete the Internet Gateway
20. Delete both public subnets
21. Delete the VPC