# ============================================================
# sweetdream:core/load —— 加载 / 重载时执行
# ------------------------------------------------------------
# 【谁调用它】data/minecraft/tags/function/load.json
# 【为什么用 execute unless + storage 标记来建计分板目标】
#   scoreboard objectives add 在目标已存在时会报错, 报错会中断整个函数 ——
#   第二次 /reload 之后后面的初始化就全都不跑了。
#   所以给目标配一个创建标记, 把 add 限制成一次。
#   (注意: scoreboard players set 在 1.21.5 不会自动建目标, 不能用它兜底。)
# 【zx.meta 现在用来干嘛】记"备份架子连续丢了几 tick",
#   详见 internal/summon_named_stand。
# ============================================================

execute unless data storage zx:config obj_meta run scoreboard objectives add zx.meta dummy
execute unless data storage zx:config obj_meta run data modify storage zx:config obj_meta set value 1b

# zx.meta 上的常量: #tps = 每秒多少 tick。
# 面板要把"剩余冷却 tick"换算成秒, 用的是它, 而不是前置包的 #interval。
# (#interval 是"回魔间隔", 默认也是 20 —— 但那是巧合。哪天把回魔间隔改成 10,
#  借它算冷却就会把秒数显示成 2 倍。)
scoreboard players set #tps zx.meta 20

# 横刀突进用的计分项: 每个玩家自己的"还剩几步"
#   用计分项而不是 storage —— 它天然"每人一份", 不用按 UUID 拼路径,
#   于是突进那一整套完全不需要宏函数, 少一层就少一类坑。
execute unless data storage zx:config obj_dash run scoreboard objectives add zx.dash dummy
execute unless data storage zx:config obj_dash run data modify storage zx:config obj_dash set value 1b

# ============================================================
# 把备份架子住的区块永久加载
# ------------------------------------------------------------
# 【为什么需要】架子固定在主世界 (0.5, -60, 0.5) —— 基岩层下面, 但不是虚空
#   (世界最低点是 -64, 所以在世界内, 吃不到虚空伤害; 虚空伤害是无视无敌的,
#    真塞进虚空它会被销毁, 然后自愈逻辑反复重造, 直接实体爆炸)。
# 【forceload 干什么】强制那个区块一直加载并参与实体运算, 于是:
#   - 玩家跑到天涯海角, 备份和回手照样有效(选择器能找到它)
#   - 不再出现"区块没加载 -> 找不到 -> 误判成丢了"的重复生成
# 【想换位置】改这里的坐标 + summon_named_stand 里的 summon 坐标, 两处要一致。
# 【重复执行安全】forceload add 对已加载的区块是无害的。
# ============================================================
execute in minecraft:overworld run forceload add 0 0
