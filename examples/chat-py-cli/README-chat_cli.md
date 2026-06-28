# Chat Python CLI

A lightweight, zero-dependency command-line interface (CLI) written in Python, specifically designed to interact with **Google Vertex AI** via a **LiteLLM** proxy gateway.

This tool provides a fast, native terminal chat experience while seamlessly supporting Vertex AI's built-in Google Search tools directly from your command line.

## Features

- **Zero Dependencies:** Built entirely with Python's standard library (`urllib`, `json`, `argparse`). No need for `pip install requests` or any virtual environments.
- **Vertex AI via LiteLLM:** Optimized to proxy requests to Google Vertex AI using LiteLLM.
- **Built-in Google Search Support:** Natively requests `googleSearch` tool execution, allowing the Vertex model to fetch real-time data and summarize it for you—all handled server-side.
- **Stateful Sessions:** Keeps conversation context in memory while running in interactive mode, acting like a true conversational terminal agent.

## Prerequisites

- Python 3.6+
- A running instance of [LiteLLM](https://github.com/BerriAI/litellm) configured to route traffic to Vertex AI.

## Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/robertluwang/chat-py-cli.git
cd chat-py-cli
chmod +x chat_cli.py
```

## Configuration

The CLI relies on standard environment variables. Because background tasks and **cron jobs do not load `.bashrc` or `.zshrc`**, the recommended best practice is to store your configuration in a dedicated `~/.env` file.

1. **Create a `~/.env` file:**
```bash
# The endpoint where your LiteLLM proxy is running
export LITELLM_URL="http://localhost:4000/v1/chat/completions"

# The master API key for your LiteLLM proxy
export LITELLM_MASTER_KEY="your-sk-key"

# The default model to use (must be mapped in your LiteLLM config)
export LITELLM_MODEL="gemini-pro"
```

2. **For interactive terminal use:**
Add this line to your `~/.bashrc` or `~/.zshrc` so the variables load automatically when you open a terminal:
```bash
source ~/.env
```

3. **For Cron Jobs:**
When scheduling via cron, explicitly source the `.env` file before executing the CLI, because cron runs in a minimal, non-interactive shell:
```bash
0 9 * * * . ~/.env && /absolute/path/to/chat_cli.py "What is the weather in Tokyo?" >> /tmp/weather.log
```

## Usage

### Interactive Mode
Start the CLI to enter an interactive, stateful chat session:
```bash
./chat_cli.py
```
*Type your message and press Enter. The conversation history is maintained for the duration of the session. Type `exit` or `quit` to leave.*

### Single-Prompt (One-Shot) Mode
Pass a prompt directly as an argument for a quick response. Great for cron jobs or quick scripts:
```bash
./chat_cli.py "What is the weather in Tokyo today?"
```

### Overriding the Model
You can override the `LITELLM_MODEL` environment variable on the fly using the `--model` flag:
```bash
./chat_cli.py --model "gemini-flash" "Summarize quantum computing in 3 sentences."
```

## Architecture

For more details on the design principles, zero-dependency architecture, and how tool delegation works, see the [DESIGN.md](./DESIGN.md).