# -*- coding: utf-8 -*-
"""批 20-D：独行 hook 拆分（加算 / 独立），承的 hook 已就位"""
import io, os, sys
sys.stdout.reconfigure(encoding='utf-8')
FN = r'D:/数据包/sweetdream/data/sweetdream/function/equipment/armor/lone_walk'

F = {}
F['hook_add.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/lone_walk/hook_add —— 「独行」被动 +8%（加算池）
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc，排在 lib/dmg_add_apply **之前**
#   （加算池必须先填好，apply 才有东西可并）。
# 【执行者】施法者（玩家）
# 【★ 为什么不写在 hook_calc 里 ★】hook_calc 挂在 dmg_add_apply **之后**（独立乘区），
#   那时候加算池已经并进伤害了，再往里写不会有任何效果（静默失效）。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.lw_on matches 1 run return 0

scoreboard players set #lw_8 zx.meta 8
data modify storage zx:work put set value {ch:"mm",pct:0}
execute store result storage zx:work put.pct int 1 run scoreboard players get #lw_8 zx.meta
function sweetdream:lib/dmg_add_put with storage zx:work put

data modify storage zx:work put.ch set value "atk"
function sweetdream:lib/dmg_add_put with storage zx:work put

data modify storage zx:work put.ch set value "oth"
function sweetdream:lib/dmg_add_put with storage zx:work put
'''

F['hook_calc.mcfunction'] = r'''# @calc: indep — 套装「临敌」+10% 独立乘区
# ============================================================
# sweetdream:equipment/armor/lone_walk/hook_calc —— 「临敌」的 10% 独立乘区
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc（排在 lib/dmg_add_apply 之后）
# 【执行者】施法者（玩家）
# 【★ 占位 / 加算分工 ★】
#   · 被动"+8%"（没写独立乘区）⇒ lone_walk/hook_add（加算池，apply 之前）；
#   · 套装"+10%（独立乘区）"⇒ 本文件（乘最终 r.damage）。
#   两个文件挂在不同位置，**不要合并**（合并就必然有一个时机错）。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.lw_lc > #now manacore.meta run return 0

scoreboard players set #lwc zx.meta 0
execute store result score #lwc zx.meta run data get storage manacore:out r.damage 1000
scoreboard players set #lwk zx.meta 110
function manacore:internal/damage/mul_pct {src:"#lwc",mul:"#lwk",obj:"zx.meta"}
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mul_out zx.meta
'''

# add8.mcfunction 的内容已并入 hook_add，删掉旧文件避免"两处同名逻辑"
old = os.path.join(FN, 'add8.mcfunction')
if os.path.exists(old):
    os.remove(old)
    print('removed add8.mcfunction')

for rel, txt in F.items():
    p = os.path.join(FN, rel)
    with io.open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(txt)
    print('wrote', rel)
