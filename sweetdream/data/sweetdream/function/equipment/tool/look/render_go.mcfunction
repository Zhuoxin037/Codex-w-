# ============================================================
# sweetdream:equipment/tool/look/render_go —— 采集数值并画到动作栏(宏参数: {uuid})
# ------------------------------------------------------------
# 【显示顺序】攻击 / 生命 / 魔力 / 术阵 / 冷却
# 【数值来源】
#   攻击  players."<uuid>".stats.base_attack
#   生命  实体自身的 Health  /  players."<uuid>".stats.max_health
#   魔力  players."<uuid>".stats.current_mana / max_mana
#   术阵  manacore:api/formation/count 的 out r.count / r.limit
#   冷却  主手物品自带的 custom_data.skill -> players."<uuid>".cooldowns."<该技能>".end
#          减当前刻 #now。手里不是"带 skill 字段的武器"时显示 0。
# 【为什么冷却要先清零再读】没在冷却时那条路径不存在, data get 会失败,
#   计分项会保留上一次的旧值 —— 必须先手动归零。
# ============================================================

# ---- 攻击 / 生命 / 魔力 ----
# 【O02(2026-10-11)】★ 本函数现在是"每刻轻量层": 全部只读计分板/命令存储 ——
#   免序列化。以前这里的 `data get entity @s Health` 和 6 次 equip_scan、
#   SelectedItem.skill 判定都是每刻一次全玩家 NBT 序列化(spark 剖析最大热点),
#   全部挪到了 equipment/tool/look/cache(每秒, lib/second 调)。
$execute store result score #v_atk zx.meta run data get storage manacore:players "$(uuid)".stats.base_attack
scoreboard players operation #v_hp zx.meta = @s zx.hp_show
$execute store result score #v_hpmax zx.meta run data get storage manacore:players "$(uuid)".stats.max_health
$execute store result score #v_mana zx.meta run data get storage manacore:players "$(uuid)".stats.current_mana
$execute store result score #v_manamax zx.meta run data get storage manacore:players "$(uuid)".stats.max_mana

# ---- 术阵数量 / 上限(走前置包的接口, 它会遍历 8 个槽位) ----
# 【重要: 为什么要备份/还原】manacore:in arg 是全局共享的"输入口", 不是存档。
#   下面那行会把它整个覆盖成 {uuid:"..."}。以前没有备份/还原, 于是只要
#   观测镜开着, 每刻都会把别人(或你在聊天栏手动填进去)的参数冲掉 ——
#   症状就是 /data get storage manacore:in arg 只看得到 uuid。
#   现在改成"先用 zx:look.saved_in 备份现场, 查完术阵再原样放回去"。
execute if data storage manacore:in arg run data modify storage zx:look saved_in set from storage manacore:in arg
$data modify storage manacore:in arg set value {uuid:"$(uuid)"}
function manacore:api/formation/count
execute store result score #v_fcnt zx.meta run data get storage manacore:out r.count
execute store result score #v_flim zx.meta run data get storage manacore:out r.limit
execute if data storage zx:look saved_in run data modify storage manacore:in arg set from storage zx:look saved_in
execute if data storage zx:look saved_in run data remove storage zx:look saved_in

# ---- 冷却: 看"手上拿的那把武器"还剩多久 ----
# 【O02】skill 字段由 cache 每秒缓存(zx:look cache."<uuid>".skill), 这里只读存储。
# 【★ N07 修】必须读**自己 uuid 那份** —— 原来读全局单格, 多人开面板时会读到
#   别人手上的技能 id(拿它去查自己的冷却路径 ⇒ 显示无关技能/恒 0)。
#   空手 / 拿别的道具时该键不存在 ⇒ 走下面的守卫, 显示 0(和原来一致)。
data remove storage zx:work a.skill
$execute if data storage zx:look cache."$(uuid)".skill run data modify storage zx:work a.skill set from storage zx:look cache."$(uuid)".skill

scoreboard players set #v_cd zx.meta 0
scoreboard players set #v_end zx.meta 0
execute if data storage zx:work a.skill run function sweetdream:equipment/tool/look/cooldown_get with storage zx:work a

# ---- 附标: 在身 / 在手上的「层数机制」(接在冷却后面, 同一行) ----
# 【怎么拼】先把 xline 清空, 再扫 6 个槽位登记在身装备 (zx:work eq.<id>),
#   然后逐条 layer 表行打听(只有"那件在身 + 层数非 0"的才会往 xline 追加组件)。
# 【★ 为什么不再单独一行 ★】动作栏**只有一行**, 塞 "\n" 也不换行(2026-10-05 试过,
#   第二行不会出现)。所以层数改成接在冷却后面、用分隔符隔开, 全程一行。
#   分隔符怎么来: 第一条 layer 行 append 时会先看一眼"这是不是第一条"
#   (#ly_first 计数), 是就往 xline 最前面垫一个 " ｜ " 分隔符 —— 见 layer_row。
# 【谁判有没有层数】收尾看 xline 是否为空表: 空就不画, 非空就把 xline 接到尾巴上。
# ★ 为什么初值是 [{"text":""}] 而不是 [] ★
#   最后一小段是 {"nbt":"xline","storage":"zx:look","interpret":true} —— 它把读到的
#   NBT **解释成文本组件**, 而「空表」是**非法组件**(既不是字符串、也不是有内容的
#   列表、也不是 map) → 原版每读一次就抛一次 "Failed to parse component: []"
#   (2026-10-05 实测: 开着面板时**每刻一条**, 2 分半刷了 2458 条, latest.log 涨到 8.8M,
#   真正的报错全被埋在里面)。垫一个空 text 组件, 列表永远非空 → 不再解析失败,
#   而空文本渲染出来什么都不占, 和"没层数"时的样子完全一样。
#   ⚠️ 别把它改回 [] : check.py 规则 45(nbtempty) 专盯这条。
data remove storage zx:look xline
data modify storage zx:look xline set value [{"text":""}]
# 【O02】6 次 equip_scan 挪进 cache(每秒) —— 这里只把缓存的名单搬进 zx:work eq。
#   ↓↓↓ 原实现(每刻 6×"if data entity + data modify from entity" = 最多 12 次全玩家
#   NBT 序列化)整段保留在 cache.mcfunction 里, 这里只读缓存:
#   【★ N07 修】读**自己 uuid 那份**(cache."<uuid>".eq) —— 原来读全局单格, 多人时
#   会穿上别人身上的装备(装备专属段串人)。
data remove storage zx:work eq
$execute if data storage zx:look cache."$(uuid)".eq run data modify storage zx:work eq set from storage zx:look cache."$(uuid)".eq
scoreboard players set #ly_first zx.meta 1
# ---- 装备专属「段」: 值不是"常数上限"的机制, 走各自的段函数 ----
# 【为什么要这个】layer 表只会画「标签 当前值/上限」, 而且上限 `max` 是**写死的常数**
#   —— 一个装备只能有一个上限。这两类都不进表, 各开一个段函数自己往 xline 追加:
#     · 调色盘「色彩」: 存的是**色码**(1 红 / 2 黄 / 3 蓝), 摆个 "2/3" 等于没标;
#     · 炉心「燃灰」:   上限**随超限变**(基础 10 / 超限 12), 写死一个数必错一个。
#   ★ 顺序有讲究 ★
#     · 调色盘段要在 layer_unroll **之后**(它显示在最右);
#     · 炉心段要在 layer_unroll **之前** —— 它原本是 layer[0], 靠 #ly_first
#       抢到"层数段第一名"的位置, 放在后面会变成"层数段最后一名"。
#   (两段都复用 #ly_first 那套分隔符协议, 见 layer_row 头注释)
execute if data storage zx:work eq.furnace_core run function sweetdream:equipment/armor/furnace_core/look_seg

# ---- 层数段 ----
function sweetdream:lib/look/layer_unroll

# ---- 装备专属「文字型段」: 值不是数字的机制, 走各自的段函数 ----
# 【必须在 layer_unroll 之后】段与段靠 #ly_first 排先后; 放在层数段后面 = 显示在最右。
execute if data storage zx:work eq.palette run function sweetdream:equipment/staff/palette/look_seg

# ---- 画出来 ----
# 【一行怎么画】攻击/生命/魔力/术阵/冷却 + (有层数时)分隔符 + 层数。
#   没任何层数时 xline 是空表, 于是只画前面那几段。
# 【★ 为什么 xline 那一段必须带 "interpret":true ★】
#   {"nbt":...,"storage":...} 默认(interpret=false)是把读到的 NBT **当 SNBT 原样打印**
#   —— xline 是个组件列表, 于是屏幕上就把整个 JSON 一串(text 引号、color、score…)
#   照字面吐出来(2026-10-05 栽过, 屏幕上能看到 {"color":"gray","text":"燃灰 "},… 一串)。
#   加 "interpret":true 后, 服务器会**把读到的值直接解释成文本组件**;
#   而「列表」本身就是合法的文本组件写法(["A","B"] ≡ {text:"A",extra:["B"]}),
#   所以 xline 会被正确拼出来, 而不是被转成字符串。
title @s actionbar [{"text":"⚔ ","color":"gray"},{"score":{"name":"#v_atk","objective":"zx.meta"},"color":"white"},{"text":"   ❤ ","color":"red"},{"score":{"name":"#v_hp","objective":"zx.meta"},"color":"red"},{"text":"/","color":"dark_red"},{"score":{"name":"#v_hpmax","objective":"zx.meta"},"color":"dark_red"},{"text":"   ✦ ","color":"aqua"},{"score":{"name":"#v_mana","objective":"zx.meta"},"color":"aqua"},{"text":"/","color":"dark_aqua"},{"score":{"name":"#v_manamax","objective":"zx.meta"},"color":"dark_aqua"},{"text":"   ✡ ","color":"light_purple"},{"score":{"name":"#v_fcnt","objective":"zx.meta"},"color":"light_purple"},{"text":"/","color":"dark_purple"},{"score":{"name":"#v_flim","objective":"zx.meta"},"color":"dark_purple"},{"text":"   ⏳ ","color":"yellow"},{"score":{"name":"#v_cd","objective":"zx.meta"},"color":"gold"},{"text":"s","color":"gold"},{"nbt":"xline","storage":"zx:look","interpret":true}]

