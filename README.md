# Convergence Cleric Bot Command Guide

## General Bot Commands
These commands control general bot functionality, allowing you to start, stop, or save configurations.

### Exit Bot
- **Command:** `/ccExit`
- **Description:** Closes the bot’s GUI, effectively stopping any active commands.
- **Usage:** Type `/ccExit` in the command input.

### Enable Bot
- **Command:** `/ccOn`
- **Description:** Activates the bot, enabling it to start running automated functions.
- **Usage:** Type `/ccOn`.

### Disable Bot
- **Command:** `/ccOff`
- **Description:** Stops the bot from performing any actions, effectively pausing its behavior.
- **Usage:** Type `/ccOff`.

### Save Settings
- **Command:** `/ccSave`
- **Description:** Saves the current settings, preserving any configuration changes.
- **Usage:** Type `/ccSave`.

---

## Healing and Buffing Commands
These commands control various healing modes and buff options.

### Toggle Main Heal
- **Command:** `/ccMainHeal`
- **Description:** Enables or disables normal healing for characters.
- **Usage:** Type `/ccMainHeal` to toggle.

### Toggle Heal-over-Time (HoT)
- **Command:** `/ccHoT`
- **Description:** Turns HoT healing on or off.
- **Usage:** Type `/ccHoT` to toggle.

### Toggle Fast Heal
- **Command:** `/ccFastHeal`
- **Description:** Enables or disables the fast heal option for prioritizing quicker heals.
- **Usage:** Type `/ccFastHeal` to toggle.

### Toggle Complete Heal
- **Command:** `/ccCompleteHeal`
- **Description:** Activates or deactivates complete heal, useful for full character recovery.
- **Usage:** Type `/ccCompleteHeal` to toggle.

### Toggle Group Heal
- **Command:** `/ccGroupHeal`
- **Description:** Controls whether the bot will perform group healing.
- **Usage:** Type `/ccGroupHeal` to toggle.

### Toggle Cure Usage
- **Command:** `/ccCures`
- **Description:** Enables or disables the use of cures during combat.
- **Usage:** Type `/ccCures` to toggle.

### Toggle Aegis Buff
- **Command:** `/ccAegis`
- **Description:** Activates or deactivates the Aegis buff.
- **Usage:** Type `/ccAegis` to toggle.

### Toggle Symbol Buff
- **Command:** `/ccSymbol`
- **Description:** Toggles the Symbol buff, which increases health.
- **Usage:** Type `/ccSymbol` to toggle.

### Toggle Shield Buff
- **Command:** `/ccShield`
- **Description:** Enables or disables the Shield buff, which increases AC.
- **Usage:** Type `/ccShield` to toggle.

---

## Resistance Buff Commands
These commands control different resistance buffs, protecting characters from various damage types.

### Resist Magic
- **Command:** `/ccResistMagic`
- **Description:** Toggles magic resistance buff.
- **Usage:** Type `/ccResistMagic` to toggle.

### Resist Fire
- **Command:** `/ccResistFire`
- **Description:** Toggles fire resistance buff.
- **Usage:** Type `/ccResistFire` to toggle.

### Resist Cold
- **Command:** `/ccResistCold`
- **Description:** Toggles cold resistance buff.
- **Usage:** Type `/ccResistCold` to toggle.

### Resist Disease
- **Command:** `/ccResistDisease`
- **Description:** Toggles disease resistance buff.
- **Usage:** Type `/ccResistDisease` to toggle.

### Resist Poison
- **Command:** `/ccResistPoison`
- **Description:** Toggles poison resistance buff.
- **Usage:** Type `/ccResistPoison` to toggle.

---

## Resurrection Commands
Commands to control resurrection settings for characters.

### Enable Resurrection
- **Command:** `/ccResOn`
- **Description:** Enables automatic resurrection usage.
- **Usage:** Type `/ccResOn`.

### Disable Resurrection
- **Command:** `/ccResOff`
- **Description:** Disables automatic resurrection usage.
- **Usage:** Type `/ccResOff`.

### Combat Resurrection
- **Command:** `/ccCombatRes`
- **Description:** Toggles the use of resurrection during combat.
- **Usage:** Type `/ccCombatRes` to toggle.

### Manual Resurrection
- **Command:** `/ccResCorpse <playerName>`
- **Description:** Manually resurrects the specified player’s corpse, if requirements are met.
- **Usage:** Type `/ccResCorpse <playerName>` where `<playerName>` is the character’s name.

---

## Other Utility Commands
Additional bot features to control epic use, meditating, and specific skills.

### Toggle Use of Epic
- **Command:** `/ccEpic`
- **Description:** Activates or deactivates the use of the Epic item or skill.
- **Usage:** Type `/ccEpic` to toggle.

### Toggle Sit/Med
- **Command:** `/ccSitMed`
- **Description:** Allows the bot to enter sit/meditate mode for faster mana regeneration.
- **Usage:** Type `/ccSitMed` to toggle.

### Toggle Mark of Karn
- **Command:** `/ccKarn`
- **Description:** Enables or disables the Mark of Karn skill usage.
- **Usage:** Type `/ccKarn` to toggle.

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
- **Usage:** Type `/ccCampHere`.

### Enable Return to Camp
- **Command:** `/ccReturnOn`
- **Description:** Enables automatic return to camp when moving too far.
- **Usage:** Type `/ccReturnOn`.

### Disable Return to Camp
- **Command:** `/ccReturnOff`
- **Description:** Disables automatic return to camp.
- **Usage:** Type `/ccReturnOff`.

### Set Camp Distance
- **Command:** `/ccCampDistance <value>`
- **Description:** Sets the distance limit from camp before auto-return is triggered.
- **Usage:** Type `/ccCampDistance 100`.

### Set Chase Target and Distance
- **Command:** `/ccChase`
- **Description:** Sets a target and distance for the bot to chase.
- **Usage:** Type `/ccChase <target> <distance>`.

---
