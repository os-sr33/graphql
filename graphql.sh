#!/bin/bash

# Check if the domain is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi


domain=$1

# Define common GraphQL endpoint paths to check
graphql_endpoints=("/graphql" "/graphiql" "/playground" "/api/graphql" "/v1/graphql" "/v2/graphql" "/api/v1/graphql")

# Step 1: Fetch subdomains using subfinder (or another tool)
echo "[+] Enumerating subdomains for $domain..."
subfinder -d $domain -silent | tee subdomains.txt

# Step 2: Use httpx to check for GraphQL-related endpoints returning 200 status
echo "[+] Checking for GraphQL endpoints..."

# Check if httpx is installed
if ! command -v httpx &> /dev/null
then
    echo "httpx could not be found. Please install it first."
    exit 1
fi

# Loop through each subdomain and check each common GraphQL endpoint
while read -r subdomain; do
    for endpoint in "${graphql_endpoints[@]}"; do
        echo "[*] Checking $subdomain$endpoint"
        httpx -silent -status-code -path "$endpoint" -no-color -target "$subdomain" | grep -E "200"
    done
done < subdomains.txt

echo "[+] Done checking for GraphQL endpoints."
