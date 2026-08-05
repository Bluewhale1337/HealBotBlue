**HealBotBlue**
By Bluewhale.

> **NOTE:** For HealBot to work correctly, the **Selfcast** feature in WoW options needs to be disabled.

Original HealBot, while being a staple healing addon in Wrath and later expansions, was in its infancy during Vanilla WoW. It was a memory and CPU hog that ate up resources, featured a clunky UI, and offered limited functions. To fix all of the above while still using it as a base framework, I refactored the entire codebase. The monolithic code structure was split to follow a more modern approach (MVC design pattern), making it more stable and easily editable. Additionally, the inefficient AURA scanning was replaced with lightweight (Observer Pattern) reactive programming. It now updates only what is necessary when a trigger fires, rather than performing clumsy, continuous scans of a 40-man raid. By doing so, I managed to throttle down CPU and memory usage significantly, placing it on par with modern addons. Additional functionalities are being added over time to provide a holistic, healer-centered raid frame.

> **Performance First:** The raidframe is not library reliant - unlike popular raidframe replacement addons it doesn't rely at all on external frameworks. While this makes my work a bit harder this allows complete control over garbage collection and CPU use which makes it multiple times more stable and lightweight.

### Reporting Errors
Major errors will pop up a frame with error information. Take a screenshot and post comments.

### Installation
Unpack the zipped file and place the `HealBotBlue` folder under `Interface/AddOns` in your World of Warcraft directory. 
Default installation path: `C:\Program Files\World of Warcraft\Interface\AddOns\HealBotBlue`

### Chat Commands
* `/hb` - Toggles the main HealBot panel on and off
* `/hb options` - Toggles the HealBot options panel on and off
* `/hb reset` - Resets the contents of the main HealBot panel

### Key Features & Current Functionality
* **MVC & Observer Architecture:** High-performance, reactive engine that updates frames dynamically on state changes, drastically reducing CPU and memory overhead. Features memory recycling pool and event loop decoupling for zero-stutter combat.
* **Native Hovercasting (Mouseover):** Cast configured spells on hovered unit frames using keybinds directly from your action bars, without losing your current target. (Toggleable in Options -> General).
* **Macro, Item, & Script Bindings:** Bind named macros, inventory items, and scripts directly to mouse clicks. Supports implicit `@mouseover` targeting natively.
* **Zero-Latency Self-Heals:** Incoming heals for the local player process instantly with zero latency, independent of network lag.
* **Talent-Based Calculations & Equipment Bonus:** Dynamic spell healing calculations for Druid, Priest, and Paladin based on talents, and automatically scans equipped gear to scale healing predictions - currently only TurtleWoW patch 1.18 supported.
* **Modifier-Aware Tooltips:** Tooltips dynamically update to show exact bound actions (Shift/Ctrl/Alt) and required mana costs (turns red if insufficient mana).
* **Blizzard Party Frame Toggle:** Toggle to automatically hide Blizzard's default party frames when in a group in favor of HealBot's layouts.
* **HoT & Buff Tracking:** Intelligently track active HoTs and buffs directly on the grid frames with custom icons (e.g., Renew, Rejuvenation, Regrowth, Fear Ward).
* **Mana Bars for Healers:** Enable and position mini-mana status bars next to unit frames, toggleable to display for healer classes only or all classes.
* **Curse & Debuff Warning (CDC):** Dynamic visual and audio alerts for cleanable debuffs. Customizable colors based on debuff type (Curse, Poison, Disease, Magic).
* **Pet & Familiar Frames:** Dedicated, toggleable frames for tracking and healing player pets.
* **Customizable Health Text:** Dynamic unit health display (Name Only, Percentage, Real Health, or Health Deficit).
* **Non-Mana Resource Tracking:** Track Rage, Energy, and Focus for non-mana classes.
* **Highly Customizable Skins:** Fully configure dimensions (width, height), row spacing, column layouts, custom textures, opacity, class-colored frames, and outline of fonts.

### To be implemented
- **GUID-based frame mapping:** Migrate internal state to use lightweight GUID tracking to resolve bugs when targets switch or duplicate names appear (e.g., enemy mobs, warlock pets).
- **Mod Integration Optimization:** Add conditional SuperWoW/UnitXP SP3 integration to reduce GC spikes and improve frame rendering accuracy.

### Known issues

* **New spell rank bug** you may experience lua error spaming your chat frame after learning new healing spells. /reload will clear the issue.


### Change Log

**v1.6.2**
* **Hotfix - raid and party frames** - if getNumRaidMembers() > 0 wrapper around extra bars stopped from displaying all frames blocked from displaying Extras\Raid.
* **UI Update - Raid & Pets Split** - Split the "Raid / Extra" toggle into separate "Raid" and "Pets" toggles. Simplified the raid bars filter dropdown to core options (All, Melee, Ranged, Heals, Custom).

**v1.6.1**
* **Hotfix - pet frames** - With class colours toggled extra frames for player pets were given some classy mint colour.
* **Hotfi - raidframes in combat** - Modfied how frames behave when player leaves during combat.

**v1.6**
* **Event Loop Decoupling:** Ripped out redundant synchronous UI redraws that were bypassed by the new MVC architecture. High-frequency events (mana regen, health ticks) now fully rely on the `HealBot_OnUpdate` dirty queue, severely reducing CPU bottlenecks.
* **Combat UI Optimizations:** Removed unnecessary full spell recalculations when dropping combat, preventing client stutter after every mob kill.
* **Memory Optimization:** Fixed severe Lua garbage collection spikes during UI reloads by preventing full party layout rebuilds on `PLAYER_TARGET_CHANGED`, and cached dynamic string concatenations directly to unit frames to eliminate memory leakage on high frequency UI refreshes.
* **Mana Validation Fix:** Removed artificial spell mana gating, fixing an issue where low-mana spells disappeared from tooltips and couldn't be cast. WoW's native mana validation now correctly processes 0-cost buffs (e.g. Clearcasting, Inner Focus) while turning low-mana tooltip spells red.
* **Self-Buff Tracking:** Fixed a bug where "Self Only" buff tracking incorrectly excluded the player when represented by party or raid frames instead of the standard "player" unit ID.
* **Settings Persistence Fix:** Changed `SavedVariables` to `SavedVariablesPerCharacter` in TOC so configurations correctly load unique per character instead of account-wide.
* **CPU Optimization:** Added early exit logic to resource tracking events (Mana, Rage, Energy) to stop background polling on party/raid members when "Show Mana Bars" is toggled off. Also removed excessive triggers (`BAG_UPDATE`, `PET_BAR_SHOWGRID`) and filtered `UNIT_INVENTORY_CHANGED` to only process the player, eliminating massive CPU spikes and unnecessary UI layout rebuilds during looting, item cooldowns, or when other players change gear.
* **OnUpdate GC Spike Fix:** Rewrote the modifier polling logic inside `HealBot_OnUpdate` to use boolean state tracking instead of dynamic string concatenation, eliminating a major source of garbage collection bloat while hovering over unit frames.
* **Aura Scanning Optimization:** Refactored Debuff tracking (`HealBot_DebuffWatch`) to use native boolean values (`true`/`false`) instead of string comparisons (`"YES"`/`"NO"`). This improves performance inside the continuous aura scanning loops.

**v1.5**
* **Macro, Item, and Script Bindings:** Support for binding named macros, inventory items, and inline scripts (e.g. `/target`) directly to mouse clicks in the Spells tab. All of these now natively support implicit `@mouseover` targeting on the unit frame you click, without losing your current target.
* **Modifier-Aware Tooltips & Resource Costs:** The tooltip dynamically updates to show exactly what action is bound when holding down Shift, Ctrl, or Alt over a frame. Spells also show their required mana cost, turning red if you do not have enough mana to cast them.
* **Memory Recycling Pool:** Added a local table recycling pool in the data layer to greatly reduce Lua garbage collection (GC) spikes, improving overall client frame rates during intense combat.

**v1.4.2**
* **Memory Optimization:** Fixed a significant memory leak where tracking tables were being repeatedly allocated every tick during aura scanning, and replaced `table.foreach` with pairs loops to avoid GC spikes during combat.

**v1.4.1**
* **Talent-based Healing Calculations:** Implemented dynamic spell healing calculations for Druid, Priest, and Paladin classes based on talents.
* **Modifier Key Polling:** Replaced MODIFIER_STATE_CHANGED event with polling in HealBot_OnUpdate to track modifier keys reliably.
* **Incoming Heals Fix:** Fixed a bug where incoming heals failed to broadcast or show on the UI due to synchronous GCD fails and `CheckInteractDistance` limitations in the 1.12 API.
* **Hovercast Incoming Heals:** Added full support for processing and displaying incoming heals when using action bar hovercasting.
* **Zero-latency Self-Heals:** Incoming heals for the local player now process instantly with zero latency and no network reliance, ensuring they function even when playing solo.

**v1.4** 
* **Extra Frame support for pets and familiars added:** Togglable from healing tab - Extra frames option selected & pets selected from dropdown.
* **Customizable Health Text:** Added a new dropdown in the Healing Options tab that allows users to choose how health text is displayed on unit frames (`Name Only`, `Health Percentage`, `Real Health`, or `Health Deficit`). Includes a smart truncation algorithm to preserve critical health numbers even if the unit name is too long.
* **Non-Mana Resource Tracking:** Added a new toggle in the General Options tab to track secondary resources (Energy, Rage, Focus) for non-mana classes. Bars are dynamically color-coded based on the resource type.
* **Dropdown UI Initialization Fix:** Resolved a Vanilla API bug where dropdown menus sharing an ID (like the new Health Text dropdown) would temporarily inherit text from previously loaded dropdowns (e.g., "Modern Flat").
* **Dynamic Modifier Tooltips:** Fixed a bug where the spell tooltip would not dynamically update its spells when pressing modifier keys (Shift/Ctrl/Alt) while hovering over a unit frame. Registered the `MODIFIER_STATE_CHANGED` event to instantly refresh the tooltip.
* **Global Variable Namespace Refactoring:** Executed a codebase-wide refactoring to encapsulate all floating global variables inside the `HealBot_` or `HEALBOT_` namespace. This prevents HealBot from silently shadowing other addons or the native WoW API, ensuring strict adherence to Vanilla Lua best practices. (Also resolved a namespace collision with `InitSpells`).
* **Chat Announcements & Mouseover Casts:** Chat announcements are now correctly fired when using native Hovercasting (Mouseover). Additionally, added safety checks to prevent spamming chat announcements when accidentally clicking on a dead player (unless casting a resurrection spell).
* **New Priest Buff (Enlighten):** Added the custom "Enlighten" buff to Priest trackable buffs, complete with the `btnholyscriptures` icon on unit frames.


**1.3.3**
* **Chat Panel Refactor:** Completely replaced the spell selection dropdowns in the Chat tab with manual text input boxes, allowing users to type exact spell names (with or without ranks) directly, matching the behavior of the key-bindings configuration. Fixed a string matching bug caused by Vanilla WoW's hidden trailing spaces when comparing spell names, ensuring that both rankless (e.g. `Flash Heal`) and ranked inputs trigger correctly. 
* **Chat Layout Stack:** Restructured the Chat Options XML layout to correctly stack the inputs into neat rows, preventing horizontal overlap and providing more space for typing long announce messages.
* **UI Persistence Bug Fixes:** Fixed a Vanilla WoW API quirk where unchecking the "Show Headers" or "Self Only" (Buffs) checkboxes caused the UI to either visually re-check itself or overwrite the setting with defaults upon a `/reload`.

**1.3.2**
* **UIDropDownMenu Fixes:** Resolved native client crash (`UIDROPDOWNMENU_OPEN_MENU` nil concatenation) when setting values on closed dropdowns.

**1.3.1**
* **Hotfix: missing helper function restored** Fixed issue with lua error for druids. 

**v1.3**
* **General Options Layout & Renaming:** Relabeled "Healing panel options" to "Mana bar options:", moved the "For Healers Only" checkbox side-by-side with "Show Mana Bars", and renamed "Enable mouse over action bar" to "Hovercasting".
* **OnShow Empty Panel Bug Fix:** Solved the rendering issue where the options panel would load empty initially until another tab was clicked.
* **Backdrop Alpha Reset Bug Fix:** Resolved a WoW API client quirk where showing the HealBot frame would reset the background color and alpha channel back to default white/transparent by calling `SetBackdropColor` after `SetBackdrop`.
* **Default Party Frame Toggle:** Added a "Hide Default Party Frames" toggle option (fully localized in English, German, French, and Korean) to hide Blizzard's default party frames. Integrated immediate toggling on joining/leaving groups.
* **Safety Guards & Crash Prevention:** Added safety guards to `HidePartyFrame` and `ShowPartyFrame` calls to prevent nil-value crashes when solo.
* **Checkbox State Initialization Fixes:** Fixed options menu bugs where "Hide when Solo", "Show Mana Bars", and "For Healers Only" checkboxes failed to reflect their saved configuration value when opening the menu.
* **CurrentPanel Nil Comparison Fix:** Fixed a startup Lua comparison crash by initializing `HealBot_Options_CurrentPanel` at the top of the main options file.
* **Monolithic Code Modularization (Options):** Split the massive, single-file options system (`HealBot_Options.xml`/`HealBot_Options.lua`) into 7 dedicated, content-named panel subfiles (`General`, `Spells`, `Healing`, `CDC`, `Skins`, `Buffs`, and `Chat`) to improve codebase modularity and stability.
* **Core Code Decoupling (MVC & Observer Pattern):** Modularized `HealBot.lua` and `HealBot_Action.lua` by decoupling them into dedicated service files: `Range`, `Comms`, `Aura`, `Spells`, `Events` controllers, and `Layout`, `Tooltip` views.
* **Scope Resolution Fix:** Promoted `HealBot_Options_ComboButtons_Button` to global scope in the base options file to resolve a `nil` comparison error when loading spell settings.
* **Global Scoping & Variable Promotion:** Promoted `CalcEquipBonus`, `HealBot_EquipChangeTimer`, `HealValue`, `InitSpells`, and `Delay_RecalcParty` to global scope in `HealBot.lua` to ensure cross-module visibility.
* **CTRA Resurrection Cancel Bug Fix:** Fixed a nil table indexing crash in the CTRA `RESNO` message handler in `HealBot_Controller_Comms.lua`.
* **Core Options Layout Correction:** Relocated the "Defaults" and "Close" buttons back into the parent options frame's container, ensuring they display consistently at the bottom of all configuration tabs.
* **UI Layout & Skins Alignment:** Reorganized all 13 opacity sliders on the Skins panel into a clean, uniform 2-column grid with explicit width/height sizes (`123 x 17`) to resolve layout overlaps. Realigned Chat tab buttons to stay within window bounds and corrected Color Picker anchors.
* **Startup Refresh Optimization:** Resolved initial loading lag where action bars would be missing by forcing an immediate UI refresh (`HealBot_RecalcSpells()`) once spell data loads.
* **Menu Cleanup:** Fixed Options panel checkboxes overlapping due to incorrect vertical spacing offsets.
* **Target Restoration Fix:** Fixed spell interruptions and "You don't have a target" errors when healing by implementing a 0.1-second delayed target restoration using `TargetLastEnemy` and `TargetLastTarget`.
* **Buff Watch Initialization & Options Fix:** Fixed a bug where buff watch failed to display missing buffs on login/UI reload when the player had no active buffs. Enabled immediate buff/aura rescanning when modifying options in the Buff watch configuration tab.

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




