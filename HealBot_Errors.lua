-- HealBot_Errors_OnLoad: Internal utility: HealBot_Errors_OnLoad
function HealBot_Errors_OnLoad(this)
  -- do nothing
end

-- HealBot_Errors_OnShow: Show event handler.
function HealBot_Errors_OnShow(this)
  local client = getglobal("HealBot_Error_Clientx")
  client:SetText("Client="..GetLocale())
  HealBot_Error_Versionx:SetText("Healbot verion="..HEALBOT_VERSION)
  HealBot_Error_Classx:SetText("Player class="..HealBot_UnitClass("player"))
end

-- HealBot_Errors_OnHide: Hide event handler.
function HealBot_Errors_OnHide(this)
  local errtext;
  HealBot_StopMoving(this);
  for j=1,28 do
    errtext = getglobal("HealBot_Error"..j);
    errtext:SetText(" ")
  end
  HealBot_ErrorCnt=0;
end

-- HealBot_Errors_OnDragStart: Internal utility: HealBot_Errors_OnDragStart
function HealBot_Errors_OnDragStart(this,arg1)
  HealBot_StartMoving(this);
end

-- HealBot_Errors_OnDragStop: Internal utility: HealBot_Errors_OnDragStop
function HealBot_Errors_OnDragStop(this)
  HealBot_StopMoving(this);
end

-- HealBot_ErrorsIn: Internal utility: HealBot_ErrorsIn
function HealBot_ErrorsIn(msg,id)
  local errtext = getglobal("HealBot_Error"..id);
  errtext:SetText(msg)
  ShowUIPanel(HealBot_Error);
end

