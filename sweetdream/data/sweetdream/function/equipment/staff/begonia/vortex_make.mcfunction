# ============================================================
# sweetdream:equipment/staff/begonia/vortex_make —— 在"这只生物"处生成一个漩涡
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑧ 步: execute as @e[tag=zx.bg_src] at @s run ...
# 【执行者/位置】被选中的「渊海」生物(位置 = 它脚下)
# 【参数来源】zx:work bgv = {uuid,u0..u3}(释放者), 直接整份抄进实体的 data.zx.bg
#   ★ 这里不用宏: `set from storage` 会把值拷过去, 不需要拼字符串。
# 【寿命】zx.bg_t = 8(秒), 由 begonia/second -> vortex_tick 每秒 -1, 到 0 收尾。
# 【★ 2026-10-08 从 marker 换成 item_display ★】
#   用户: "把漩涡替换为 display 贴图…我希望是一个蓝色的漩涡, 不要和暗潮/暗海相同"。
#   · 模型 sweetdream:vortex = 横平面贴地(元素 y 8..9, 照暗海/暗潮),
#     ★ item_model 值写 **items/ 下的定义名**(sweetdream:vortex), 不是 item/ 下的几何名 ——
#       它解析到 `assets/sweetdream/items/vortex.json`(sea/tide/withered_wood 同款)。
#     贴图 24 帧旋转蓝色三臂涡旋(见 .workbuddy/_gen_staff_fx.py, 不与暗潮波纹/暗海湖泊撞)。
#   · ★ 2026-10-08 修正 scale: 5.0f -> 8.0f ★
#     用户: "你这个贴图完全不符合半径4格的漩涡大小吧(难道说你算的是总4格?)"。
#     技能文案是「漩涡每秒都会将 **4 格内** 的全部生物拉回中心」= **半径 4** ⇒ 直径应为 8。
#     口径锚点 = 暗海: 「物品模型 [0,16] 以实体位置为中心, scale N → 平面直径 N 格」
#     (暗海主片「半径 3 ⇒ scale 0.6f…直径 6」同款, 1:1)。故此处 scale = 8.0f ⇒ 直径 8 = 半径 4。
#     (老版 5.0f = 直径 5 = 半径 2.5, 只画到伤害核那一圈, 比吸附范围小一大截 —— 就是用户看到的"不符"。)
#   · translation y +0.02 抬离地面防闪面。
#   · 逻辑照旧: 坐标 = 位置真相; data.zx.bg 存归属(display 实体同样吃 `data`, 见 RULES §48)。
# ============================================================

summon minecraft:item_display ~ ~ ~ {Tags:["zx.bg_vtx","zx.bg_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:vortex"}},brightness:{sky:6,block:6},interpolation_duration:0,transformation:{translation:[0.0f,0.02f,0.0f],scale:[8.0f,1.0f,8.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
data modify entity @n[limit=1,tag=zx.bg_new] data.zx.bg set from storage zx:work bgv
# 超限: 漩涡范围扩大为 6 格 => 直径 12(scale = 直径, 与"范围 4 格 => 直径 8"同口径)
execute if data entity @n[limit=1,tag=zx.bg_new] data.zx.bg{ol:1b} run data modify entity @n[limit=1,tag=zx.bg_new] transformation.scale set value [12.0f,1.0f,12.0f]
scoreboard players set @n[limit=1,tag=zx.bg_new] zx.bg_t 8
tag @n[limit=1,tag=zx.bg_new] remove zx.bg_new
