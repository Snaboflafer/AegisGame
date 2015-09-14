Steven Austin sausti12@jhu.edu
Andrew Shiau ashiau1@jhu.edu
Nathaniel Rhodes nrhodes5@jhu.edu

DEVELOPMENT PLAN

ALPHA
For the Alpha release, air capabilities and the associated preliminary art and musical scores will be completed. This will be for the first tutorial level only, and no ground abilities will be present.

BETA
For the beta release, air and ground capabilities, and the associated art and musical scores will be completed. This is be for the tutorial and first four levels. The total of five levels will be fully functioning at this point. Collision detection will be a key part of this of this release.

GOLD
The GOLD release will be marked by all ten levels completed. All artwork, and musical scores will be fully polished and finalized.

INDIVIDUAL RESPONSIBILITIES
Andrew - Musical score and programming
Nathaniel - Artwork, programming, general creative vision
Andy - Programming
Steven - Project management and programming

POTENTIAL RISKS AND MITIGATIONS
Animations
Considering none of us have significant animation experience, creating a high quality deliverable will be difficult. We plan to take an extremely proactive approach, and reach out to instructors ahead of time for assistance when needed.

Efficient collision detection and game physics
We will have a lot of enemies on the screen, both in the air and on the ground. Thus tracking them efficiently will be difficult. Additionally, having air and land based physics could potentially be a significant amount of work. We will again reach out to instructors early in the process to discuss the best possible approaches.

Graphics inefficiency.
Having graphics as images could potentially be extremely inefficient. We will investigate alternatives to image based graphics.

BACKGROUND STORY
The story will be set  in the relatively near future, keeping the technology and enemies practical. Taking place shortly after the outbreak of war, the protagonist would use the new mech technology to defend against the evil opposing force. The story will be told mainly in pre-stage mission briefings, and via non-player character dialogue overlaid on the screen during levels. 

GAME SETTING
The game setting could be the surface of war torn planet and or space station. The theme of the game is of greater to focus to us and will be reminiscent of classic arcade shooters. The graphics would be 16-bit (limited color palette, x2 pixel scaling.) Audio should be a similar quality. Music would best sound like a MIDI track (as compared to recorded), and effects should be low quality recordings or synthesized sounds. While there will be a classic aesthetic, we can also implement some modern effects (such as particles, physics, pixel shaders, etc.) Given the core mechanic, all levels must feature some sort of ground.

MECHANICS
The game will be styled similarly to those of arcades and 16-bit consoles (e.g. SNES, Genesis). Within the shoot ‘em up genre, it would be a mix between a side-scrolling shooter (e.g. Gradius) and a Run and Gun (e.g. Metal Slug), with an auto-scrolling camera, which constantly moves forward.

The core mechanic would be that the player controls a mech, which could switch between air and ground. In either mode, the player would defeat enemies while advancing towards the end of the level, where they must fight a boss.

When in ground mode, the player would be heavy but well armored, while in air would be fast but relatively weak. To incentivize the player to switch modes, they might only be able to collect powerups and recharge their armor while in the air, but can drop down to the ground to fight tougher enemies. This gives the player choice in how they want to play a level, and at what pace.

CONTROLS:
	WASD for 8 possible directions
	Space to Jump
	Shift to toggle between modes
	Mouse for selecting and shooting target
	
In the air, the player could move in any of the 8 main directions (cardinal and diagonal) On the ground, they will be able to move left and or right on the screen (relative to the constantly moving camera) and jump.

Shooting would be allowed in direction allowed by the mouse. Performance would be measured by points. Defeating enemies would give the player points and powerups (weapon upgrades, health pickups). Progression throughout levels would be linear (that is player starts on Level 1, continues, and does not return to previous stages.). Player health could be measured with distinct values (i.e. 3 to 4 hits) with an additional armor bar while on the ground.

ROUGH LEVELS

Stages would be horizontal, and pre-generated (no procedurally generated). This would include basic platforming, since the screen will be constantly scrolling, and the player should mainly focus on enemies. Levels would have a tilemap theme (e.g. plains, city, factory, etc.), but stage design would mostly be aesthetic.

Basic level progression:

1. The first level is mainly intended to introduce the player to the core ground/air mechanic. Therefore, the enemies would be fairly weak (one or two hits to defeat) and mainly passive (fly around screen, occasionally attacking.) Spaced throughout the level, a commander NPC could give some basic information (e.g. introduce flight and ground mechanic controls). At the end of the level, the player would face his or her first boss. This battle would be used teach the player to fight strong enemies on the ground.

2. After the tutorial level, we will introduce more enemies. New enemies could be either air or land based, although the player can fight from either mode. The majority of enemies would spawn in patterned groups (e.g. Galaga), and fly around screen for a short time until either the player defeats them or camera scrolls past them. Stronger enemies would stay on the screen until defeated.

Stages should take a few minutes each, with a total of ten levels. Since the game is a side-scrolling shooter, levels are less defined by their geometry but the enemies patterns encountered. Early levels would have simple enemies, while later levels would have an increased number with greater capabilities.
