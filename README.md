version=1.0.0

# Convergence Cleric Bot Command Guide

### Start Script
- **Command:** `/lua run ConvCLR`
- **Description:** Starts the Lua script Convergence Cleric.

## General Bot Commands
These commands control general bot functionality, allowing you to start, stop, or save configurations.

### Exit Bot
- **Command:** `/ConvCLR exit`
- **Description:** Closes the bot’s GUI, effectively stopping any active commands.

### Enable Bot
- **Command:** `/ConvCLR bot on`
- **Description:** Activates the bot, enabling it to start running automated functions.

### Disable Bot
- **Command:** `/ConvCLR bot off`
- **Description:** Stops the bot from performing any actions, effectively pausing its behavior.

### Save Settings
- **Command:** `/ConvCLR save`
- **Description:** Saves the current settings, preserving any configuration changes.

---

### Set Main Assist
- **Command:** `/ConvCLR assist <name>`
- **Description:** Sets the main assist for the bot to follow in assisting with attacks.

### Set Assist Range
- **Command:** `/ConvCLR assistRange <value>`
- **Description:** Specifies the distance within which the bot will assist the main assist's target.

### Set Assist Percent
- **Command:** `/ConvCLR assistPercent <value>`
- **Description:** Sets the health percentage of the target at which the bot will begin assisting.

---

## Healing
These commands control various healing modes.

### Toggle Main Heal
- **Command:** `/ConvCLR mainheal <on|off>`
- **Description:** Enables or disables normal healing for characters.

### Toggle Heal-over-Time (HoT)
- **Command:** `/ConvCLR hot <on|off>` 
- **Description:** Turns HoT healing on or off.

### Toggle Fast Heal
- **Command:** `/ConvCLR fastheal <on|off>`
- **Description:** Enables or disables the fast heal option for prioritizing quicker heals.

### Toggle Complete Heal
- **Command:** `/ConvCLR ch <on|off>`
- **Description:** Activates or deactivates complete heal, useful for full character recovery.

### Toggle Group Heal
- **Command:** `/ConvCLR groupheal <on|off>`
- **Description:** Controls whether the bot will perform group healing.

### Toggle Cure Usage
- **Command:** `/ConvCLR cures <on|off>`
- **Description:** Enables or disables the use of cures during combat.

---

## Group or Raid Buff Control
These commands control who you want to buff.

### Set Buff Group
- **Command:** `/ConvCLR buffgroup <on|off>`
- **Description:** Enables or disables group buffing for the current group members.

### Set Buff Raid
- **Command:** `/ConvCLR buffraid <on|off>`
- **Description:** Enables or disables raid-wide buffing for all raid members.

---

## Buff Commands
These commands control different HP & AC Buffs.

### Toggle Aegis Buff
- **Command:** `/ConvCLR aegis <on|off>`
- **Description:** Activates or deactivates the Aegis buff.

### Toggle Symbol Buff
- **Command:** `/ConvCLR symbol <on|off>`
- **Description:** Toggles the Symbol buff, which increases health.

### Toggle Shield Buff
- **Command:** `/ConvCLR shield <on|off>`
- **Description:** Enables or disables the Shield buff, which increases AC.

---

## Resistance Buff Commands
These commands control different resistance buffs, protecting characters from various damage types.

### Resist Magic
- **Command:** `/ConvCLR buffmagic <on|off>`
- **Description:** Toggles magic resistance buff.

### Resist Fire
- **Command:** `/ConvCLR bufffire <on|off>`
- **Description:** Toggles fire resistance buff.

### Resist Cold
- **Command:** `/ConvCLR buffcold <on|off>`
- **Description:** Toggles cold resistance buff.

### Resist Disease
- **Command:** `/ConvCLR buffdisease <on|off>`
- **Description:** Toggles disease resistance buff.
  
### Resist Poison
- **Command:** `/ConvCLR buffpoison <on|off>`
- **Description:** Toggles poison resistance buff.

---

## Resurrection Commands
Commands to control resurrection settings for characters.

### Enable Resurrection
- **Command:** `/ConvCLR rez on`
- **Description:** Enables automatic resurrection usage.

### Disable Resurrection
- **Command:** `/ConvCLR rez off`
- **Description:** Disables automatic resurrection usage.

### Combat Resurrection
- **Command:** `/ConvCLR combatres <on|off>`
- **Description:** Toggles the use of resurrection during combat.

### Manual Resurrection
- **Command:** `/ConvCLR rescorpse <playerName>`
- **Description:** Manually resurrects the specified player’s corpse, if requirements are met.
- **Usage:** Type `/ConvCLR rescorpse <playerName>` where `<playerName>` is the character’s name.
- **Example:** `/ConvCLR rescorpse John` will attempt to res the corpse for the character John.

---

## Other Utility Commands
Additional bot features to control epic use, meditating, and specific skills.

### Toggle Use of Epic
- **Command:** `/ConvCLR epic <on|off>`
- **Description:** Activates or deactivates the use of the Epic item or skill.

### Toggle Sit/Med
- **Command:** `/ConvCLR sitmed <on|off>`
- **Description:** Allows the bot to enter sit/meditate mode for faster mana regeneration.

### Toggle Mark of Karn
- **Command:** `/ConvCLR karn <on|off>`
- **Description:** Enables or disables the Mark of Karn skill usage.

---

## Slider Commands (Threshold Settings)
Commands to set healing and group heal percentage thresholds.

### Set Main Heal Threshold
- **Command:** `/ConvCLR mainhealpct <value>`
- **Description:** Sets the percentage threshold for triggering main healing.
- **Usage:** Type `/ConvCLR mainhealpct 50` to set to 50%.

### Set HoT Threshold
- **Command:** `/ConvCLR hotpct <value>`
- **Description:** Sets the percentage threshold for triggering HoT healing.
- **Usage:** Type `/ConvCLR hotpct 60`.

### Set Fast Heal Threshold
- **Command:** `/ConvCLR fasthealpct <value>`
- **Description:** Sets the percentage threshold for fast healing.
- **Usage:** Type `/ConvCLR fasthealpct 40`.

### Set Complete Heal Threshold
- **Command:** `/ConvCLR completehealpct <value>`
- **Description:** Sets the percentage threshold for complete healing.
- **Usage:** Type `/ConvCLR completehealpct 20`.

### Set Group Heal Threshold
- **Command:** `/ConvCLR grouphealpct <value>`
- **Description:** Sets the group healing percentage threshold.
- **Usage:** Type `/ConvCLR grouphealpct 30`.

### Set Group Members to Heal
- **Command:** `/ConvCLR grouphealnumber <value>`
- **Description:** Specifies the number of group members that must be under the heal threshold to trigger group healing.
- **Usage:** Type `/ConvCLR grouphealnumber 3`.

---

## Navigation Commands
Commands to control navigation settings and camping behavior.

### Set Camp Here
- **Command:** `/ConvCLR camphere <distance|on|off>`
- **Description:** Sets the current location as the camp location, with optional distance.

### Enable Return to Camp
- **Command:** `/ConvCLR camphere on`
- **Description:** Enables automatic return to camp when moving too far.

### Disable Return to Camp
- **Command:** `/ConvCLR camphere off`
- **Description:** Disables automatic return to camp.

### Set Camp Distance
- **Command:** `/ConvCLR camphere <distance>`
- **Description:** Sets the distance limit from camp before auto-return is triggered.
- **Usage:** Type `/ConvCLR camphere 100`.

### Set Chase Target and Distance
- **Command:** `/ConvCLR chase <target> <distance> | on | off`
- **Description:** Sets a target and distance for the bot to chase.
- **Usage:** Type `/ConvCLR chase <target> <distance>` or `/ConvCLR chase off`.
- **Example:** `/ConvCLR chase John 30` will set the character John as the chase target at a distance of 30.
- **Example:** `/ConvCLR chase off` will turn chasing off.

---
