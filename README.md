# Tracta for Claude Code & Codex

**Run your WhatsApp sales inbox from your AI agent.** Read and answer customer conversations, take a chat
over from the bot, and get woken up the moment a customer writes — without polling loops.

[Tracta](https://fovente.cofoundy.ai) is an AI WhatsApp sales agent and shared inbox for small businesses.
This plugin connects your AI to it in one install:

- **The Tracta MCP server** (OAuth): conversations, messages, contacts, deals, tasks, templates, and your
  AI agent's scripts and settings — scoped to your workspace and role.
- **A skill** that knows how to use it: "atiende a Rosa", "suscríbete a la conversación", "avísame cuando
  responda", "what's waiting for a reply today?".
- **A background watcher agent** (Claude Code): it waits on the conversation while your chat stays free,
  and pings your agent the instant the customer writes. Your agent drafts the reply — or sends it, if you
  told it to — and keeps listening.

## Install

**Claude Code**

```
/plugin marketplace add cofoundy/fovente-plugin
/plugin install fovente@fovente
```

Then run `/mcp`, pick `fovente` and sign in with your Tracta account.

**Codex**

```
codex plugin marketplace add cofoundy/fovente-plugin
```

Install `fovente` from `/plugins` and sign in. Codex stops a tool call after 60 s by default, and listening
to a conversation waits up to ~5 minutes per call. Raise it in `~/.codex/config.toml`:

```toml
[mcp_servers.fovente]
tool_timeout_sec = 330
```

**Any other MCP client:** add `https://mcp.fovente.cofoundy.ai/mcp` (Streamable HTTP, OAuth).

## Try it

> "Show me the conversations waiting for a reply today."
>
> "Atiende la conversación de Rosa: avísame cuando escriba y propónme la respuesta."
>
> "Take over this chat and answer the customer yourself until I say stop."

Taking a conversation turns the AI agent off **for that conversation only** so the two of you don't both
answer; your agent tells you, and hands it back when you're done.

## Requirements

A Tracta account with the agent or admin role. Sending WhatsApp messages needs a connected number.

## Links

[Docs](https://app.basalt.cofoundy.ai/cofoundy/fovente-public/mcp) ·
[Privacy](https://fovente.cofoundy.ai/privacidad) · [Terms](https://fovente.cofoundy.ai/terminos) ·
Support: info@cofoundy.dev

MIT © Cofoundy SAC
