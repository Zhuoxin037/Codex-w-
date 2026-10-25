# ============================================================
# sweetdream:equipment/armor/zhuzu/open_summon —— 生成领域 marker（宏）
# ------------------------------------------------------------
# 【宏参数】sweetdream:work zz {u0,u1,u2,u3} = 使用者的 UUID 四个 int
# 【★ 为什么用 summon 宏而不是 summon 字面量】UUID 只能从实体读出来，
#   选择器里写不进 UUID 文本 ⇒ 必须拼到 NBT 里。参考 thunder_wedge/wedge_one。
# ============================================================
$summon minecraft:marker ~ ~ ~ {Tags:["zx.zz_field","zx.zz_new"],data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}
scoreboard players set @e[type=marker,tag=zx.zz_new,distance=..2,limit=1] zx.zz_ft 10
scoreboard players operation @e[type=marker,tag=zx.zz_new,distance=..2,limit=1] zx.zz_own = #zz_me zx.meta
tag @e[type=marker,tag=zx.zz_new,distance=..2] remove zx.zz_new
