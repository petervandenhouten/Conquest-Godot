# Planet Management System

## Overview
The planet management system allows faction owners to develop their planets with various facilities that provide strategic advantages.

## How to Use

### Opening the Planet Screen
- **Right-click** on a planet you own to open the planet management screen
- Only the owning faction can access the planet screen during their turn
- Non-owners will see "You don't control this planet" message

### Planet Facilities

Each planet has four types of facilities you can build:

#### 1. Energy Systems (Cost: 40 energy)
- Increases energy production per turn
- Base production: 10 energy/turn
- Each energy system adds: +5 energy/turn
- Max energy capacity: 100

#### 2. Defence Systems (Cost: 50 energy)
- Increases planet defence strength
- Each defence level adds: +10 defence strength
- Defence bonus in battles: +2% chance per 10 defence points
- Protects your planet from enemy invasions

#### 3. Research Systems (Cost: 60 energy)
- Generates research points per turn
- Each research level adds: +3 research/turn
- (Research system can be extended for technology upgrades)

#### 4. Construction Level (via Energy Systems)
- Automatically increases with energy systems
- Improves overall planet development

## Game Integration

### Battle System
- Defence systems provide a defensive bonus during battles
- Higher defence = better chance to defend against attackers
- Planets can be captured by winning battles

### Turn Processing
- All planets process facilities at the end of each turn
- Energy is generated automatically
- Research points accumulate over time

### Strategic Considerations
1. **Early game**: Build energy systems to fuel expansion
2. **Border planets**: Invest in defence systems
3. **Safe planets**: Focus on research for long-term benefits
4. **Resource management**: Balance spending vs saving energy

## UI Controls
- **Build buttons**: Purchase facilities (disabled if insufficient energy)
- **Return to Galaxy Map**: Close planet screen and return to main view
- **Status display**: Shows current energy, facilities, and production rates

## Future Enhancements
- Construction facilities for building ships
- Technology research tree
- Special buildings and unique planet bonuses
- Planet specialization options
