# ============================================================
# sweetdream:debug/lightning_probe —— 「闪电链」现场诊断(只读)
# ------------------------------------------------------------
# 【用法】① 开超限负离子技能 → ② 换引雷针普攻打中怪 → ③ 等 2 秒 →
#         /function sweetdream:debug/lightning_probe
#   (想单独测雷鸣: 副手雷鸣 + 主手引雷针, 打一发, 看「雷鸣连锁」那两行)
# 【为什么需要它】这条链一共有 **8 个**可能断掉的地方, 断在任何一处的表现
#   都是"没有额外伤害"、而且**零日志** —— 只能靠计数锚定位。
# ============================================================
#   ● 引雷针普攻(bolt_atk)一级:
#     dbg0 雷劈下来了(函数被调用)
#     ★ 2026-10-13: 引雷针已**只降雷、无自身伤害**(原 当前魔力 ×0.03 砍掉),
#       dbg1/dbg2/dbg3(伤害 / 2 格内目标数 / 已结算)随数值一起删了。
#       现在只判 dbg0 涨没涨 = 那一道雷到底劈出来没有。
# ============================================================
#   ● 跨武器落点伤害(on_lightning → ol_bonus)四级:
#     an_dbg0 钩子被调用(不管窗口开没开)
#     an_dbg1 进窗口了(zx.an_boost > 0)
#     an_dbg2 落点 2 格内圈到生物
#     an_dbg3 伤害已结算
#   ⇒ 判读: dbg0 涨而 dbg1 不涨 = 雷劲窗口没开(看下面"雷劲"那一行);
#            dbg1 涨而 dbg2 不涨 = 雷劈在空地上/离怪太远。
# ============================================================
#   ● 雷鸣(tool/thunder)两级:
#     th_dbg0 场上抓到过"新闪电"(core/tick → strike)
#     th_dbg1 真的登记了连锁(6 格内有持雷鸣的玩家)
#   ⇒ dbg0 涨而 dbg1 不涨 = 副手那件不是雷鸣 / 你离那道雷超过 6 格。
# ============================================================
# 【只读】只写 zx.meta 上的 #*_dbg* 假玩家, 不动任何游戏状态。
# ============================================================

tellraw @s [{"text":"===== 闪电链诊断 =====","color":"gold"}]

# ---- ⓪ 手上/副手是什么 ----
tellraw @s [{"text":" 主手: ","color":"yellow"},{"nbt":"SelectedItem.components.\"minecraft:custom_data\".zx[0]","entity":"@s","interpret":false},{"text":"   副手: ","color":"yellow"},{"nbt":"Inventory[{Slot:-106b}].components.\"minecraft:custom_data\".zx[0]","entity":"@s","interpret":false}]
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunder"]}] run tellraw @s [{"text":"   ✔ 副手是「雷鸣」—— 具备连锁条件","color":"green"}]
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunder"]}] run tellraw @s [{"text":"   ✘ 副手不是「雷鸣」—— 不会有任何连锁","color":"red"}]

# ---- ① 雷劲窗口(超限·负离子的 8 秒) ----
tellraw @s [{"text":" 【雷劲】zx.an_boost(还剩几秒) = ","color":"aqua"},{"score":{"name":"*","objective":"zx.an_boost"},"color":"aqua"}]
execute if score @s zx.an_boost matches ..0 run tellraw @s [{"text":"   ✘ 窗口没开: 8 秒已过, 或放技能时手里不是**超限版**负离子(看下面)","color":"red"}]
execute if score @s zx.an_boost matches 1.. run tellraw @s [{"text":"   ✔ 窗口开着 —— 这期间你自己劈的雷都该带落点伤害","color":"green"}]
execute if items entity @s weapon.mainhand *[custom_data~{zx:["anion"],ol:"anion"}] run tellraw @s [{"text":"   ✔ 主手是超限·负离子","color":"green"}]
execute if items entity @s weapon.offhand *[custom_data~{zx:["anion"],ol:"anion"}] run tellraw @s [{"text":"   ✔ 副手是超限·负离子","color":"green"}]

# ---- ② 引雷针普攻(只降雷, 无自身伤害) ----
tellraw @s [{"text":" 【引雷针·普攻】劈雷次数 ","color":"light_purple"},{"score":{"name":"#tr_dbg0","objective":"zx.meta"}},{"text":"（该件只降雷, 无自身伤害）","color":"dark_gray"}]
execute if score #tr_dbg0 zx.meta matches ..0 run tellraw @s [{"text":"   ✘ 一次都没劈过 ⇒ 用法是**普通右键**发法球、命中怪之后 1 秒才落雷(不是潜行右键)","color":"red"}]

# ---- ③ 跨武器落点伤害四级 ----
tellraw @s [{"text":" 【跨武器·落点】钩子 ","color":"light_purple"},{"score":{"name":"#an_dbg0","objective":"zx.meta"}},{"text":" → 进窗口 ","color":"light_purple"},{"score":{"name":"#an_dbg1","objective":"zx.meta"}},{"text":" → 圈到生物 ","color":"light_purple"},{"score":{"name":"#an_dbg2","objective":"zx.meta"}},{"text":" → 已结算 ","color":"light_purple"},{"score":{"name":"#an_dbg3","objective":"zx.meta"}}]
execute if score #an_dbg0 zx.meta matches 1.. if score #an_dbg1 zx.meta matches ..0 run tellraw @s [{"text":"   ✘ 钩子跑了但窗口没开 ⇒ 先放超限负离子技能, 再在 8 秒内劈雷","color":"red"}]

# ---- ④ 雷鸣两级 ----
tellraw @s [{"text":" 【雷鸣】抓到新雷 ","color":"light_purple"},{"score":{"name":"#th_dbg0","objective":"zx.meta"}},{"text":" → 登记连锁 ","color":"light_purple"},{"score":{"name":"#th_dbg1","objective":"zx.meta"}}]
execute if score #th_dbg0 zx.meta matches 1.. if score #th_dbg1 zx.meta matches ..0 run tellraw @s [{"text":"   ✘ 抓到雷但没登记 ⇒ 那道雷劈下来时你在 6 格之外, 或那时副手还不是雷鸣","color":"red"}]

# ---- ⑤ 待落的雷(引雷针预约中 / 雷鸣预约中) ----
execute if entity @e[tag=zx.tr_pend,distance=0..] run tellraw @s [{"text":"   引雷针有已预约、还没落下的雷(1 秒延迟, 正常)","color":"yellow"}]
execute if entity @e[tag=zx.th_pend,distance=0..] run tellraw @s [{"text":"   雷鸣有已预约、还没落下的连锁雷(1 秒延迟, 正常)","color":"yellow"}]
tellraw @s [{"text":"===== 诊断结束 (锚是累计值, 重开世界才归零) =====","color":"gold"}]
