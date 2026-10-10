# ============================================================
# sweetdream:equipment/staff/begonia/vortex_end —— 漩涡消失: 结算 + 渊海收尾
# ------------------------------------------------------------
# 【谁调用它】vortex_tick 第 ④ 步(寿命归 0); 【执行者/位置】漩涡 item_display
# 【基础版(lore 逐字)】漩涡消失后会对处于中心的生物造成相当于释放者最大魔力值
#   ×0.15 的伤害。之后清除「渊海」。
# 【超限版(超限·海棠, 2026-10-10 实装)】"爆炸后会对漩涡内全部生物造成相当于
#   自身最大魔力值 ×0.25 的伤害并使处于中心的生物附加「渊海」，之后该技能
#   冷却时间 -12 秒。"
#   · 伤害: 中心 2 格 ×0.15 -> **漩涡内(6 格)全部 ×0.25**;
#   · 「渊海」: 清除(基础) -> **给中心 2 格内的生物附加**(超限; 原文没写清除,
#     且"附加"正是为了让中心那只还能被下一轮技能选中 —— 漩涡链的钩子);
#   · 冷却: 结算那一刻把 sweetdream:begonia 的剩余冷却 -12 秒。
# 【"处于中心的生物"= 中心 2 格内的生物】(两版同口径)
# 【伤害口径】释放者最大魔力 -> max_mana_mul 通道; 执行者是 item_display(不是玩家), 用
#   它 data.zx.bg 里存的释放者 uuid 查面板, 归属用 u0..u3(和 color_hit 同款)。
#   ★ 2026-10-10 修 F13: **算伤害那一步的执行者换成释放者本人**(见 ② 与
#     internal/damage/calc_as_owner) —— 否则 damage_calc 事件里"玩家限定"的加算
#     hook 全被跳过, 漩涡伤害吃不到主人的装备加成。
# 【清「渊海」走统一入口】让余烬/永恒的消耗被动收得到信号; 附加走 tag/mark 公共接口。
# 【超限分支读哪】自己 data.zx.bg.ol(施法那刻拍进来的快照, 见 skill ①'/⑦)。
# ============================================================

# ① 圈人: 两份名单分开 —— 伤害名单(基础=中心2格 / 超限=6格全部) + 中心名单(渊海收尾用)
tag @e[tag=zx.bg_cen,distance=0..] remove zx.bg_cen
tag @e[tag=zx.bg_all,distance=0..] remove zx.bg_all
execute unless data entity @s data.zx.bg{ol:1b} run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.bg_cen
execute unless data entity @s data.zx.bg{ol:1b} run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.bg_all
execute if data entity @s data.zx.bg{ol:1b} run tag @e[type=!#sweetdream:no_damage,distance=..6] add zx.bg_all
execute if data entity @s data.zx.bg{ol:1b} run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.bg_cen

# ② 算伤害: 释放者最大魔力 ×0.15(基础) / ×0.25(超限)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.15}
execute if data entity @s data.zx.bg{ol:1b} run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.25}
data modify storage manacore:in arg.uuid set from entity @s data.zx.bg.uuid
# ★ 2026-10-10 修 F13: 以"释放者本人"的身份算, 而不是漩涡 item_display ——
#   否则 damage_calc 事件里"玩家限定"的加算 hook(升级增伤/共振/漫步/桂冠…)全被
#   跳过, 漩涡收尾伤害吃不到主人的装备加成(见 internal/damage/calc_as_owner)。
#   uuid 四段放独立节点 zx:work co, 免得污染 ③ 要用的 zx:work a。
data modify storage zx:work co set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work co.u0 set from entity @s data.zx.bg.u0
data modify storage zx:work co.u1 set from entity @s data.zx.bg.u1
data modify storage zx:work co.u2 set from entity @s data.zx.bg.u2
data modify storage zx:work co.u3 set from entity @s data.zx.bg.u3
function sweetdream:internal/damage/calc_as_owner with storage zx:work co

# ③ 打成伤害(归属 = 释放者; 目标 = 基础中心 / 超限全部)
data modify storage zx:work a set value {target:"@e[tag=zx.bg_cen]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
execute if data entity @s data.zx.bg{ol:1b} run data modify storage zx:work a.target set value "@e[tag=zx.bg_all]"
data modify storage zx:work a.damage set from storage manacore:out r.damage
data modify storage zx:work a.u0 set from entity @s data.zx.bg.u0
data modify storage zx:work a.u1 set from entity @s data.zx.bg.u1
data modify storage zx:work a.u2 set from entity @s data.zx.bg.u2
data modify storage zx:work a.u3 set from entity @s data.zx.bg.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 「渊海」收尾
#   基础: 清除中心 2 格内带渊海的生物(走统一入口, 让消耗型被动收得到信号)
execute unless data entity @s data.zx.bg{ol:1b} run data modify storage zx:work a set value {target:"@e[tag=zx.bg_cen,tag=zx.status.yuanhai]",mark:"yuanhai"}
execute unless data entity @s data.zx.bg{ol:1b} run function sweetdream:lib/mark_consume
#   超限: 给中心 2 格内**还没带**渊海的生物附加(带了的不再打 —— 免得图标实体重复)
execute if data entity @s data.zx.bg{ol:1b} run data modify storage zx:work ic set value {target:"@e[tag=zx.bg_cen,tag=!zx.status.yuanhai]",mark:"yuanhai"}
execute if data entity @s data.zx.bg{ol:1b} run function sweetdream:tag/mark with storage zx:work ic

# ④' 超限: 该技能冷却时间 -12 秒(结算那一刻减; 归属 = 漩涡记着的释放者)
execute if data entity @s data.zx.bg{ol:1b} run data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:begonia",seconds:12.0}
execute if data entity @s data.zx.bg{ol:1b} run data modify storage manacore:in arg.uuid set from entity @s data.zx.bg.uuid
execute if data entity @s data.zx.bg{ol:1b} run function manacore:api/cooldown/reduce

# ⑤ 表现 + 收尾
particle minecraft:nautilus ~ ~0.5 ~ 1.5 0.6 1.5 0.05 24 normal
particle minecraft:splash ~ ~0.5 ~ 1.5 0.5 1.5 0.02 30 normal
playsound minecraft:entity.elder_guardian.hurt player @a ~ ~ ~ 0.7 1.0
tag @e[tag=zx.bg_cen,distance=0..] remove zx.bg_cen
tag @e[tag=zx.bg_all,distance=0..] remove zx.bg_all
kill @s
