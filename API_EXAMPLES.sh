#!/bin/bash
# Example API calls for iOS VoIP Server
# Usage: Run server with `npm run dev` then use these commands

echo "VoIP Notification Server - API Examples"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if server is running
echo -e "${BLUE}Checking server health...${NC}"
curl -s http://localhost:3000/health | jq '.' || echo "Server not running. Start with: npm run dev"
echo ""

# Example 1: Register a token
echo -e "${BLUE}[Example 1] Register a device token${NC}"
echo "Command:"
echo 'curl -X POST http://localhost:3000/register-token \'
echo '  -H "Content-Type: application/json" \'
echo '  -d '"'"'{"token":"your-device-token-here"}'"'"
echo ""

# Example 2: Get all tokens
echo -e "${BLUE}[Example 2] Get all registered tokens${NC}"
echo "Command:"
echo "curl http://localhost:3000/tokens"
echo ""
echo "Response:"
curl -s http://localhost:3000/tokens | jq '.' || echo "(No response - server may not be running)"
echo ""

# Example 3: Send notification to specific token
echo -e "${BLUE}[Example 3] Send notification to specific device${NC}"
echo "Command:"
echo 'curl -X POST http://localhost:3000/send-to-token \'
echo '  -H "Content-Type: application/json" \'
echo '  -d '"'"'{"token":"device-token","title":"Call","body":"Incoming call"}'"'"
echo ""

# Example 4: Send to all devices
echo -e "${BLUE}[Example 4] Send to all registered devices${NC}"
echo "Command:"
echo 'curl -X POST http://localhost:3000/send-notification \'
echo '  -H "Content-Type: application/json" \'
echo '  -d '"'"'{"title":"Alert","body":"Message to all"}'"'"
echo ""

# Example 5: Full workflow
echo -e "${BLUE}[Example 5] Complete workflow${NC}"
echo "Step 1: Get device token from Flutter app UI"
echo ""
echo "Step 2: Register token"
echo "DEVICE_TOKEN=\"paste-device-token-here\""
echo 'curl -X POST http://localhost:3000/register-token \'
echo '  -H "Content-Type: application/json" \'
echo '  -d "{\"token\":\"$DEVICE_TOKEN\"}"'
echo ""
echo "Step 3: Send notification"
echo 'curl -X POST http://localhost:3000/send-to-token \'
echo '  -H "Content-Type: application/json" \'
echo '  -d "{\"token\":\"$DEVICE_TOKEN\",\"title\":\"VoIP Call\",\"body\":\"Incoming call from Server\"}"'
echo ""
echo "Step 4: Check server logs for confirmation"
echo ""

echo -e "${GREEN}Copy and paste these commands in your terminal${NC}"
