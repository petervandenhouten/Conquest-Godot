# Battle System

## Overview
The battle system provides an interactive, full-screen combat interface when ships from different factions meet at a planet. Players can strategically allocate energy to shields and weapons to influence battle outcomes.

## How Battles Work

### Battle Initiation
1. A ship moves to a planet occupied by an enemy ship
2. Ship travels along the lane to the planet
3. Upon arrival, the battle screen automatically opens
4. Both players (if human) can allocate energy for combat

### Battle Screen Layout
- **Full-screen interface** with planet surface and sky background
- **Defender ship** shown at bottom-left corner (stationary)
- **Attacker ship** shown at top-right corner (arriving)
- **Control panels** for each human player
- **Result display** showing battle outcome

## Energy Allocation

### For Human Players
When a human player is involved in battle, they can allocate their ship's current energy:

#### Shield Allocation
- Increases defensive capability during battle
- 10 energy = +5 shield strength bonus
- Higher shields improve survival chance

#### Weapon Allocation
- Increases offensive capability during battle
- 10 energy = +5 attack power bonus
- Higher weapons improve winning chance

#### Constraints
- Total allocation cannot exceed current ship energy
- Energy spent is consumed regardless of battle outcome
- Must confirm allocation to proceed

### For AI Players
AI players automatically allocate energy:
- **Attacker AI**: 60% weapons, 40% shields (offensive stance)
- **Defender AI**: 60% shields, 40% weapons (defensive stance)

## Combat Resolution

### Combat Strength Calculation
```
Base Ship Attack = ship_manager.attack_power
Base Ship Shield = ship_manager.shield_strength

Allocated Attack Bonus = (weapon_energy / 10) * 5
Allocated Shield Bonus = (shield_energy / 10) * 5

Total Attack = Base Attack + Allocated Attack Bonus
Total Shield = Base Shield + Allocated Shield Bonus + Planet Defence (defender only)

Combat Strength = Attack + (Shield / 2)
```

### Battle Outcome
1. Compare attacker strength vs defender strength
2. Calculate win probability: `attacker_strength / (attacker_strength + defender_strength)`
3. Random roll determines winner
4. Winner keeps their ship, loser's ship is destroyed
5. Attacker captures planet if victorious

### Example Battle
```
Attacker:
- Base: 18 attack, 30 shields
- Allocates: 40 energy to weapons, 20 to shields
- Total: 38 attack, 40 shields
- Strength: 38 + (40/2) = 58

Defender:
- Base: 10 attack, 15 shields
- Planet defence: +20
- Allocates: 20 energy to weapons, 30 to shields
- Total: 20 attack, 50 shields
- Strength: 20 + (50/2) = 45

Win chance: 58/(58+45) = 56.3% for attacker
```

## Strategic Considerations

### Attacker Strategy
1. **All-in assault**: Max weapons for quick victory
2. **Balanced approach**: Split energy 60/40 weapons/shields
3. **Cautious attack**: Higher shields if enemy is strong
4. **Energy conservation**: Minimal allocation if overwhelming advantage

### Defender Strategy
1. **Fortress defense**: Max shields + planet bonus
2. **Counter-attack**: High weapons to eliminate threat
3. **Balanced defense**: Utilize planet bonus with shields
4. **Energy saving**: Low allocation if victory unlikely

### When to Invest Energy
- **High-value targets**: Spend more to capture important planets
- **Close matchups**: Energy allocation can tip the balance
- **Clear advantages**: Save energy when strength difference is large
- **Multiple battles**: Conserve energy for subsequent engagements

## Planet Defence Integration
- Defender automatically receives planet defence bonus
- Defence systems built on planet add to defender's shield
- Encourages fortifying border planets
- Makes attacking fortified positions more difficult

## Battle Flow

### Phase 1: Setup
1. Battle manager initializes with attacker, defender, and planet
2. Battle screen displays and shows faction information
3. Ship stats displayed for both sides

### Phase 2: Energy Allocation
1. Human players see control panels with sliders
2. Players adjust shield and weapon energy allocation
3. Live feedback shows total allocation vs available energy
4. Player confirms allocation when ready
5. AI players auto-allocate instantly

### Phase 3: Combat
1. Once both sides confirm (or AI auto-confirms)
2. Combat strengths are calculated
3. Battle is resolved with random roll
4. Results displayed with detailed breakdown

### Phase 4: Resolution
1. Winner announced with combat stats
2. Loser's ship destroyed
3. Planet ownership transfers if attacker wins
4. Continue button returns to galaxy map

## UI Controls

### Allocation Panel (Human Players)
- **Shield Slider**: Adjust energy to shields (0 to max energy)
- **Weapon Slider**: Adjust energy to weapons (0 to max energy)
- **Allocation Display**: Shows current allocation and total
- **Confirm Button**: Lock in allocation (disabled if over budget)

### Result Screen
- **Battle Statistics**: Detailed breakdown of strengths
- **Winner Announcement**: Shows which faction won
- **Continue Button**: Return to galaxy map and execute outcome

## Technical Details

### BattleManager Class
- Manages battle state and phases
- Handles energy allocation validation
- Calculates combat statistics
- Resolves battle outcome
- Manages ship destruction and planet capture

### BattleScreen Class
- Controls UI display and interactions
- Handles player input for energy allocation
- Shows/hides panels based on AI vs human
- Displays results and manages transitions
- Connects battle manager with visual interface

## Integration with Game Systems

### Ship Systems
- Ship upgrades directly affect battle strength
- Energy capacity limits allocation options
- Upgraded ships have significant advantages
- Energy is consumed from ship's reserves

### Planet Systems
- Planet defence systems boost defender
- Encourages strategic planet development
- Captures transfer ownership and facilities
- Home planets worth defending

### Turn System
- Battles occur during active player's turn
- AI battles resolve automatically
- Energy spent is permanent (recharges next turn)
- Ship movement and battle count as actions

## Tips for Players

1. **Build ship energy systems** - More energy = more battle allocation
2. **Fortify border planets** - Defence systems protect your territory
3. **Don't over-commit** - Save energy for multiple engagements
4. **Read the situation** - Adjust allocation based on opponent strength
5. **Upgrade wisely** - Balance attack and defence on ships
6. **Defend smartly** - Use planet bonuses to your advantage

## Future Enhancements
- Animation of ships during combat
- Special abilities and tactics
- Critical hits and misses
- Terrain effects on battles
- Fleet battles with multiple ships
- Retreat and surrender options
