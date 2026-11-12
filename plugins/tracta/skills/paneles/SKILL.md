---
name: paneles
description: Use when the user wants a live panel, dashboard or report over their Tracta account — deals by stage, chats waiting for a person, follow-ups due, a manager's view — built as a claude.ai artifact that reads the Tracta connector each time someone opens it. Triggers include "arma un panel", "un dashboard de mis ventas", "quiero ver mis deals por etapa", "panel para gerencia", "qué chats esperan", "reporte en vivo", "build me a dashboard of my Tracta pipeline".
---

# Paneles en vivo sobre Tracta

A panel is a claude.ai artifact whose numbers come from the user's Tracta connector **every time someone
opens it**: no export, no copy of the data, no new endpoint. It runs with the access of whoever opens it,
so a teammate with the `agent` role sees only their own deals, and someone without the connector sees
nothing.

## Before you build

1. **The connector must be on claude.ai.** The page calls the user's claude.ai connector by its display
   name (the one they gave it in Settings → Connectors, often "Tracta" or "Fovente"). A Tracta MCP that
   only your Claude Code session has is not reachable from the page. If it is missing, ask them to add
   `https://mcp.coresponde.com/mcp` as a connector in claude.ai first.
2. **Know which account it reads.** Call `tenant_info` once and say the account name back. A user with
   several accounts sees the one their connector is on.
3. **Learn the shapes from one real read**, never from memory. All of these only read:
   - `deals_list({limit: 100, include_closed: false})` → `{items: [...], has_more, next_cursor}`;
     `amount` is text ("699.00"), with `currency`.
   - `pipeline_config_get()` → `{stages: [{key, label, kind}]}`; `kind` is `abierta`, `ganada`,
     `activa`, `completada` or `perdida`. Use the account's own `label`s, never hard-coded stage names.
   - `conversations_list({needs_reply: true, ai_paused: true})` and
     `conversations_list({needs_reply: true, status: "escalated"})` → the chats waiting for a person.
   - `metrics_get({since, until})` → conversation and lead totals for a window.
   - `tasks_list(...)` → follow-ups due.

## Building it

- In claude.ai's artifact tool, start from the **Data** (dashboard) type and follow its instructions:
  each source is one live call on the connector, and the page draws what the calls return.
- Every list answer is wrapped (`items`, `stages`): add a loader that returns the rows, and page with
  `next_cursor` up to a ceiling, marking the result as cut when there is more.
- Arithmetic (totals, amounts per stage, hours waiting) goes in a calculation over the sources, so a
  reader can see how each number was made.
- Only read tools. A panel never calls `messages_send`, `deals_update`, `conversations_take` or anything
  that writes: a page's call runs again for every reader.

## Customer data in a panel

A panel shows the business's customers to whoever opens it.

- **Never show phone numbers.** Drop `contact_phone` in the loader, so it isn't even in the rows a
  reader can download.
- **Never show message content.** Who is waiting, why (escalated, AI off) and for how long is enough;
  the conversation is read in the app.
- Contact and deal names are fine for the account's own team. Before the user shares a panel with
  someone outside it (a client's manager, an investor), offer a version with counts and amounts only.
- Say so when you hand it over: it is private until they share it from the page.

## Example

Cofoundy's own guard panel: chats waiting for a person (AI off or escalated, the customer wrote last),
the oldest wait in hours, open deals per stage with the amount in soles. Four sources (`deals_list`,
`pipeline_config_get`, two `conversations_list`) and three calculations; no endpoint was added for it.
