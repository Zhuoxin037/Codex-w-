# ============================================================
# sweetdream:equipment/sword/yebu/ol_bind_dim —— 单维度: 到点的移速惩罚当场摘
# ------------------------------------------------------------
# 【谁调用它】yebu/ol_bind_sweep(三个维度各一次)
# 【★ distance=0.. 不是过滤条件 ★】裸 @e 在这个包里曾经跨维度搜索(unfreeze_sweep
#   头注释记的事故), 加 distance=0.. 是把搜索锁进当前维度; 它不过滤任何生物。
# ============================================================
execute as @e[tag=zx.yb_bind,distance=0..] if score @s zx.yb_be <= #now manacore.meta run function sweetdream:equipment/sword/yebu/ol_bind_end
