# ============================================================
# sweetdream:equipment/armor/stellar_elegy/second —— 每秒入口
# ------------------------------------------------------------
# 【★ 必须 at @s ★】只写 execute as 只换执行者, 位置还是服务器的(世界出生点),
#   里面任何 distance 都会算错。(风行回响、超•负•荷 都栽过这个坑)
# 【备份公共输入口】下面会写 manacore:in arg, 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

# ① 被动: 穿着就 +280 上限(差值账本)
execute as @a run function sweetdream:equipment/armor/stellar_elegy/passive

# ② 受击后的"每秒回 10 魔力", 持续 5 秒
execute as @a[scores={zx.se_regen=1..}] at @s run function sweetdream:equipment/armor/stellar_elegy/regen

function sweetdream:lib/in_restore
