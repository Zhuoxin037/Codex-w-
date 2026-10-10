# ============================================================
# sweetdream:equipment/sword/tinder/visual/sync —— 火种 · 按状态刷新手持外观
# ------------------------------------------------------------
# 【谁调用它】
#   ① tinder/second —— 每秒兜底：刚拿到剑 / 换到手 / 刚进世界, 1 秒内补上模型
#   ② tinder/burn   —— 燃烧态打完那一下**熄灭**的当刻, 立刻换回熄灭外观
#   ③ tinder/dark   —— 熄灭态打完那一下**点燃**的当刻, 立刻换成燃烧外观
# 【执行者】施法者(玩家)
# 【做什么】按玩家级状态 zx.td_on(1=燃烧 / 0=熄灭) 把主手/副手那把火种的
#   item_model 改成 sweetdream:tinder_on / sweetdream:tinder_off。
#
# 【★ 为什么需要它 ★】
#   火种在数据包里就是一把 netherite_sword, 本来**没有独立模型**。
#   技能原文的两态(燃烧 / 熄灭)要"看起来不一样", 就得让外观跟着状态走 ——
#   两条 items 定义写在资源包 sweetdream_rp_原版风(合并版里也有)里, 这里只负责切。
#
# 【★ 守卫: 已经是目标外观就不写组件 ★】
#   `unless items … item_model="…"` 先判一次, 避免每秒重复 set_components。
#   组件即使值相同也会被当成"变了一次" ⇒ 配合 items/*.json 里的
#   hand_animation_on_swap:false 才不会在手上抽搐(见资源包 README)。
#
# 【★ 只改 item_model ★】
#   不碰 lore / 升级数据 / custom_data / 技能数据 —— 照抄 staff_icon_held 的口径。
#
# 【★ 认人只认 custom_data~{zx:["tinder"]}, 不认底物 ★】
#   和全包其它装备一致: netherite_sword 是很多武器共用的底物, 不能当身份。
#
# 【★ 判据为什么用 unless … matches 1 而不是 if … matches 0 ★】
#   没有这个分数的玩家(从没点燃过)本来是"熄灭态" —— `if score … matches 0` 对
#   "分数不存在"恒为假, 会把新剑判成"非熄灭"而不刷外观。见 RULES 的 selfclr。
# ============================================================

# —— 燃烧态 ——
execute if score @s zx.td_on matches 1 if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["tinder"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:tinder_on"] run item modify entity @s weapon.mainhand sweetdream:tinder_visual/on
execute if score @s zx.td_on matches 1 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tinder"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tinder_on"] run item modify entity @s weapon.offhand sweetdream:tinder_visual/on

# —— 熄灭态（没有分数 = 从未点燃过 = 熄灭）——
execute unless score @s zx.td_on matches 1 if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["tinder"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:tinder_off"] run item modify entity @s weapon.mainhand sweetdream:tinder_visual/off
execute unless score @s zx.td_on matches 1 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tinder"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tinder_off"] run item modify entity @s weapon.offhand sweetdream:tinder_visual/off
