# ============================================================
# sweetdream:lib/second —— 公共件们的每秒入口(挂在 #manacore:event/second)
# ------------------------------------------------------------
# 【备份公共输入口】下面这些都会读/写 manacore:in arg, 见 lib/in_bak。
# ============================================================

# 【进度的安全网不在这里】lib/rearm 是"每刻"跑的, 挂在 core/tick 最前面, 不挂这里
#   —— 理由见那两个文件; 别在本文件里再调一次(会变成每刻 + 每秒各一次, 无意义)。

function sweetdream:lib/in_bak

# 冻结/时停到点解冻
# 流光: 每秒扫"到点结算"的人 —— 取代一次性 schedule, 多人同时施法不会互相顶掉(第 3 条)
execute as @a[tag=zx.lg_casting] at @s run function sweetdream:equipment/sword/liuguang/hit_self
# 超限·流光: 同上, 每秒扫"到点结算"的人(4 个目标的延迟伤害)
execute as @a[tag=zx.lgo_casting] at @s run function sweetdream:equipment/sword/liuguang/ol_hit_self

# 深海: 正在施法的人每秒补画一次范围环(同上)
execute if entity @a[tag=zx.de_run] run function sweetdream:equipment/sword/deepsea_echo/fx

# 升级: 穿着的盔甲上的升级(魔力上限 / 每秒回魔) —— 见 upgrade/second
function sweetdream:upgrade/second

function sweetdream:lib/unfreeze_sweep

# 魔力上限下限保护 —— 必须放在所有装备结算之后(脑髓蛭/脊骨共生会把上限算成负数)
execute as @a run function sweetdream:lib/mana_floor

function sweetdream:lib/in_restore
