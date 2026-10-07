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
$execute store result score #v_atk zx.meta run data get storage manacore:players "$(uuid)".stats.base_attack
execute store result score #v_hp zx.meta run data get entity @s Health
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
# 【为什么改成看主手物品】以前记的是"最近放过的技能", 于是你切到别的武器,
#   面板上还挂着上一把的冷却, 很别扭。现在直接读主手物品自带的 custom_data.skill:
#     手里是带 skill 的武器 -> 显示它那条冷却
#     其他(空手 / 观测镜 / 别的道具) -> 显示 0
# 【为什么不会报错】空手时 SelectedItem 整个不存在, 主手是别的道具时没有 skill
#   这个字段 —— 两种情况都被下面那句 if data 守卫挡住, 不会让函数中断。
# 【观测镜自己】它是 paper, 身上没有 skill 字段, 所以拿着它时显示 0(符合预期)。
data remove storage zx:work a.skill
execute if data entity @s SelectedItem.components."minecraft:custom_data".skill run data modify storage zx:work a.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill

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
data remove storage zx:work eq
scoreboard players set #ly_first zx.meta 1
function sweetdream:debug/equip_scan {p:"SelectedItem"}
function sweetdream:debug/equip_scan {p:"equipment.offhand"}
function sweetdream:debug/equip_scan {p:"equipment.head"}
function sweetdream:debug/equip_scan {p:"equipment.chest"}
function sweetdream:debug/equip_scan {p:"equipment.legs"}
function sweetdream:debug/equip_scan {p:"equipment.feet"}
function sweetdream:lib/look/layer_unroll

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

