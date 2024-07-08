# Plotlix

A simple LiveView application for creating and sharing [Plotly](https://plotly.com) diagrams.

Requirements are described [here](Technical%20Assignment%20Full-Stack%20Dev.pdf).

## Installation

This application depends on:
- Erlang and Elixir (can be installed with [asdf](https://asdf-vm.com/guide/getting-started.html)),
- Postgres running locally.

To start the project:

  * Run `mix setup` to install and set up dependencies,
  * start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Dev mailbox
If you need to verify emails after changing the user password in the development environment, go to [`/dev/mailbox`](http://localhost:4000/dev/mailbox).
