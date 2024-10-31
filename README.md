# Convergence Cleric Bot Command Guide

### Start Script
- **Command:** `/lua run convcleric`
- **Description:** Starts the Lua script Convergence Cleric.

## General Bot Commands
These commands control general bot functionality, allowing you to start, stop, or save configurations.

### Exit Bot
- **Command:** `/ccExit`
- **Description:** Closes the bot’s GUI, effectively stopping any active commands.

### Enable Bot
- **Command:** `/ccOn`
- **Description:** Activates the bot, enabling it to start running automated functions.

### Disable Bot
- **Command:** `/ccOff`
- **Description:** Stops the bot from performing any actions, effectively pausing its behavior.

### Save Settings
- **Command:** `/ccSave`
- **Description:** Saves the current settings, preserving any configuration changes.

---

### Set Main Assist
- **Command:** `/ccMainAssist`
- **Description:** Sets the main assist for the bot to follow in assisting with attacks.

### Set Assist Range
- **Command:** `/ccAssistRange <value>`
- **Description:** Specifies the distance within which the bot will assist the main assist's target.

### Set Assist Percent
- **Command:** `/ccAssistPercent <value>`
- **Description:** Sets the health percentage of the target at which the bot will begin assisting.

---

## Healing
These commands control various healing modes.

### Toggle Main Heal
- **Command:** `/ccMainHeal`
- **Description:** Enables or disables normal healing for characters.

### Toggle Heal-over-Time (HoT)
- **Command:** `/ccHoT` 
- **Description:** Turns HoT healing on or off.

### Toggle Fast Heal
- **Command:** `/ccFastHeal`
- **Description:** Enables or disables the fast heal option for prioritizing quicker heals.

### Toggle Complete Heal
- **Command:** `/ccCompleteHeal`
- **Description:** Activates or deactivates complete heal, useful for full character recovery.

### Toggle Group Heal
- **Command:** `/ccGroupHeal`
- **Description:** Controls whether the bot will perform group healing.

### Toggle Cure Usage
- **Command:** `/ccCures`
- **Description:** Enables or disables the use of cures during combat.

---

## Group or Raid Buff Control
These commands control who you want to buff.

### Set Buff Group
- **Command:** `/ccBuffGroup`
- **Description:** Enables or disables group buffing for the current group members.

### Set Buff Raid
- **Command:** `/ccBuffRaid`
- **Description:** Enables or disables raid-wide buffing for all raid members.

---

## Buff Commands
These commands control different HP & AC Buffs.

### Toggle Aegis Buff
- **Command:** `/ccAegis`
- **Description:** Activates or deactivates the Aegis buff.

### Toggle Symbol Buff
- **Command:** `/ccSymbol`
- **Description:** Toggles the Symbol buff, which increases health.

### Toggle Shield Buff
- **Command:** `/ccShield`
- **Description:** Enables or disables the Shield buff, which increases AC.

---

## Resistance Buff Commands
These commands control different resistance buffs, protecting characters from various damage types.

### Resist Magic
- **Command:** `/ccResistMagic`
- **Description:** Toggles magic resistance buff.

### Resist Fire
- **Command:** `/ccResistFire`
- **Description:** Toggles fire resistance buff.

### Resist Cold
- **Command:** `/ccResistCold`
- **Description:** Toggles cold resistance buff.

### Resist Disease
- **Command:** `/ccResistDisease`
- **Description:** Toggles disease resistance buff.
  
### Resist Poison
- **Command:** `/ccResistPoison`
- **Description:** Toggles poison resistance buff.

---

## Resurrection Commands
Commands to control resurrection settings for characters.

### Enable Resurrection
- **Command:** `/ccResOn`
- **Description:** Enables automatic resurrection usage.

### Disable Resurrection
- **Command:** `/ccResOff`
- **Description:** Disables automatic resurrection usage.

### Combat Resurrection
- **Command:** `/ccCombatRes`
- **Description:** Toggles the use of resurrection during combat.

### Manual Resurrection
- **Command:** `/ccResCorpse <playerName>`
- **Description:** Manually resurrects the specified player’s corpse, if requirements are met.
- **Usage:** Type `/ccResCorpse <playerName>` where `<playerName>` is the character’s name.
- **Example:** `/ccResCorpse John` will attempt to res the corpse for the character John.

---

## Other Utility Commands
Additional bot features to control epic use, meditating, and specific skills.

### Toggle Use of Epic
- **Command:** `/ccEpic`
- **Description:** Activates or deactivates the use of the Epic item or skill.

### Toggle Sit/Med
- **Command:** `/ccSitMed`
- **Description:** Allows the bot to enter sit/meditate mode for faster mana regeneration.

### Toggle Mark of Karn
- **Command:** `/ccKarn`
- **Description:** Enables or disables the Mark of Karn skill usage.

---

## Slider Commands (Threshold Settings)
Commands to set healing and group heal percentage thresholds.

### Set Main Heal Threshold
- **Command:** `/ccMainHealPct <value>`
- **Description:** Sets the percentage threshold for triggering main healing.
- **Usage:** Type `/ccMainHealPct 50` to set to 50%.

### Set HoT Threshold
- **Command:** `/ccHotPct <value>`
- **Description:** Sets the percentage threshold for triggering HoT healing.
- **Usage:** Type `/ccHotPct 60`.

### Set Fast Heal Threshold
- **Command:** `/ccFastHealPct <value>`
- **Description:** Sets the percentage threshold for fast healing.
- **Usage:** Type `/ccFastHealPct 40`.

### Set Complete Heal Threshold
- **Command:** `/ccCompleteHealPct <value>`
- **Description:** Sets the percentage threshold for complete healing.
- **Usage:** Type `/ccCompleteHealPct 20`.

### Set Group Heal Threshold
- **Command:** `/ccGroupHealPct <value>`
- **Description:** Sets the group healing percentage threshold.
- **Usage:** Type `/ccGroupHealPct 30`.

### Set Group Members to Heal
- **Command:** `/ccGroupHealNumber <value>`
- **Description:** Specifies the number of group members that must be under the heal threshold to trigger group healing.
- **Usage:** Type `/ccGroupHealNumber 3`.

---

## Navigation Commands
Commands to control navigation settings and camping behavior.

### Set Camp Here
- **Command:** `/ccCampHere`
- **Description:** Sets the current location as the camp location.

### Enable Return to Camp
- **Command:** `/ccReturnOn`
- **Description:** Enables automatic return to camp when moving too far.

### Disable Return to Camp
- **Command:** `/ccReturnOff`
- **Description:** Disables automatic return to camp.

### Set Camp Distance
- **Command:** `/ccCampDistance <value>`
- **Description:** Sets the distance limit from camp before auto-return is triggered.
- **Usage:** Type `/ccCampDistance 100`.

### Set Chase Target and Distance
- **Command:** `/ccChase`
- **Description:** Sets a target and distance for the bot to chase.
- **Usage:** Type `/ccChase <target> <distance>` or `/ccChase off`.
- **Example:** `/ccChase John 30` will set the character John as the chase at a distance of 30.
- **Example:** `/ccChase off` will turn chasing off.

---