# FatSecret MCP Server

A Model Context Protocol (MCP) server that provides access to the FatSecret nutrition database API with full 3-Legged OAuth authentication support.

## Features

- Complete OAuth 1.0a implementation (3-legged) for user authentication
- Food database access: search and retrieve detailed nutrition information
- Recipe database: search for recipes and get detailed instructions
- User data: access food diaries and add food entries
- Secure credential handling: tokens signed with HMAC-SHA1 and HTTPS-only API calls

## Contributor Guide

New contributors should read the [Repository Guidelines](AGENTS.md) for project structure, workflows, and review expectations.

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn
- A FatSecret developer account

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/fatsecret-mcp.git
cd fatsecret-mcp

# Install dependencies
npm install

# Build the TypeScript
npm run build
```

## Docker

You can build and run the MCP server in a container. In Docker, the app always uses environment variables only; no configuration file is needed or used inside the container.

### Build the image

```bash
docker build -t fatsecret-mcp:local .
```

### Run with environment variables only

- App credentials only (for public endpoints like search):

```bash
docker run --rm \
  -e CLIENT_ID=your_client_id \
  -e CLIENT_SECRET=your_client_secret \
  fatsecret-mcp:local
```

- With user tokens (for user-specific operations):

```bash
docker run --rm \
  -e CLIENT_ID=your_client_id \
  -e CLIENT_SECRET=your_client_secret \
  -e ACCESS_TOKEN=your_access_token \
  -e ACCESS_TOKEN_SECRET=your_access_token_secret \
  -e USER_ID=optional_user_id \
  fatsecret-mcp:local
```

Note: inside the container, no config file is used. FATSECRET_CONFIG_PATH and volumes are not required.

### Supported environment variables

- CLIENT_ID: FatSecret Client ID (required)
- CLIENT_SECRET: FatSecret Client Secret (required)
- ACCESS_TOKEN: OAuth user access token (optional; required for user-specific tools)
- ACCESS_TOKEN_SECRET: OAuth user access token secret (optional; required for user-specific tools)
- USER_ID: FatSecret user ID (optional)

Tip: You can obtain tokens using the CLI locally, then pass them to the container as environment variables.

### Healthcheck

The image defines a basic healthcheck that reports healthy when the runtime is up. You can also inspect logs or add a custom command if needed.

```bash
docker inspect --format='{{json .State.Health}}' $(docker run -d fatsecret-mcp:local) | jq
```

## Setup

### 1. Get FatSecret API credentials

1. Visit the [FatSecret Platform](https://platform.fatsecret.com/)
2. Create a developer account and register your application
3. Note your Client ID and Client Secret

### 2. Configure the MCP server in your client

Add the server to your MCP client (e.g., Claude Desktop):

```json
{
  "mcpServers": {
    "fatsecret": {
      "command": "node",
      "args": ["path/to/fatsecret-mcp-server/dist/index.js"]
    }
  }
}
```

### 3. Authentication Process

#### Option 1: OAuth Console (CLI) locally

Use the included CLI utility to authenticate interactively on your machine (outside of Docker). When done, the CLI writes a local config file and prints a summary with values and copy-pasteable export commands, so you can run the container entirely with env vars.

```bash
npm run build
node dist/cli.js
```

Flow:
1. Enter Client ID and Client Secret
2. Complete OAuth in the browser and paste the verifier code
3. The CLI saves credentials and prints: CLIENT_ID, CLIENT_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_SECRET, USER_ID, with export commands you can copy

#### Option 2: Authentication via MCP tools

You can perform OAuth via MCP tools (e.g., in Claude). Once you have tokens, provide them to Docker using env vars.

#### Option 3: Environment variables locally

You can also use a `.env` file locally with CLIENT_ID and CLIENT_SECRET (and tokens if available). The server/CLI loads these variables automatically if present.

## Usage

### 1. Set API credentials

Use the `set_credentials` tool with your Client ID and Client Secret.

### 2. Authenticate a user (3-legged OAuth)

For user-specific operations, complete the OAuth flow (via CLI or tools). In Docker, pass tokens as env vars.

### 3. Use the API

Once authenticated, you can use all available tools.

## Available Tools

### Authentication Tools

#### `set_credentials`

Set your FatSecret API credentials.

Parameters:
- clientId (string, required)
- clientSecret (string, required)

#### `start_oauth_flow`

Start the 3-legged OAuth flow.

Parameters:
- callbackUrl (string, optional; default: "oob")

#### `complete_oauth_flow`

Complete the OAuth flow with authorization.

Parameters:
- requestToken (string, required)
- requestTokenSecret (string, required)
- verifier (string, required)

#### `check_auth_status`

Check current authentication status.

### Food Database Tools

#### `search_foods`

Search for foods in the FatSecret database.

Parameters:
- searchExpression (string, required)
- pageNumber (number, optional; default: 0)
- maxResults (number, optional; default: 20)

#### `get_food`

Get detailed information about a specific food.

Parameters:
- foodId (string, required)

### Recipe Database Tools

#### `search_recipes`

Search for recipes in the FatSecret database.

Parameters:
- searchExpression (string, required)
- pageNumber (number, optional; default: 0)
- maxResults (number, optional; default: 20)

#### `get_recipe`

Get detailed information about a specific recipe.

Parameters:
- recipeId (string, required)

### User Data Tools (Requires Authentication)

#### `get_user_profile`

Get the authenticated user's profile information.

#### `get_user_food_entries`

Get user's food diary entries for a specific date.

Parameters:
- date (string, optional; YYYY-MM-DD, default: today)

#### `add_food_entry`

Add a food entry to the user's diary.

Parameters:
- foodId (string, required)
- servingId (string, required)
- quantity (number, required)
- mealType (string, required: breakfast, lunch, dinner, snack)
- date (string, optional; YYYY-MM-DD, default: today)

## Example Workflow

1. Setup credentials

   Tool: set_credentials
   - clientId: "your_client_id"
   - clientSecret: "your_client_secret"

2. Search for foods

   Tool: search_foods
   - searchExpression: "chicken breast"

3. Get food details

   Tool: get_food
   - foodId: "12345"

4. Authenticate user (if needed)

   Tool: start_oauth_flow
   - callbackUrl: "oob"

   Then:

   Tool: complete_oauth_flow
   - requestToken: "from_start_oauth_flow"
   - requestTokenSecret: "from_start_oauth_flow"
   - verifier: "from_authorization_page"

5. Add food to diary

   Tool: add_food_entry
   - foodId: "12345"
   - servingId: "67890"
   - quantity: 1
   - mealType: "lunch"

## Configuration Storage

- Local (non-Docker) runs: the server saves configuration/tokens to `~/.fatsecret-mcp-config.json`.
- Docker: no file is used; configuration is passed only via environment variables.

## Security Notes

- Credentials are handled locally and tokens are properly signed using HMAC-SHA1
- All API communications use HTTPS

## API Reference

This server talks to the FatSecret Platform API. See:

- [FatSecret Platform API Documentation](https://platform.fatsecret.com/docs/guides)
- [OAuth 1.0a Specification](https://tools.ietf.org/html/rfc5849)

## Error Handling

The server provides detailed error messages for common issues:

- Missing or invalid credentials
- OAuth flow errors
- API rate limiting
- Network connectivity issues
- Invalid parameters

## Testing

### Testing from the command line

Utilities included in `utils/`:

1) Interactive test tool

```bash
node utils/test-interactive.js
```

2) Date conversion test

```bash
node utils/test-date-conversion.js
```

3) Direct JSON-RPC testing

```bash
node utils/test-mcp.js | node dist/index.js
```

### Testing in Claude Desktop

1. Restart Claude Desktop after configuring the MCP server
2. Look for "fatsecret" in the available tools
3. Start with `check_auth_status` to verify the connection

## Troubleshooting

- In Docker, pass user tokens via environment variables to use user-specific tools.
- If you see "User authentication required", complete OAuth (CLI or tools) and re-run with ACCESS_TOKEN and ACCESS_TOKEN_SECRET set in the container.

## Development

```bash
# Install dependencies
npm install

# Build and run
npm run build
npm start

# Development mode with quick rebuild
npm run dev
```

### Project Structure

```
fatsecret-mcp/
├── src/
│   ├── index.ts        # Main MCP server implementation
│   └── cli.ts          # OAuth console utility
├── dist/               # Compiled JavaScript files
├── utils/              # Test utilities
├── package.json
├── tsconfig.json
└── README.md
```

## License

MIT License - see LICENSE file for details.
