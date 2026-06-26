**HealBotBlue**
By Bluewhale.

> **NOTE:** For HealBot to work correctly, the **Selfcast** feature in WoW options needs to be disabled.

### Reporting Errors
Major errors will pop up a frame with error information. Take a screenshot and post comments.

### Installation
Unpack the zipped file and place the `HealBotBlue` folder under `Interface/AddOns` in your World of Warcraft directory. 
Default installation path: `C:\Program Files\World of Warcraft\Interface\AddOns\HealBotBlue`

### Chat Commands
* `/hb` - Toggles the main HealBot panel on and off
* `/hb options` - Toggles the HealBot options panel on and off
* `/hb reset` - Resets the contents of the main HealBot panel

### Option Changes from the original HealBot Continues

### Change Log

**1.2.1**
* **Initialization bug** Fixed issue where Action module would get stuck on infinite loop causing stack overflow.

**v1.2**
* **Class Colors & Dimming:** Frame text now inherits class colors with black outline for better visibility. Missing buffs intelligently dim the class color and turn the text yellow.
* **Modern Skin Updates:** Fixed white background bugs in modern skins and brightened debuff indicators.
* **Bug Fix (Buff Application):** Fixed a Vanilla WoW API bug where applying buffs to a target without having them explicitly selected would trigger auto-self-cast instead.
* **Bug Fix (Health Block):** Fixed a bug where the "Always Heal" option (preventing heals on full HP targets) completely blocked the ability to click frames to apply missing buffs.

**v1.1**
* **Native Hovercasting:** Added a native Action Bar Hovercasting (Mouseover) engine. You can now cast spells on hovered targets using action bar keybinds without losing your current target. Togglable in Options -> General.
* **Fear Ward Tracking:** Added Fear Ward to the global HoT tracker, which will display the icon directly on the unit frame.
* **Bug Fix:** Fixed Shaman weapon buff tracking (e.g., Rockbiter) failing due to spell ranks in tooltips.
* **Bug Fix:** Fixed missing health bar skin textures by ensuring `.tga` paths are explicitly resolved.
* **Bug Fix:** Fixed division-by-zero math errors during UI scaling that caused the addon to crash.

**v1.0**
* **Buff tracking** - Added submenu for tracking buffs on element
* ***Hot tracking with icons** - Hots and DoTs display on player bars
* **Incoming heals use newer protocol** 
* **Chat functionalities** - modified chat functionalities for spellcast announcements
* **Mana Bars** - Mana bars for healers in the grid added togglable from options menu.



