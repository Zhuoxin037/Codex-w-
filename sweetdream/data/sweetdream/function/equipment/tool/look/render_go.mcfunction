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

# ---- 画出来 ----
title @s actionbar [{"text":"⚔ ","color":"gray"},{"score":{"name":"#v_atk","objective":"zx.meta"},"color":"white"},{"text":"   ❤ ","color":"red"},{"score":{"name":"#v_hp","objective":"zx.meta"},"color":"red"},{"text":"/","color":"dark_red"},{"score":{"name":"#v_hpmax","objective":"zx.meta"},"color":"dark_red"},{"text":"   ✦ ","color":"aqua"},{"score":{"name":"#v_mana","objective":"zx.meta"},"color":"aqua"},{"text":"/","color":"dark_aqua"},{"score":{"name":"#v_manamax","objective":"zx.meta"},"color":"dark_aqua"},{"text":"   ✡ ","color":"light_purple"},{"score":{"name":"#v_fcnt","objective":"zx.meta"},"color":"light_purple"},{"text":"/","color":"dark_purple"},{"score":{"name":"#v_flim","objective":"zx.meta"},"color":"dark_purple"},{"text":"   ⏳ ","color":"yellow"},{"score":{"name":"#v_cd","objective":"zx.meta"},"color":"gold"},{"text":"s","color":"gold"}]
