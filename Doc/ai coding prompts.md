# Godot Space Conquest - AI coding prompts

create a new godot 4.6.2 project for a 2D space strategy game
this is the map of the galaxy with the planet. The lines are the possible ways to travel from one planet to another.
introduce a class faction (that contains the name and the colors, and if a faction is humon or computer controlled)

## Turn bases strategy

introduce a turn based system allow all factions to a limited number of  ships moves

## Game initialization

Initialy, all ship should start at the home planet of the faction
Initialy, each faction starts the game with one planet, i.e. their home planet
Select home planets so that there are initialy not connected to other home planets. the requirement is that the distance should be at least two lanes (so home planets are not directly connected)
All factions start with 1 ship.

## Number of ships on a planet

A planet can only contain 1 ship. In the galaxy map, the planet is colored with the color of the occupying faction.
If a planet is occupied by a ship of a faction, another ship of that same faction cannot travel to that planet
If a planet is occupied by a ship of a faction, another ship of another faction can only travel to the planet to start a battle.
When a human player has selected a ship, the travel lanes that are valid options to move will be highligted (e.g. colored yellow and thicker)

## Planet screen

Opens a GUI when a user of the occupying faction clicks on the planet. Other users cannot open this screen.
Shows image of planet surface and sky
Shows energy, defence, research and construction facilities
Owner faction can build defence system(s)
Owner faction can build research system(s)
Owner faction can build energy system(s)
Owner faction can build construction system(s)
Has button to return to galaxy map screen

## Battle screen

Open when a ship arrives at a planet occupied by another faction.
If a ship of a faction arrived on a planet occupied by another faction there will be a battle (see battle screen)
Opens a full screen GUI, showing the surface and sky of the planet as backgound.
Shows the defending ship stationary at the left bottom corner, and the attick ship arriving from the right upper corner.
If the defender is controlled by a human, the user can select to use more energy on shield and defensive systems, or at weapons
If the attacker is controlled by a human, the user can select to use more energy on shield and defensive systems, or at weapons
Only open the GUI then the defender or attacker is a human controlled faction.
If no human controlled faction are involved. Simulate a battle. Only show the result in the planet changed to the color of the faction after the simulated battle.

## Ship screen

Opens a GUI when a user of the occupying faction clicks on the ship. Other users cannot open this screen.
Shows image of the ships and the mounted systems
Shows energy, defence and weapon capabilities of a ship
Owner faction can add defence/shield system(s)
Owner faction can add weapon system(s)
Owner faction can add energy system(s)
