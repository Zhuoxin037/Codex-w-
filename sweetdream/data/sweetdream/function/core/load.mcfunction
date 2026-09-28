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

# 装备效果用的"账本": 每个来源自己身上"已经加进面板多少"
#   装备加成只能靠"穿上加、脱下减"的差值写法(面板是一个数, 没有加成层),
#   所以每个来源单独记一笔, 换装时才知道自己该加减多少。
#   静脉泵 / 套装各记魔力, 体外 / 套装各记生命, 互不干涉。
#   (计分项名字上限 16 字符, 所以写得短)
execute unless data storage zx:config obj_pump_mana run scoreboard objectives add zx.pump_mana dummy
execute unless data storage zx:config obj_pump_mana run data modify storage zx:config obj_pump_mana set value 1b
execute unless data storage zx:config obj_set_mana run scoreboard objectives add zx.set_mana dummy
execute unless data storage zx:config obj_set_mana run data modify storage zx:config obj_set_mana set value 1b
execute unless data storage zx:config obj_power_hp run scoreboard objectives add zx.power_hp dummy
execute unless data storage zx:config obj_power_hp run data modify storage zx:config obj_power_hp set value 1b
execute unless data storage zx:config obj_set_hp run scoreboard objectives add zx.set_hp dummy
execute unless data storage zx:config obj_set_hp run data modify storage zx:config obj_set_hp set value 1b

# 桂冠专用: zx.dio_mana = 已经加进面板的魔力上限; zx.dio_regen = 还剩几秒回魔
execute unless data storage zx:config obj_dio_mana run scoreboard objectives add zx.dio_mana dummy
execute unless data storage zx:config obj_dio_mana run data modify storage zx:config obj_dio_mana set value 1b
execute unless data storage zx:config obj_dio_regen run scoreboard objectives add zx.dio_regen dummy
execute unless data storage zx:config obj_dio_regen run data modify storage zx:config obj_dio_regen set value 1b

# 风行于大地之上专用: 风声层数 / aura 加了多少最大魔力 / aura 剩余秒数 / 3 轮爆发剩几轮
execute unless data storage zx:config obj_wg_sound run scoreboard objectives add zx.wg_sound dummy
execute unless data storage zx:config obj_wg_sound run data modify storage zx:config obj_wg_sound set value 1b
execute unless data storage zx:config obj_wg_mana run scoreboard objectives add zx.wg_mana dummy
execute unless data storage zx:config obj_wg_mana run data modify storage zx:config obj_wg_mana set value 1b
execute unless data storage zx:config obj_wg_aura run scoreboard objectives add zx.wg_aura dummy
execute unless data storage zx:config obj_wg_aura run data modify storage zx:config obj_wg_aura set value 1b
# zx.wg_burst: 技能召唤完术阵后还剩几轮没打(每秒由 second 扣 1, 扣到 0 才结算风声奖励)
execute unless data storage zx:config obj_wg_burst run scoreboard objectives add zx.wg_burst dummy
execute unless data storage zx:config obj_wg_burst run data modify storage zx:config obj_wg_burst set value 1b

# 法球(法杖类普攻的载体)用的计分项: 一格 = 100(定点 2 位小数), 起步 3000 = 30 格
execute unless data storage zx:config obj_ball_dist run scoreboard objectives add zx.ball_dist dummy
execute unless data storage zx:config obj_ball_dist run data modify storage zx:config obj_ball_dist set value 1b

# 通用标签(渊海/流火/夜火/噬心/白昼梦)的图标系统:
#   zx.icon_id = 每只被标记的生物(以及它的图标实体)自己的编号, 用来配对
#   #icon_id   = 全局借号用的计数器
execute unless data storage zx:config obj_icon_id run scoreboard objectives add zx.icon_id dummy
execute unless data storage zx:config obj_icon_id run data modify storage zx:config obj_icon_id set value 1b
scoreboard players add #icon_id zx.meta 0

# 技能伤害默认用哪个伤害类型。
#   sweetdream:skill = 本包注册的类型, 和玩家平砍一样吃护甲, 但**不被受伤无敌帧吃掉**
#     (它被挂在原版标签 minecraft:bypasses_cooldown 里)。
#   ⚠️ 这是"注册表"类内容(damage_type), **只在进世界时加载** ——
#      改了它 / 第一次装它之后, 光 /reload 不够, 要退出世界再进来。
#   【保险开关】万一它没生效(所有技能忽然没伤害), 在游戏里执行:
#       /data modify storage zx:config damage_type set value "minecraft:player_attack"
#       /reload
#   就能立刻退回原版平砍类型(代价是多段伤害又会撞无敌帧)。
#   这个字段**只在不存在时**写, 所以你自己改过的值不会被覆盖。
execute unless data storage zx:config damage_type run data modify storage zx:config damage_type set value "sweetdream:skill"

# 清掉残留的法球(比如 /reload 时正在飞的那几颗)。法球是实体, 留着才是真残留;
# 而"读档以后接着飞"没有任何意义, 所以每次加载一律清空。
kill @e[tag=zx.ball]

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
