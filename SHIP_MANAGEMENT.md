# Ship Management System

## Overview
The ship management system allows faction owners to upgrade their ships with various systems that enhance combat capabilities and survivability.

## How to Use

### Opening the Ship Screen
- **Right-click** on a ship you own to open the ship management screen
- Only the owning faction can access the ship screen during their turn
- Non-owners will see "You don't control this ship" message

### Ship Systems

Each ship can be upgraded with three types of systems:

#### 1. Defence/Shield Systems (Cost: 40 energy)
- Increases ship shield strength
- Each defence level adds: +15 shield strength
- Shields contribute to combat strength and survival chance
- Protects your ship during battles

#### 2. Weapon Systems (Cost: 50 energy)
- Increases ship attack power
- Base attack: 10
- Each weapon level adds: +8 attack power
- Higher attack = better chance to win battles

#### 3. Energy Systems (Cost: 35 energy)
- Increases ship energy capacity
- Base capacity: 100 energy
- Each energy system adds: +20 max capacity
- More energy per turn: +3 energy/turn per system
- Allows more upgrades to be installed

## Combat System

### Combat Strength Calculation
```
Combat Strength = Attack Power + (Shield Strength / 2)
```

### Battle Resolution
- When ships engage in combat, their combat strengths are compared
- Attacker strength vs Defender strength + Planet defences
- Higher strength = better chance of winning
- Winner keeps their ship, loser is destroyed

Example:
- Attacker: 26 combat strength (18 attack + 4 shields)
- Defender: 40 combat strength (10 attack + 15 shields + 20 planet defence)
- Attacker has 26/(26+40) = 39% chance to win

## Resource Management

### Energy
- Ships start with 100 energy
- Energy recharges each turn: 5 base + (energy systems × 3)
- Spend energy to install systems
- Manage resources wisely for long-term upgrades

### Turn Processing
- All ships recharge energy at the start of their faction's turn
- Energy accumulates up to maximum capacity
- Plan upgrades based on available energy

## Strategic Considerations

### Ship Roles
1. **Tank Ships**: Heavy defence systems, absorb damage
2. **Attack Ships**: Maximum weapon systems, high damage
3. **Balanced Ships**: Mix of defence and weapons
4. **Support Ships**: Energy-focused for future upgrades

### Upgrade Priority
- **Early game**: Add 1-2 energy systems for sustainable growth
- **Border ships**: Balance weapons and defence
- **Offensive ships**: Prioritize weapons for conquest
- **Defensive ships**: Heavy shields on home planets

### Combat Tips
- Upgraded ships have significant advantages in battle
- Planet defences stack with ship defences when defending
- Attack power is more valuable on offense
- Shield strength provides defensive bonuses

## Integration with Game Systems

### Planet Interaction
- Ship defences combine with planet defence systems
- Defending on a fortified planet gives major advantages
- Capture planets to expand your territory

### Battle Flow
1. Attacker moves to enemy-occupied planet
2. Combat is automatically resolved on arrival
3. Strengths are compared (including planet bonuses)
4. Winner determined, loser destroyed
5. Attacker captures planet if victorious

## UI Controls
- **Add System buttons**: Install upgrades (disabled if insufficient energy)
- **Return to Galaxy Map**: Close ship screen and return to main view
- **Status display**: Shows current energy, systems, and combat stats
- **Combat strength indicator**: Shows total combat effectiveness

## Future Enhancements
- Special weapons and abilities
- Ship classes with unique bonuses
- Experience and veteran bonuses
- Fleet formations and tactics
- Ship repair and maintenance systems
