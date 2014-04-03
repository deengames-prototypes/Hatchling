# Hatchling

Hatchling is a pure Ruby roguelike library. It provides some useful functionality for creating roguelikes, including:

- Unified display (+colour) across platforms (Windows/Linux)
- Entity/component system
- Event-based message system
- Data-driven architecture

# Quick-Start Guide

For a reference working game, please take a look at [Planetoid](https://github.com/deengames/Hatchling).

## Entry Point and Starting Map

For your entry point (I usually call mine `main.rb`), you only need the following code:

```
require 'hatchling'
Hatchling::Game.new.start
```

You'll need to define your [game.json](https://github.com/deengames/Hatchling/wiki/Content-Creation#gamejson) and [town json](https://github.com/deengames/Hatchling/wiki/Content-Creation#map-definition) files

To generate your dungeon, you need to add a [dungeon class](https://github.com/deengames/Hatchling/wiki/Content-Creation#the-dungeon-class). An empty class, with a public `@walls` attribute, will generate an empty dungeon.

Please `require` that before calling `Game.new.start`. For more information, see docs on [the dungeon class](https://github.com/deengames/Hatchling/wiki/Content-Creation#the-dungeon-class).

## Creating Entities and Components

- Base entity class: construction, get component
- Player definition
- Standard components (display, input, battle, health)

## Custom Components

TBD!

## Communicating via Events

- baseComponent.bind to bind
- baseComponent.trigger to initiate
- entity.trigger works, but on all components (no exclusion)
