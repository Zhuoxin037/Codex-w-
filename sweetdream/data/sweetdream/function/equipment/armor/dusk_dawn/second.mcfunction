# ============================================================
# sweetdream:equipment/armor/dusk_dawn/second —— 每秒入口
# ------------------------------------------------------------
# 【★ 必须 at @s ★】只写 execute as 位置还是服务器的, 里面所有相对判定都会错。
# 【备份公共输入口】下面到处在写 manacore:in arg, 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

# ① 被动 + 套装(上限 +180 / +200)
execute as @a run function sweetdream:equipment/armor/dusk_dawn/passive

# ② 魔力低于一半 -> 每秒回 20
execute as @a at @s run function sweetdream:equipment/armor/dusk_dawn/low_mana

# ③ 击杀后的临时上限倒计时(8 秒)
execute as @a[scores={zx.dd_temp=1..}] at @s run function sweetdream:equipment/armor/dusk_dawn/temp_tick

# ④ 套装: 每 3 秒恢复 1% 魔力(用全局秒号 % 3 判定, 所有人同拍, 省一套计分项)
scoreboard players operation #m3 zx.meta = #sec manacore.meta
scoreboard players operation #m3 zx.meta %= #3 zx.meta
execute if score #m3 zx.meta matches 0 as @a[tag=zx.dd_set_on] at @s run function sweetdream:equipment/armor/dusk_dawn/set_regen

# ⑤ 【2026-10-12 坑 138 起删除】这里原本给"穿着但没挂附魔的老靴子"补挂
#   `sweetdream:dusk_dawn` 监听附魔。整套附魔机制已废弃 ——
#   原版 post_attack **只读攻击者的主手物品**上的附魔, 挂在靴子(slots:feet)上
#   永远不触发, 所以那套回调从来没跑过。计数改由 5 条标签进度完成, 见 kill_mark。
#   老靴子上残留的那个附魔无害(不触发 / tooltip 已隐藏 / 无光效), 不必清理。

function sweetdream:lib/in_restore
