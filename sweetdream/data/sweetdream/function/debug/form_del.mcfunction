# ============================================================
# sweetdream:debug/form_del —— 给自己 -1 个术阵(调试用)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/form_del      (以玩家身份执行)
#   菜单里也有: /trigger zx.dbg_menu -> 「自己的术阵 -1」
# 【摘哪一个】**最后一个非空槽位**(编号最大的那个), 不管它是谁建的 ——
#   技能建的(风行 wg_0 / 超•负•荷 charge)和调试建的(dbg_N)一视同仁。
#   这样"按几次 -1 就真的归零"永远成立, 不会出现"我删了但数量没变"。
# 【为什么不像 +1 那样只摘 dbg_ 开头的】只摘自己建的会留下一堆真术阵,
#   调试时反而是障碍 —— 这里要的就是"把数量压下去"。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"还没注册完成(uuid 是空的), 等一秒再试","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work fm set value {uuid:"",i:0}
data modify storage zx:work fm.uuid set from storage zx:data self.uuid

# ① 找最后一个非空槽位(#fm_slot; -1 = 一个术阵都没有)
function sweetdream:debug/form_pick_last with storage zx:work fm
execute if score #fm_slot zx.meta matches -1 run tellraw @s [{"text":"[术阵] 现在就是 0 个, 没什么可摘的","color":"red"}]
execute if score #fm_slot zx.meta matches -1 run return 0

# ② 摘掉它
execute store result storage zx:work fm.i int 1 run scoreboard players get #fm_slot zx.meta
function sweetdream:debug/form_del_go with storage zx:work fm
