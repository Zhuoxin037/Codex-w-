# ============================================================
# sweetdream:equipment/armor/ebb_tide/entity_reset —— 清掉生物身上返汐的全部残留
# ------------------------------------------------------------
# 【执行者】任意实体(@s)（由 core/load 三维度 @e[distance=0..] 广播）
# 【★ 为什么要这个函数 ★】et_e / et_du / et_on / et_wid / et_ok / et_px/py/pz 全打在
#   **生物**身上 ⇒ 实体死了/卸载了分数也**永久留在存档**(铁律)。下一只新怪被分配
#   同一个 wid 就会"凭空带着 30 档减速"。
# 【★ 不挂任何判死逻辑 ★】这里只清分数, 什么都不判 —— 残留绝不能误杀。
# ============================================================

scoreboard players reset @s zx.et_e
scoreboard players reset @s zx.et_du
scoreboard players reset @s zx.et_on
scoreboard players reset @s zx.et_wid
scoreboard players reset @s zx.et_ok
scoreboard players reset @s zx.et_px
scoreboard players reset @s zx.et_py
scoreboard players reset @s zx.et_pz
