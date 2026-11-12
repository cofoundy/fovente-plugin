---
name: tracta
description: Use when the user wants to work their Tracta inbox from chat — read or answer WhatsApp/Telegram customer conversations, take over a chat from the AI agent, subscribe to / listen to / watch a conversation and react when the customer writes, manage contacts, deals and follow-up tasks, or edit the Tracta AI agent's scripts and settings. Triggers include "quédate de guardia", "vigila la cuenta", "avísame si alguien escribe", "suscríbete a la conversación", "atiende a X", "escucha la conversa", "avísame cuando responda", "take over this chat", "watch this conversation", "reply to the customer", "Tracta".
---

# Tracta

Tracta is an AI WhatsApp sales agent plus a shared inbox. This plugin connects you to it through the
`tracta` MCP server (OAuth — the user signs in once; every call is scoped to their workspace and role).

MCP tools can load lazily: if you only see tool names, search for them first (e.g. `tracta conversations_take`).

## On guard for the whole account — never poll

When the user asks you to stay on guard, watch the account, or answer whoever writes in a chat without AI,
the tool is **`conversations_wait`**. It blocks until a customer writes in ANY conversation that waits for a
person (its AI is off, or it was escalated) and returns who wrote, in which conversation and what they said.
It takes nothing and turns nothing off; chats where the AI is answering never wake it. Each call returns only
what arrived since your previous call, so nothing is lost between calls.

In Claude Code, run it in the background, never on the main thread:

1. Dispatch `Agent(subagent_type: "tracta:watcher", run_in_background: true, prompt: "mode: account")`.
2. Tell the user, in one line, that you are on guard and the chat stays free.
3. When the watcher wakes you, for each conversation it names: **take the one you are going to attend**
   with `conversations_take(<id>)` (that claims it for you, so two agents never answer the same customer),
   then answer per the rules below (draft and wait for OK, unless the user said to answer on your own).
4. Dispatch a new account watcher right away. Repeat until the user says stop.

## Listening to one conversation in real time — never poll

When the user asks you to subscribe to, listen to, watch or attend a conversation, or to tell them when the
customer answers, the tool is **`conversations_take`**. It blocks until the customer writes and returns the
whole burst of messages as text. There is no webhook to set up and **you must not poll**: no loops, no
`/loop`, no cron, no "I'll check every N minutes" — each poll burns a turn and still arrives late.

**In Claude Code, never call `conversations_take` on the main thread.** It blocks for up to ~4 minutes per
call and the user loses the chat while it waits. Run it in the background through the watcher agent:

1. Resolve the conversation id (`conversations_search` / `conversations_list`). If more than one matches,
   ask which one.
2. Dispatch the watcher in the background:
   `Agent(subagent_type: "tracta:watcher", run_in_background: true, prompt: "conversation_id: con_…")`.
3. Tell the user, in one line, that you are listening and that the chat stays free. Keep working on
   whatever else they ask.
4. When the watcher's notification arrives, read the customer's messages and act:
   - Default: draft a reply and show it to the user; send it with `messages_send` only after they approve.
   - If the user told you to answer on your own ("respóndele tú", "you handle it"), send it directly with
     `messages_send`, then tell them in one line what you sent.
5. Dispatch a new watcher right away so you keep listening. Repeat until the user says stop.
6. If the watcher returns `revoked`, someone else took the conversation: stop listening and say who.

**Other clients (Codex, Cursor, …) have no background agents.** Call `conversations_take` directly and tell
the user it waits until the customer writes. Codex cuts tool calls at 60 s by default; the README explains
how to raise `tool_timeout_sec`.

## What taking a conversation does

- The first `conversations_take` call **turns that conversation's AI agent off** so you and it don't both
  answer, and assigns the thread to the user. Say so when it happens.
- When the user is done, hand it back with `conversations_update(conversation_id, ai_enabled=true)` — ask
  first; don't hand back silently.
- It only affects that one conversation. The AI agent keeps answering every other customer.

## Sending messages — this reaches a real customer

- `messages_send` and `templates_send` deliver to the customer's phone. Never send test text to a real chat.
- WhatsApp only allows free-form messages within 24 h of the customer's last message. Outside that window,
  `messages_send` fails: use an approved template (`templates_list` → `templates_send`).
- Tools are annotated: anything marked destructive (deletes, merges, full overwrites) needs the user's
  explicit OK first.

## Other common jobs

- What's waiting: `conversations_list` (filters for unread / needs reply), then `messages_list` for a thread.
- CRM: `deals_list`, `deals_update`, `tasks_list`, `tasks_complete`.
- The AI agent's knowledge: `scripts_list` → `scripts_get` → `scripts_update_content` (overwrites the whole
  script — read it first and keep what you are not changing).

Docs: https://app.basalt.cofoundy.ai/cofoundy/fovente-public/mcp · Support: info@cofoundy.dev
