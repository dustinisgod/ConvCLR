# Convergence Cleric Bot Command Guide

### Start Script
- **Command:** `/lua run convcleric`
- **Description:** Starts the Lua script Convergence Cleric.

## General Bot Commands
These commands control general bot functionality, allowing you to start, stop, or save configurations.

### Exit Bot
- **Command:** `/convclr exit`
- **Description:** Closes the bot’s GUI, effectively stopping any active commands.

### Enable Bot
- **Command:** `/convclr bot on`
- **Description:** Activates the bot, enabling it to start running automated functions.

### Disable Bot
- **Command:** `/convclr bot off`
- **Description:** Stops the bot from performing any actions, effectively pausing its behavior.

### Save Settings
- **Command:** `/convclr save`
- **Description:** Saves the current settings, preserving any configuration changes.

---

### Set Main Assist
- **Command:** `/convclr assist <name>`
- **Description:** Sets the main assist for the bot to follow in assisting with attacks.

### Set Assist Range
- **Command:** `/convclr assistRange <value>`
- **Description:** Specifies the distance within which the bot will assist the main assist's target.

### Set Assist Percent
- **Command:** `/convclr assistPercent <value>`
- **Description:** Sets the health percentage of the target at which the bot will begin assisting.

---

## Healing
These commands control various healing modes.

### Toggle Main Heal
- **Command:** `/convclr mainheal <on|off>`
- **Description:** Enables or disables normal healing for characters.

### Toggle Heal-over-Time (HoT)
- **Command:** `/convclr hot <on|off>` 
- **Description:** Turns HoT healing on or off.

### Toggle Fast Heal
- **Command:** `/convclr fastheal <on|off>`
- **Description:** Enables or disables the fast heal option for prioritizing quicker heals.

### Toggle Complete Heal
- **Command:** `/convclr ch <on|off>`
- **Description:** Activates or deactivates complete heal, useful for full character recovery.

### Toggle Group Heal
- **Command:** `/convclr groupheal <on|off>`
- **Description:** Controls whether the bot will perform group healing.

### Toggle Cure Usage
- **Command:** `/convclr cures <on|off>`
- **Description:** Enables or disables the use of cures during combat.

---

## Group or Raid Buff Control
These commands control who you want to buff.

### Set Buff Group
- **Command:** `/convclr buffgroup <on|off>`
- **Description:** Enables or disables group buffing for the current group members.

### Set Buff Raid
- **Command:** `/convclr buffraid <on|off>`
- **Description:** Enables or disables raid-wide buffing for all raid members.

---

## Buff Commands
These commands control different HP & AC Buffs.

### Toggle Aegis Buff
- **Command:** `/convclr aegis <on|off>`
- **Description:** Activates or deactivates the Aegis buff.

### Toggle Symbol Buff
- **Command:** `/convclr symbol <on|off>`
- **Description:** Toggles the Symbol buff, which increases health.

### Toggle Shield Buff
- **Command:** `/convclr shield <on|off>`
- **Description:** Enables or disables the Shield buff, which increases AC.

---

## Resistance Buff Commands
These commands control different resistance buffs, protecting characters from various damage types.

### Resist Magic
- **Command:** `/convclr buffmagic <on|off>`
- **Description:** Toggles magic resistance buff.

### Resist Fire
- **Command:** `/convclr bufffire <on|off>`
- **Description:** Toggles fire resistance buff.

### Resist Cold
- **Command:** `/convclr buffcold <on|off>`
- **Description:** Toggles cold resistance buff.

### Resist Disease
- **Command:** `/convclr buffdisease <on|off>`
- **Description:** Toggles disease resistance buff.
  
### Resist Poison
- **Command:** `/convclr buffpoison <on|off>`
- **Description:** Toggles poison resistance buff.

---

## Resurrection Commands
Commands to control resurrection settings for characters.

### Enable Resurrection
- **Command:** `/convclr rez on`
- **Description:** Enables automatic resurrection usage.

### Disable Resurrection
- **Command:** `/convclr rez off`
- **Description:** Disables automatic resurrection usage.

### Combat Resurrection
- **Command:** `/convclr combatres <on|off>`
- **Description:** Toggles the use of resurrection during combat.

### Manual Resurrection
- **Command:** `/convclr rescorpse <playerName>`
- **Description:** Manually resurrects the specified player’s corpse, if requirements are met.
- **Usage:** Type `/convclr rescorpse <playerName>` where `<playerName>` is the character’s name.
- **Example:** `/convclr rescorpse John` will attempt to res the corpse for the character John.

---

## Other Utility Commands
Additional bot features to control epic use, meditating, and specific skills.

### Toggle Use of Epic
- **Command:** `/convclr epic <on|off>`
- **Description:** Activates or deactivates the use of the Epic item or skill.

### Toggle Sit/Med
- **Command:** `/convclr sitmed <on|off>`
- **Description:** Allows the bot to enter sit/meditate mode for faster mana regeneration.

### Toggle Mark of Karn
- **Command:** `/convclr karn <on|off>`
- **Description:** Enables or disables the Mark of Karn skill usage.

---

## Slider Commands (Threshold Settings)
Commands to set healing and group heal percentage thresholds.

### Set Main Heal Threshold
- **Command:** `/convclr mainhealpct <value>`
- **Description:** Sets the percentage threshold for triggering main healing.
- **Usage:** Type `/convclr mainhealpct 50` to set to 50%.

### Set HoT Threshold
- **Command:** `/convclr hotpct <value>`
- **Description:** Sets the percentage threshold for triggering HoT healing.
- **Usage:** Type `/convclr hotpct 60`.

### Set Fast Heal Threshold
- **Command:** `/convclr fasthealpct <value>`
- **Description:** Sets the percentage threshold for fast healing.
- **Usage:** Type `/convclr fasthealpct 40`.

### Set Complete Heal Threshold
- **Command:** `/convclr completehealpct <value>`
- **Description:** Sets the percentage threshold for complete healing.
- **Usage:** Type `/convclr completehealpct 20`.

### Set Group Heal Threshold
- **Command:** `/convclr grouphealpct <value>`
- **Description:** Sets the group healing percentage threshold.
- **Usage:** Type `/convclr grouphealpct 30`.

### Set Group Members to Heal
- **Command:** `/convclr grouphealnumber <value>`
- **Description:** Specifies the number of group members that must be under the heal threshold to trigger group healing.
- **Usage:** Type `/convclr grouphealnumber 3`.

---

## Navigation Commands
Commands to control navigation settings and camping behavior.

### Set Camp Here
- **Command:** `/convclr camphere <distance|on|off>`
- **Description:** Sets the current location as the camp location, with optional distance.

### Enable Return to Camp
- **Command:** `/convclr camphere on`
- **Description:** Enables automatic return to camp when moving too far.

### Disable Return to Camp
- **Command:** `/convclr camphere off`
- **Description:** Disables automatic return to camp.

### Set Camp Distance
- **Command:** `/convclr camphere <distance>`
- **Description:** Sets the distance limit from camp before auto-return is triggered.
- **Usage:** Type `/convclr camphere 100`.

### Set Chase Target and Distance
- **Command:** `/convclr chase <target> <distance> | on | off`
- **Description:** Sets a target and distance for the bot to chase.
- **Usage:** Type `/convclr chase <target> <distance>` or `/convclr chase off`.
- **Example:** `/convclr chase John 30` will set the character John as the chase target at a distance of 30.
- **Example:** `/convclr chase off` will turn chasing off.

---
