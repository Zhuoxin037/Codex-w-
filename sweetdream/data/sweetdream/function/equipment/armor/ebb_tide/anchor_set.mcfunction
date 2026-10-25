# ============================================================
# sweetdream:equipment/armor/ebb_tide/anchor_set —— 记下"上次补片"的锚点
# ------------------------------------------------------------
# 【执行者】那只生物(@s)
# 【★ 这三个分数打在**生物**身上 ⇒ 永久留存档(铁律), core/load 三维度兜底清。
# ============================================================

execute store result score @s zx.et_px run data get entity @s Pos[0] 100
execute store result score @s zx.et_py run data get entity @s Pos[1] 100
execute store result score @s zx.et_pz run data get entity @s Pos[2] 100
scoreboard players set @s zx.et_ok 1
