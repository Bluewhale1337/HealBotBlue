HealBot_Integrations_UnitXP_Active = false;
HealBot_Integrations_Nampower_Active = false;

function HealBot_Integrations_Toggle()
  -- UnitXP
  if HealBot_Config.HealBot_Integrations_UnitXP == 1 and UnitXP ~= nil then
    HealBot_Integrations_UnitXP_Active = true;
    HealBot_AddDebug("UnitXP Integration: ENABLED");
  else
    HealBot_Integrations_UnitXP_Active = false;
    HealBot_AddDebug("UnitXP Integration: DISABLED");
  end

  -- nampower
  if HealBot_Config.HealBot_Integrations_Nampower == 1 then
    HealBot_Integrations_Nampower_Active = true;
    HealBot_AddDebug("nampower Integration: ENABLED");
    -- Add Nampower specific initialization here later
  else
    HealBot_Integrations_Nampower_Active = false;
    HealBot_AddDebug("nampower Integration: DISABLED");
  end
end
