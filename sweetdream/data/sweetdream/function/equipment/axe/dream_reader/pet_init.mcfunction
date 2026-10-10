# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_init —— 新生的“入梦体”初始化
# ------------------------------------------------------------
# 【谁调用它】pet_spawn(`as @e[tag=zx.dr_new,distance=..2,limit=1]`)
# 【执行者】那个刚 summon 出来的 marker(入梦体)
# 【做什么】① 设 30 秒安全寿命(600 tick, core/tick 每刻 -1)
#           ② 读自己的 data.zx.ol —— 是 1 就打 tag `zx.dr_ol`(入梦体侧全靠这个 tag 分支)
# 【为什么把 ol 拷成 tag】pet_tick / pet_hit 里要按"超限与否"分支, 而它们**不是宏函数**,
#   拿不到施法那刻的变量; NBT 判 `nbt={data:{zx:{ol:1b}}}` 又太长且不好读 ⇒ 落成 tag 最省。
#   ★ 读不到(字段不存在)时 store 不执行, #dr_ol 保持刚 set 的 0 -> 走基础版, 安全。
# ============================================================

# ① 安全寿命
scoreboard players set @s zx.dr_life 600

# ② 超限标记
scoreboard players set #dr_ol zx.meta 0
execute store result score #dr_ol zx.meta run data get entity @s data.zx.ol 1
execute if score #dr_ol zx.meta matches 1 run tag @s add zx.dr_ol
