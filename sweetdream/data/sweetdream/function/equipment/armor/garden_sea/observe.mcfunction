# ============================================================
# sweetdream:equipment/armor/garden_sea/observe —— 枯枝园/无光海的施放观察者
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/cooldown_start(前置包在每次技能冷却开始时抛出;
#   本包所有主动技能都在"扣完蓝之后"才记冷却 → 此刻 @s 仍是施法者本人)
# 【为什么共用一个观察者】两件甲的触发条件一模一样("每使用一次技能"),
#   冷却事件每次施法只抛一次 → 分派一次比挂两个观察者省。
# 【★ 备份公共输入口 ★】本函数嵌在冷却写入的链路中间, 调用的 on_cast 里
#   会写 manacore:in arg(拿 uuid), 必须备份还原 —— 不然调用方 cast 留在
#   in arg 里的参数被冲掉, 见 lib/in_bak。
# ============================================================

# ⓪ 不是玩家(理论到不了这) → 收工
execute unless entity @s[type=minecraft:player] run return 0

# ① 备份公共输入口
function sweetdream:lib/in_bak

# ② 穿枯枝园 → 朽木 + 渊海
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["withered_garden"]}] run function sweetdream:equipment/armor/withered_garden/on_cast_gd

# ③ 穿无光海 → 暗潮
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lightless_sea"]}] run function sweetdream:equipment/armor/lightless_sea/on_cast_ls

# ④ 还原公共输入口
function sweetdream:lib/in_restore
