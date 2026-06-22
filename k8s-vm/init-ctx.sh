#!/bin/bash
vcf context create bank-app --endpoint https://auto-a.site-a.vcf.lab/ --insecure-skip-tls-verify --type cci --auth-type basic --tenant-name acme-east-a --api-token `cat ~/Desktop/vcfa_api_token.txt`
