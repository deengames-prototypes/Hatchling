# Hatchling

Hatchling is a pure Ruby roguelike library. It provides some useful functionality for creating roguelikes, including:

- Unified display (+colour) across platforms (Windows/Linux)
- Entity/component system
- Event-based message system
- Data-driven architecture

# Quick-Start Guide

For a reference working game, please take a look at [Planetoid](https://github.com/deengames/Hatchling). If you want to contribute, please read the [[Contributer's Guide]].

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

Like many entity-component systems, your basic `Entity` class is simply a conglomerate of `Component` instances. You can pass them into the constructor, like so:

```
monster = Entity.new({
	:display => DisplayComponent.new(...),
	:battle => BattleComponent.new(...)
})
```

Components are referenced by key, which is used to fetch or check for components:

```
monster.get(:display) # returns DisplayComponent instance
monster.has?(:battle) # returns true
monster.has?(:input) # returns false
```

These are used in systems, which encapsulate all of the default behaviour (more on that below).

### Core Components

Hatchling currently ships with the current components:

- **DisplayComponent:** Contains a position (x/y) and appearance (character/color)
- **InputComponent:** Can respond to keyboard input and call arbitrary code.
- **BattleComponent:** Contains useful stats for combat (strength and speed, for example)
- **HealthComponent:** Has maximum/current health statistics, and useful functions like `is_alive?`

Note: unlike other entity/component systems, components are actually *classes with their own functions.* This makes it easier to rebuild, reuse, and test components.

All components extend the `BaseComponent` class, which contains common functionality, such as referencing the parent entity via `c.entity`, and events.

### Defining the Player

The player is a normal entity, with a couple of special properties:
- It has a `name` component set to the value `'Player'`
- The `InputSystem` moves the `Player` around on key-press

### Systems

Hatchling comes with the current systems. You currently **cannot subclass, override or otherwise customize these** without changing the source (feel free to do that).

- **Display System:** Handles screen drawing (entities, messages, etc.) efficiently (only draw whatever changed)
- **Input System:** Input handling
- **Battle System:** Give entities with a `BattleComponent` turns and facilitate moving
- **Event System:** Used to handle event broadcasts (see events section below).

### Custom Components

You can create your own components and add them to entities as you wish; just make sure you extend `BaseComponent` so that you can reference the parent entity.

## Communicating via Events

Components within the same entity, and across entities, can communicate with each other (and entities with other entities) via events. To trigger an event:

```
b = BaseComponent.new
b.bind('Calculated PI', lambda { |data|
	raise "PI is actually #{data}"
})

EventSystem.trigger('Calculated PI', 3.14159)
```

In this example, we use a `BaseComponent` instance (for illustrative means only). In practice, you'll use other components (including your own custom ones).

This event will be broadcast to all components in the game.

## Battle
- Create a `Battler` class
- Make a `resolve_attacks(attacks)` method
    - Takes an array of {:attacker => ..., :target => ...} (entities)
    - Returns `{:messages => [m1, m2, ...]}` (an array of messages for the UI)

You make your own batler, with your own rules. If you want to use a default (generic) battler, here's one that uses only core components (`BattleComponent`, `HealthComponent`) for simple damage calculation (`attack - defense`):

```
require 'hatchling'
require_relative 'monster'

include Hatchling

class Battler
	def resolve_attacks(attacks)
		messages = []		
		
		attacks.each do |a|
			attacker = a[:attacker]
			target = a[:target]
						
			damage = attacker.get(:battle).strength
			health = target.get(:health)			
			health.get_hurt(damage) if damage > 0
									
			message = "#{attacker.name} attacks #{target.name} for #{damage} damage!"
			message += " #{target.name} dies!" if !health.is_alive?
			messages << message
		end
		return {:messages => messages}
	end
end
```
