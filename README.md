**HealBotBlue**
By Bluewhale.

Original HealBot, while being a staple healing addon in Wrath and later expansions, was in its infancy during Vanilla WoW. It was a memory and CPU hog that ate up resources, featured a clunky UI, and offered limited functions. To fix all of the above while still using it as a base framework, I refactored the entire codebase. The monolithic code structure was split to follow a more modern approach (MVC design pattern), making it more stable and easily editable. Additionally, the inefficient AURA scanning was replaced with lightweight (Observer Pattern) reactive programming. It now updates only what is necessary when a trigger fires, rather than performing clumsy, continuous scans of a 40-man raid. By doing so, I managed to throttle down CPU and memory usage significantly, placing it on par with modern addons. Additional functionalities are being added over time to provide a holistic, healer-centered raid frame.


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

**v1.3**
* **Monolithic Code Modularization (Options):** Split the massive, single-file options system (`HealBot_Options.xml`/`HealBot_Options.lua`) into 7 dedicated, content-named panel subfiles (`General`, `Spells`, `Healing`, `CDC`, `Skins`, `Buffs`, and `Chat`) to improve codebase modularity and stability.
* **Core Code Decoupling (MVC & Observer Pattern):** Modularized `HealBot.lua` and `HealBot_Action.lua` by decoupling them into dedicated service files: `Range`, `Comms`, `Aura`, `Spells`, `Events` controllers, and `Layout`, `Tooltip` views.
* **Scope Resolution Fix:** Promoted `HealBot_Options_ComboButtons_Button` to global scope in the base options file to resolve a `nil` comparison error when loading spell settings.
* **Global Scoping & Variable Promotion:** Promoted `CalcEquipBonus`, `HealBot_EquipChangeTimer`, `HealValue`, `InitSpells`, and `Delay_RecalcParty` to global scope in `HealBot.lua` to ensure cross-module visibility.
* **CTRA Resurrection Cancel Bug Fix:** Fixed a nil table indexing crash in the CTRA `RESNO` message handler in `HealBot_Controller_Comms.lua`.
* **Lua 5.1 Compatibility Update:** Forwarded observer parameters directly via vararg forwarding (`...`) in `HealBot_Model.lua` to avoid runtime errors with the deprecated `arg` table.
* **Core Options Layout Correction:** Relocated the "Defaults" and "Close" buttons back into the parent options frame's container, ensuring they display consistently at the bottom of all configuration tabs.
* **Skins Grid Alignment:** Fixed layout overlaps on the Skins panel by setting explicit width/height sizes (`123 x 17`) on the opacity sliders and reorganizing all 13 sliders into a clean, uniform 2-column grid.
* **Startup Refresh Optimization:** Resolved initial loading lag where action bars would be missing by forcing an immediate UI refresh (`HealBot_RecalcSpells()`) once spell data loads.
* **UI Layout Fixes:** Fixed slider width constraints in the Skin menu causing layout overlaps. Realigned Chat tab buttons to ensure they do not exceed the window bounds. Fixed Color Picker anchors.
* **Menu Cleanup:** Fixed Options panel checkboxes overlapping due to incorrect vertical spacing offsets.

**v1.2.2**
* **White background fix** Fixed issue where white background would persist while alpha channel got changes.
* **Alpha slider** Fixed bug where alpha slider wouldn't apply changes instantly.

**v1.2.1**
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
* **Buff tracking:** Added a submenu for tracking buffs on elements.
* **HoT tracking with icons:** HoTs and DoTs display on player bars.
* **Incoming heals:** Now using a newer protocol.
* **Chat functionalities:** Modified chat functionalities for spellcast announcements.
* **Mana Bars:** Mana bars for healers in the grid added, toggleable from the options menu.




