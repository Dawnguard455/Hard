if not CLIENT then return end
if _G.HOUSTON_F4_LOADED then return end
_G.HOUSTON_F4_LOADED = true
local W, H = 1400, 850
local HEADER_H = 56
local SIDEBAR_W = 260
local MONTHS = {"ЯНВАРЯ","ФЕВРАЛЯ","МАРТА","АПРЕЛЯ","МАЯ","ИЮНЯ","ИЮЛЯ","АВГУСТА","СЕНТЯБРЯ","ОКТЯБРЯ","НОЯБРЯ","ДЕКАБРЯ"}
local DAYS = {"ВОСКРЕСЕНЬЕ","ПОНЕДЕЛЬНИК","ВТОРНИК","СРЕДА","ЧЕТВЕРГ","ПЯТНИЦА","СУББОТА"}
surface.CreateFont("HF4_Logo",  { font = "JetBrains Mono", size = 18, weight = 700 })
surface.CreateFont("HF4_Time",  { font = "JetBrains Mono", size = 13, weight = 700 })
surface.CreateFont("HF4_Date",  { font = "JetBrains Mono", size = 11, weight = 400 })
surface.CreateFont("HF4_Close", { font = "JetBrains Mono", size = 18, weight = 400 })
surface.CreateFont("HF4_Tab",   { font = "JetBrains Mono", size = 13, weight = 400 })
surface.CreateFont("HF4_TabA",  { font = "JetBrains Mono", size = 13, weight = 700 })
surface.CreateFont("HF4_Badge", { font = "JetBrains Mono", size = 10, weight = 700 })
surface.CreateFont("HF4_Mini",  { font = "JetBrains Mono", size = 11, weight = 400 })
surface.CreateFont("HF4_MiniB", { font = "JetBrains Mono", size = 11, weight = 700 })
surface.CreateFont("HF4_SName", { font = "JetBrains Mono", size = 13, weight = 700 })
surface.CreateFont("HF4_SJob",  { font = "JetBrains Mono", size = 11, weight = 700 })
local LINKS = {
    discord = "https://discord.gg/9YczsP5jXN",
    telegram = "https://t.me/YOUR_CHANNEL",
    vk = "https://vk.com/YOUR_GROUP",
    website = "https://your-site.com",
    forum = "https://your-site.com/forum",
    laws = "https://your-site.com/laws",
    rules = "https://your-site.com/rules",
    donate = "https://your-site.com/donate",
    info = "https://your-site.com/info",
    apply = "https://forum.your-site.com/faction-applications",
}
local FACTIONS = {
    { name = "HOUSTON POLICE DEPARTMENT", status = "open", slots = 25,
      desc = "Основное правоохранительное ведомство города Хьюстон. Патрулирование улиц, реагирование на 911, расследование преступлений.",
      reqs = { "Возраст IC: от 21 года", "Возраст OOC: от 14 лет", "Микрофон, отсутствие банов", "Знание законов и правил" } },
    { name = "GOVERNMENT OF HOUSTON", status = "open", slots = 20,
      desc = "Правительство города: законы, бюджет, лицензии, суды, выборы.",
      reqs = { "Возраст IC: от 25 лет", "Возраст OOC: от 16 лет", "Опыт в госструктурах", "Знание законов города" } },
    { name = "HOUSTON FIRE DEPARTMENT", status = "open", slots = 15,
      desc = "Пожарная охрана и парамедики. Тушение пожаров, спасение из ДТП.",
      reqs = { "Возраст IC: от 18 лет", "Возраст OOC: от 14 лет", "Отсутствие банов", "Знание законов" } },
    { name = "HOUSTON MEDICAL CENTER", status = "open", slots = 25,
      desc = "Главная больница города. Нейтральная фракция.",
      reqs = { "Возраст IC: от 18 лет", "Возраст OOC: от 14 лет", "Стрессоустойчивость", "Нейтралитет" } },
    { name = "WEAZEL NEWS HOUSTON", status = "open", slots = 15,
      desc = "Новостное агентство города. Репортажи, интервью, статьи.",
      reqs = { "Возраст IC: от 18 лет", "Возраст OOC: от 14 лет", "Грамотность, портфолио", "Знание законов" } },
}
local function FM(n)
    local s = tostring(math.floor(n or 0))
    local k
    repeat s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1 %2") until k == 0
    return "$" .. s
end
local function GetBank(ply) return IsValid(ply) and (ply:GetNWInt("bank", 0) or 0) or 0 end
local function GetCash(ply) return IsValid(ply) and (ply:getDarkRPVar("money") or 0) or 0 end
local function BuildContentHTML()
    local ply = LocalPlayer()
    local pjob = string.upper(team.GetName(ply:Team()))
    local cash = FM(GetCash(ply))
    local bank = FM(GetBank(ply))
    local players = #player.GetAll() .. " / " .. game.MaxPlayers()
    local map = string.upper(game.GetMap())
    local salary = "$" .. tostring(ply:getDarkRPVar("salary") or 0) .. " / 5 МИН"
    local t = os.date("*t")
    local timeStr = string.format("%02d:%02d", t.hour, t.min)
    local dateStr = t.day .. " " .. MONTHS[t.month] .. " " .. t.year
    local fullDate = DAYS[t.wday] .. ", " .. dateStr
    local fH = ""
    for _, fac in ipairs(FACTIONS) do
        local sc = fac.status == "open" and "#4ade80" or "#5a5a5a"
        local st = fac.status == "open" and "● НАБОР ОТКРЫТ" or "○ НАБОР ЗАКРЫТ"
        local rq = ""
        for _, r in ipairs(fac.reqs or {}) do
            rq = rq .. "<div class='freq'>· " .. r .. "</div>"
        end
        local btn = fac.status == "open" and
            "<button class='fbtn' onclick=\"houston.openURL('" .. (LINKS.apply or "#") .. "')\">ПОДАТЬ ЗАЯВКУ НА ФОРУМЕ →</button>" or ""
        fH = fH .. "<div class='faction'><div class='fhead'><div class='fname'>" .. fac.name .. "</div><div class='fstatus' style='color:" .. sc .. "'>" .. st .. "</div></div><div class='fdesc'>" .. (fac.desc or "") .. "</div><div class='freqs'>" .. rq .. "</div><div class='fslots'>СЛОТОВ: <b>" .. (fac.slots or 0) .. "</b></div>" .. btn .. "</div>"
    end
    local cH = ""
    local comms = {
        {"ДИСКОРД", LINKS.discord, "#5865F2", "D", "Основная площадка общения. Голосовые каналы, обзвоны."},
        {"ТЕЛЕГРАМ", LINKS.telegram, "#24A1DE", "T", "Новостной канал и чат проекта."},
        {"ВКОНТАКТЕ", LINKS.vk, "#0077FF", "VK", "Официальная группа VK."},
        {"САЙТ", LINKS.website, "#333", "W", "Официальный сайт проекта."},
        {"ФОРУМ", LINKS.forum, "#333", "F", "Форум. Заявки, жалобы."},
    }
    for _, c in ipairs(comms) do
        cH = cH .. "<div class='commcard' onclick=\"houston.openURL('" .. (c[2] or "#") .. "')\"><div class='commicon' style='background:" .. c[3] .. "'>" .. c[4] .. "</div><div class='commname'>" .. c[1] .. "</div><div class='commdesc'>" .. c[5] .. "</div><div class='commlink'>ПРИСОЕДИНИТЬСЯ →</div></div>"
    end
    local wH = ""
    local ws = {
        {"ЗАКОНЫ СЕРВЕРА", LINKS.laws, "ДОКУМЕНТЫ"},
        {"ПРАВИЛА СЕРВЕРА", LINKS.rules, "ПРАВИЛА"},
        {"ДОНАТ", LINKS.donate, "МАГАЗИН"},
        {"ИНФОРМАЦИЯ", LINKS.info, "ИНФОРМАЦИЯ"},
    }
    for _, l in ipairs(ws) do
        wH = wH .. "<div class='linkrow' onclick=\"houston.openURL('" .. (l[2] or "#") .. "')\"><span class='linklabel'>" .. l[1] .. "</span><span class='linkvalue'>" .. l[3] .. " →</span></div>"
    end
    return [[<!DOCTYPE html>
<html><head><meta charset="UTF-8"><style>
*{box-sizing:border-box;margin:0;padding:0}
html,body{width:100%;height:100%;overflow:hidden}
body{background:#121212;color:#fff;font-family:'JetBrains Mono','Consolas',monospace;font-size:12px;display:flex;flex-direction:column}
.page{display:none;padding:20px 24px;overflow-y:auto;flex:1;min-height:0}
.page.active{display:block;animation:fadeIn 0.22s ease}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
.page::-webkit-scrollbar{width:6px}
.page::-webkit-scrollbar-track{background:transparent}
.page::-webkit-scrollbar-thumb{background:#e63946;border-radius:3px}
.section-title{font-size:12px;font-weight:700;color:#8a8a8a;letter-spacing:0.8px;margin-bottom:12px;padding-bottom:8px;border-bottom:1px solid #2a2a2a;position:relative}
.section-title::before{content:'';position:absolute;left:0;bottom:-1px;width:40px;height:1px;background:#e63946}
.info-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid rgba(42,42,42,0.5);font-size:12px}
.info-row:last-child{border-bottom:none}
.info-label{color:#5a5a5a}
.info-value{color:#fff;font-weight:700}
.info-value.accent{color:#e63946}
.info-value.success{color:#4ade80}
.hint{font-size:11px;color:#5a5a5a;padding:8px 12px;border-left:2px solid #e63946;margin:14px 0;line-height:1.7}
.hint b{color:#e63946}
.faction{background:#1c1c1c;border:1px solid #2a2a2a;border-radius:2px;padding:14px;margin-bottom:10px;transition:all 0.2s ease;position:relative}
.faction::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:#e63946;opacity:0;transition:opacity 0.2s ease}
.faction:hover{background:#232323;border-color:rgba(230,57,70,0.4)}
.faction:hover::before{opacity:1}
.fhead{display:flex;justify-content:space-between;margin-bottom:8px;align-items:center}
.fname{font-size:13px;font-weight:700;color:#fff}
.fstatus{font-size:10px;font-weight:700}
.fdesc{font-size:11px;color:#8a8a8a;line-height:1.6;margin-bottom:10px}
.freqs{font-size:10px;color:#5a5a5a;line-height:1.8;padding-left:10px;border-left:2px solid #2a2a2a;margin-bottom:10px}
.fslots{font-size:10px;color:#5a5a5a;margin-bottom:10px}
.fslots b{color:#e63946}
.fbtn{background:transparent;border:1px solid #e63946;color:#e63946;padding:7px 16px;font-family:inherit;font-size:11px;font-weight:700;cursor:pointer;border-radius:2px;transition:all 0.2s ease}
.fbtn:hover{background:#e63946;color:#fff}
.commgrid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.commcard{background:#1c1c1c;border:1px solid #2a2a2a;border-radius:2px;padding:18px;cursor:pointer;transition:all 0.2s ease;position:relative}
.commcard::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:#e63946;opacity:0;transition:opacity 0.2s ease}
.commcard:hover{background:#232323;border-color:rgba(230,57,70,0.4)}
.commcard:hover::before{opacity:1}
.commicon{width:44px;height:44px;border-radius:50%;margin-bottom:12px;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:18px;color:#fff}
.commname{font-size:13px;font-weight:700;margin-bottom:6px;color:#fff}
.commdesc{font-size:11px;color:#5a5a5a;line-height:1.6;margin-bottom:10px}
.commlink{font-size:11px;color:#e63946;font-weight:700}
.linkrow{display:flex;justify-content:space-between;padding:14px 0;border-bottom:1px solid rgba(42,42,42,0.7);cursor:pointer;position:relative}
.linkrow:first-child{border-top:1px solid rgba(42,42,42,0.7)}
.linkrow::before{content:'';position:absolute;left:0;top:50%;width:3px;height:0;background:#e63946;transition:all 0.2s ease}
.linkrow:hover{padding-left:10px}
.linkrow:hover::before{height:20px;margin-top:-10px}
.linklabel{font-size:13px;color:#8a8a8a}
.linkrow:hover .linklabel{color:#fff}
.linkvalue{font-size:12px;color:#e63946;font-weight:700}
.shop-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;padding-bottom:12px;border-bottom:1px solid #2a2a2a}
.shop-head-left{display:flex;flex-direction:column;gap:6px}
.shop-title{font-size:13px;font-weight:700;color:#fff}
.shop-wallet{font-size:12px;color:#5a5a5a}
.shop-wallet b{color:#e63946}
.currency-switch{display:flex;border:1px solid #2a2a2a;border-radius:2px;overflow:hidden}
.currency-label{padding:8px 12px;font-size:10px;color:#5a5a5a;background:#161616;border-right:1px solid #2a2a2a;display:flex;align-items:center}
.currency-btn{padding:8px 16px;background:#1c1c1c;color:#8a8a8a;border:none;font-family:inherit;font-size:11px;font-weight:700;cursor:pointer;border-right:1px solid #2a2a2a}
.currency-btn:last-child{border-right:none}
.currency-btn.active{background:#e63946;color:#fff}
.shop-empty{border:1px dashed #2a2a2a;padding:60px 20px;text-align:center;color:#5a5a5a}
.shop-empty-icon{font-size:42px;margin-bottom:16px;opacity:0.5}
.shop-empty-title{font-size:13px;color:#8a8a8a;margin-bottom:10px;font-weight:700;letter-spacing:1.2px}
.shop-empty-desc{font-size:11px;line-height:1.7}
.shop-empty-desc b{color:#e63946}
</style></head><body>
<div class="page active" id="p-dashboard">
  <div class="section-title">ИНФОРМАЦИЯ О СЕРВЕРЕ</div>
  <div class="info-row"><span class="info-label">ИГРОКОВ</span><span class="info-value accent">]] .. players .. [[</span></div>
  <div class="info-row"><span class="info-label">РЕЖИМ</span><span class="info-value">DARKRP</span></div>
  <div class="info-row"><span class="info-label">КАРТА</span><span class="info-value">]] .. map .. [[</span></div>
  <div class="info-row"><span class="info-label">ВРЕМЯ</span><span class="info-value">]] .. timeStr .. [[</span></div>
  <div class="info-row"><span class="info-label">ДАТА</span><span class="info-value">]] .. fullDate .. [[</span></div>
  <div class="section-title" style="margin-top:24px">ВАШ ПРОФИЛЬ</div>
  <div class="info-row"><span class="info-label">ПРОФЕССИЯ</span><span class="info-value accent">]] .. pjob .. [[</span></div>
  <div class="info-row"><span class="info-label">ЗАРПЛАТА</span><span class="info-value">]] .. salary .. [[</span></div>
  <div class="info-row"><span class="info-label">НАЛИЧКА</span><span class="info-value accent">]] .. cash .. [[</span></div>
  <div class="info-row"><span class="info-label">БАНК</span><span class="info-value success">]] .. bank .. [[</span></div>
  <div class="hint">Магазин в разделе <b>МАГАЗИН</b> доступен только для вашей текущей профессии.<br>Смена профессии - у <b>NPC профессий</b> в игре.<br>Жалобы - на форуме. Информация - в разделе <b>САЙТ</b>.</div>
</div>
<div class="page" id="p-shop">
  <div class="shop-head"><div class="shop-head-left"><div class="shop-title">МАГАЗИН - ]] .. pjob .. [[</div><div class="shop-wallet">КОШЕЛЁК: <b>]] .. cash .. [[</b></div></div><div class="currency-switch"><div class="currency-label">ОПЛАТА</div><button class="currency-btn active">НАЛИЧКА</button><button class="currency-btn">БАНК</button></div></div>
  <div class="shop-empty"><div class="shop-empty-icon">&#128722;</div><div class="shop-empty-title">МАГАЗИН ПУСТ</div><div class="shop-empty-desc">Для профессии <b>]] .. pjob .. [[</b> товары не добавлены.</div></div>
</div>
<div class="page" id="p-factions">
  <div class="section-title">ФРАКЦИИ - ТОЛЬКО ЧЕРЕЗ ОБЗВОН</div>
  <div class="hint">Фракции <b>не продаются</b>. Заявка подаётся <b>на форуме</b>, обзвон проходит в Discord с лидером фракции.</div>
  ]] .. fH .. [[
</div>
<div class="page" id="p-community">
  <div class="section-title">СООБЩЕСТВО HARD | HOUSTON</div>
  <div class="hint">Присоединяйтесь к нашему сообществу - общение, анонсы, поддержка и обзвоны.</div>
  <div class="commgrid">]] .. cH .. [[</div>
</div>
<div class="page" id="p-website">
  <div class="section-title">НАШ САЙТ</div>
  ]] .. wH .. [[
</div>
<script>
function showPage(name) {
  var ps = document.querySelectorAll('.page');
  for (var i = 0; i < ps.length; i++) ps[i].classList.remove('active');
  var p = document.getElementById('p-' + name);
  if (p) p.classList.add('active');
}
</script>
</body></html>]]
end
local currentTab = "dashboard"
local tabButtons = {}
local contentPanel = nil
local TABS = {
    { id = "dashboard", label = "ПАНЕЛЬ" },
    { id = "shop",      label = "МАГАЗИН", badge = "0" },
    { id = "factions",  label = "ФРАКЦИИ", badge = "5" },
    { id = "community", label = "СООБЩЕСТВО" },
    { id = "website",   label = "САЙТ" },
}
local function SwitchTab(id)
    currentTab = id
    for _, btn in ipairs(tabButtons) do btn.IsActive = (btn.TabId == id) end
    if IsValid(contentPanel) then contentPanel:QueueJavascript("showPage('" .. id .. "')") end
end
local function OpenF4()
    if IsValid(_G.HoustonF4Frame) then _G.HoustonF4Frame:Close() return end
    local f = vgui.Create("DFrame")
    _G.HoustonF4Frame = f
    f:SetSize(W, H); f:Center(); f:MakePopup()
    f:SetTitle(""); f:ShowCloseButton(false); f:SetDraggable(true)
    f:SetKeyboardInputEnabled(true)
    f.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(18, 18, 18, 255))
        surface.SetDrawColor(230, 57, 70); surface.DrawRect(0, 0, w, 2)
        surface.SetDrawColor(22, 22, 22); surface.DrawRect(0, HEADER_H, SIDEBAR_W, h - HEADER_H)
        surface.SetDrawColor(42, 42, 42); surface.DrawRect(0, HEADER_H, w, 1)
        surface.SetDrawColor(42, 42, 42); surface.DrawRect(SIDEBAR_W, HEADER_H, 1, h - HEADER_H)
        surface.SetDrawColor(42, 42, 42); surface.DrawRect(20, h - 120, SIDEBAR_W - 40, 1)
        draw.SimpleText("HARD",    "HF4_Logo", 20, HEADER_H/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("HOUSTON", "HF4_Logo", 94, HEADER_H/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(230, 57, 70); surface.DrawRect(78, HEADER_H/2 - 10, 3, 20)
    end
    contentPanel = vgui.Create("DHTML", f)
    contentPanel:SetPos(SIDEBAR_W + 1, HEADER_H + 1)
    contentPanel:SetSize(W - SIDEBAR_W - 1, H - HEADER_H - 1)
    contentPanel:SetHTML(BuildContentHTML())
    contentPanel:AddFunction("houston", "openURL", function(url)
        if url and url ~= "" and url ~= "#" then gui.OpenURL(url) surface.PlaySound("buttons/button14.wav") end
    end)
    -- Шапка справа
    local closeBtn = vgui.Create("DButton", f)
    closeBtn:SetPos(W - 34, HEADER_H/2 - 11)
    closeBtn:SetSize(22, 22); closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hov = self:IsHovered()
        draw.SimpleText("×", "HF4_Close", w/2, h/2 - 1, hov and Color(230,57,70) or Color(138,138,138), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() f:Close() end
    local curX = W - 60
    local dateLabel = vgui.Create("DLabel", f)
    dateLabel:SetFont("HF4_Date"); dateLabel:SetTextColor(Color(138, 138, 138))
    dateLabel:SetText("-- --- ----"); dateLabel:SizeToContents()
    curX = curX - dateLabel:GetWide()
    dateLabel:SetPos(curX, HEADER_H/2 - 8); dateLabel:SetSize(dateLabel:GetWide(), 16)
    curX = curX - 12
    local sepLbl = vgui.Create("DLabel", f)
    sepLbl:SetFont("HF4_Date"); sepLbl:SetTextColor(Color(70, 70, 70))
    sepLbl:SetText("|"); sepLbl:SizeToContents()
    curX = curX - sepLbl:GetWide()
    sepLbl:SetPos(curX, HEADER_H/2 - 8); sepLbl:SetSize(sepLbl:GetWide(), 16)
    curX = curX - 12
    local timeLabel = vgui.Create("DLabel", f)
    timeLabel:SetFont("HF4_Time"); timeLabel:SetTextColor(Color(255, 255, 255))
    timeLabel:SetText("--:--"); timeLabel:SizeToContents()
    curX = curX - timeLabel:GetWide()
    timeLabel:SetPos(curX, HEADER_H/2 - 9); timeLabel:SetSize(timeLabel:GetWide(), 18)
    local function UpdateClock()
        if not IsValid(timeLabel) then timer.Remove("HF4_Clock") return end
        local t = os.date("*t")
        timeLabel:SetText(string.format("%02d:%02d", t.hour, t.min)); timeLabel:SizeToContents()
        dateLabel:SetText(string.format("%d %s %d", t.day, MONTHS[t.month], t.year)); dateLabel:SizeToContents()
    end
    timer.Create("HF4_Clock", 1, 0, UpdateClock)
    UpdateClock()
    -- Табы
    tabButtons = {}
    local ty = HEADER_H + 14
    for _, tab in ipairs(TABS) do
        local btn = vgui.Create("DButton", f)
        btn:SetPos(12, ty); btn:SetSize(SIDEBAR_W - 24, 42); btn:SetText("")
        btn.TabId = tab.id; btn.IsActive = (tab.id == currentTab)
        btn.Paint = function(self, w, h)
            if self.IsActive then draw.RoundedBox(2, 0, 0, w, h, Color(34, 34, 40))
            elseif self:IsHovered() then draw.RoundedBox(2, 0, 0, w, h, Color(28, 28, 28)) end
            if self.IsActive then surface.SetDrawColor(230, 57, 70); surface.DrawRect(0, 0, 3, h) end
            local tc = self.IsActive and Color(255,255,255) or Color(138,138,138)
            if self:IsHovered() and not self.IsActive then tc = Color(255,255,255) end
            draw.SimpleText(tab.label, self.IsActive and "HF4_TabA" or "HF4_Tab", 14, h/2, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            if tab.badge then
                surface.SetFont("HF4_Badge")
                local bw = surface.GetTextSize(tab.badge) + 14
                local bh = 18
                local bx = w - bw - 14
                local by = h/2 - bh/2
                local bg = self.IsActive and Color(230,57,70) or Color(48,48,48)
                local fg = self.IsActive and Color(255,255,255) or Color(138,138,138)
                draw.RoundedBox(2, bx, by, bw, bh, bg)
                draw.SimpleText(tab.badge, "HF4_Badge", bx + bw/2, by + bh/2, fg, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        btn.DoClick = function() SwitchTab(tab.id) end
        table.insert(tabButtons, btn)
        ty = ty + 48
    end
    -- Профиль
    local ply = LocalPlayer()
    local pname = ply:Nick()
    local pjob = string.upper(team.GetName(ply:Team()))
    local cash = FM(GetCash(ply))
    local bank = FM(GetBank(ply))
    local profileY = H - 100
    local pName = vgui.Create("DLabel", f)
    pName:SetPos(16, profileY); pName:SetSize(SIDEBAR_W - 32, 18)
    pName:SetFont("HF4_SName"); pName:SetTextColor(Color(255, 255, 255))
    pName:SetText(pname)
    local pJob = vgui.Create("DLabel", f)
    pJob:SetPos(16, profileY + 22); pJob:SetSize(SIDEBAR_W - 32, 16)
    pJob:SetFont("HF4_SJob"); pJob:SetTextColor(Color(230, 57, 70))
    pJob:SetText(pjob)
    local cashRow = vgui.Create("DPanel", f)
    cashRow:SetPos(16, profileY + 48); cashRow:SetSize(SIDEBAR_W - 32, 18)
    cashRow.Paint = function(self, w, h)
        surface.SetDrawColor(90, 90, 90); surface.DrawRect(0, h/2 - 5, 10, 10)
        draw.SimpleText("НАЛИЧКА", "HF4_Mini", 16, h/2, Color(90,90,90), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(cash, "HF4_MiniB", w, h/2, Color(230,57,70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    local bankRow = vgui.Create("DPanel", f)
    bankRow:SetPos(16, profileY + 72); bankRow:SetSize(SIDEBAR_W - 32, 18)
    bankRow.Paint = function(self, w, h)
        surface.SetDrawColor(90, 90, 90); surface.DrawRect(0, h/2 - 5, 10, 10)
        draw.SimpleText("БАНК", "HF4_Mini", 16, h/2, Color(90,90,90), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(bank, "HF4_MiniB", w, h/2, Color(74,222,128), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    SwitchTab(currentTab)
    f.OnClose = function()
        timer.Remove("HF4_Clock")
        _G.HoustonF4Frame = nil
        contentPanel = nil
    end
end
hook.Remove("ShowSpare2", "DarkRP_Menu")
hook.Remove("ShowHelp", "DarkRP_Menu")
hook.Remove("PlayerBindPress", "DarkRP_Menu")
hook.Remove("PlayerBindPress", "DarkRP_ShowMenu")
hook.Remove("PlayerBindPress", "darkrp_showmenu")
hook.Add("PlayerBindPress", "Houston_F4_Bind", function(ply, bind, pressed)
    if not pressed then return end
    if bind == "gm_showhelp" then OpenF4() return true end
end, -100)
hook.Add("ShowHelp", "Houston_F4_ShowHelp", function() OpenF4() return true end, -100)
concommand.Add("houston_f4", OpenF4)
print("[HOUSTON F4] Загружено.")
