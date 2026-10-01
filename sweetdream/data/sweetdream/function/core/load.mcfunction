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
#   zx.icon_id 只为读取旧版本编号而保留；新版使用完整 UUID 配对。
#   #icon_id 为旧数据兼容计数器，新版不再借号。
execute unless data storage zx:config obj_icon_id run scoreboard objectives add zx.icon_id dummy
execute unless data storage zx:config obj_icon_id run data modify storage zx:config obj_icon_id set value 1b
scoreboard players add #icon_id zx.meta 0

# 超•负•荷 的"超载状态"倒计时: 还剩几秒; 同时是"技能生效中"的开关
execute unless data storage zx:config obj_chg_on run scoreboard objectives add zx.chg_on dummy
execute unless data storage zx:config obj_chg_on run data modify storage zx:config obj_chg_on set value 1b

# 引梦镰 的"强化攻击"锁定: 触发过强化之后还剩几秒不能再触发(初始 0 = 没锁)
execute unless data storage zx:config obj_sd_lock run scoreboard objectives add zx.sd_lock dummy
execute unless data storage zx:config obj_sd_lock run data modify storage zx:config obj_sd_lock set value 1b

# ---- 四件新装备/武器专用的计分项(目标名上限 16 字符, 所以写得很短) ----
# 群星坠落之挽歌: se_mana = 已加进面板的魔力上限; se_regen = 受击后"每秒回10魔力"还剩几秒
execute unless data storage zx:config obj_se_mana run scoreboard objectives add zx.se_mana dummy
execute unless data storage zx:config obj_se_mana run data modify storage zx:config obj_se_mana set value 1b
execute unless data storage zx:config obj_se_regen run scoreboard objectives add zx.se_regen dummy
execute unless data storage zx:config obj_se_regen run data modify storage zx:config obj_se_regen set value 1b

# 黄昏黎明之交界: dd_mana 已加上限 / dd_set 套装已加上限 / dd_temp 临时上限剩余秒 /
#   dd_t1 击杀基础(+200) / dd_t2 击杀带标签额外(+100) / dd_app 已经加了多少(差值账本) /
#   dd_know 用来判断"两条进度是不是同一次击杀"
execute unless data storage zx:config obj_dd_mana run scoreboard objectives add zx.dd_mana dummy
execute unless data storage zx:config obj_dd_mana run data modify storage zx:config obj_dd_mana set value 1b
execute unless data storage zx:config obj_dd_set run scoreboard objectives add zx.dd_set dummy
execute unless data storage zx:config obj_dd_set run data modify storage zx:config obj_dd_set set value 1b
execute unless data storage zx:config obj_dd_temp run scoreboard objectives add zx.dd_temp dummy
execute unless data storage zx:config obj_dd_temp run data modify storage zx:config obj_dd_temp set value 1b
execute unless data storage zx:config obj_dd_t1 run scoreboard objectives add zx.dd_t1 dummy
execute unless data storage zx:config obj_dd_t1 run data modify storage zx:config obj_dd_t1 set value 1b
execute unless data storage zx:config obj_dd_t2 run scoreboard objectives add zx.dd_t2 dummy
execute unless data storage zx:config obj_dd_t2 run data modify storage zx:config obj_dd_t2 set value 1b
execute unless data storage zx:config obj_dd_app run scoreboard objectives add zx.dd_app dummy
execute unless data storage zx:config obj_dd_app run data modify storage zx:config obj_dd_app set value 1b
execute unless data storage zx:config obj_dd_know run scoreboard objectives add zx.dd_know dummy
execute unless data storage zx:config obj_dd_know run data modify storage zx:config obj_dd_know set value 1b

# 寒鸦: cc_ice = 冰凌层数(0..3)
#   (这一发是第几层 / 伤害多少, 射击时写进 zx:data cc."<uuid>"; 命中由附魔回调处理)
execute unless data storage zx:config obj_cc_ice run scoreboard objectives add zx.cc_ice dummy
execute unless data storage zx:config obj_cc_ice run data modify storage zx:config obj_cc_ice set value 1b

# 燎原: ly_aura = 光环还剩几秒(0 = 没有光环) / ly_timer = 离下一次灼烧还有几秒
#        ly_times = 这一次光环里已经灼烧了几次(第 3/6/9 次附加「流火」)
execute unless data storage zx:config obj_ly_aura run scoreboard objectives add zx.ly_aura dummy
execute unless data storage zx:config obj_ly_aura run data modify storage zx:config obj_ly_aura set value 1b
execute unless data storage zx:config obj_ly_timer run scoreboard objectives add zx.ly_timer dummy
execute unless data storage zx:config obj_ly_timer run data modify storage zx:config obj_ly_timer set value 1b
execute unless data storage zx:config obj_ly_times run scoreboard objectives add zx.ly_times dummy
execute unless data storage zx:config obj_ly_times run data modify storage zx:config obj_ly_times set value 1b

# 公共: fz_end = 冻结/时停的结束时刻(用框架时钟 #now)
execute unless data storage zx:config obj_fz_end run scoreboard objectives add zx.fz_end dummy
execute unless data storage zx:config obj_fz_end run data modify storage zx:config obj_fz_end set value 1b

# 烈火，残躯: fb_lava 熔浆层数
execute unless data storage zx:config obj_fb_lava run scoreboard objectives add zx.fb_lava dummy
execute unless data storage zx:config obj_fb_lava run data modify storage zx:config obj_fb_lava set value 1b

# 自己包用的两个小常量(框架只给了 #10/#100/#15/#16/#scale):
#   #2 用于"当前魔力 ×2 < 上限"这种比较, #3 用于"每 3 秒一次"的取模
scoreboard players set #2 zx.meta 2
scoreboard players set #3 zx.meta 3
# 焚舟烈空换算用的常量:
#   #20 = 每 20 点烈空算一档, #30 = 每档 +30 魔力上限
#   ⚠️ 这两个不建的话 `#im_p /= #20` 会变成除以 0 —— 命令报错会中断整个
#   second_one, 现象就是"烈空在涨, 但上限不加、buff 也不倒计时"。
scoreboard players set #20 zx.meta 20
scoreboard players set #30 zx.meta 30

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

# 升级 / 超限 的定义表(框架, 见 升级与超限系统-设计.md)
function sweetdream:upgrade/def/load
function sweetdream:overlimit/def/load

# 通用标签 v2：创建缓存目标，迁移旧状态并重建显示。
function sweetdream:tag/load

# 时停独立计时(冷冻 zx.fz_end / 时停 zx.ts_end) + 原本是否 NoAI 的备份
execute unless data storage zx:config obj_ts_end run scoreboard objectives add zx.ts_end dummy
execute unless data storage zx:config obj_ts_end run data modify storage zx:config obj_ts_end set value 1b
execute unless data storage zx:config obj_noai_bak run scoreboard objectives add zx.noai_bak dummy
execute unless data storage zx:config obj_noai_bak run data modify storage zx:config obj_noai_bak set value 1b
# 引梦镰横扫: 注册 zx.sd_t / zx.sd_id / zx.sd_leave
function sweetdream:equipment/sword/sickle_dreams/sweep/load
# 余烬+焚舟: 烈空层数/模式/上限账本/套装 buff
execute unless data storage zx:config obj_lk run scoreboard objectives add zx.lk dummy
execute unless data storage zx:config obj_lk run data modify storage zx:config obj_lk set value 1b
execute unless data storage zx:config obj_lk_mode run scoreboard objectives add zx.lk_mode dummy
execute unless data storage zx:config obj_lk_mode run data modify storage zx:config obj_lk_mode set value 1b
execute unless data storage zx:config obj_im_mk run scoreboard objectives add zx.im_mk dummy
execute unless data storage zx:config obj_im_mk run data modify storage zx:config obj_im_mk set value 1b
execute unless data storage zx:config obj_im_buff run scoreboard objectives add zx.im_buff dummy
execute unless data storage zx:config obj_im_buff run data modify storage zx:config obj_im_buff set value 1b
execute unless data storage zx:config obj_im_buff_mk run scoreboard objectives add zx.im_buff_mk dummy
execute unless data storage zx:config obj_im_buff_mk run data modify storage zx:config obj_im_buff_mk set value 1b
execute unless data storage zx:config obj_em_mana run scoreboard objectives add zx.em_mana dummy
execute unless data storage zx:config obj_em_mana run data modify storage zx:config obj_em_mana set value 1b
execute unless data storage zx:config obj_im_set20 run scoreboard objectives add zx.im_set20 dummy
execute unless data storage zx:config obj_im_set20 run data modify storage zx:config obj_im_set20 set value 1b
execute unless data storage zx:config obj_em_conv run scoreboard objectives add zx.em_conv dummy
execute unless data storage zx:config obj_em_conv run data modify storage zx:config obj_em_conv set value 1b
execute unless data storage zx:config obj_em_seen run scoreboard objectives add zx.em_seen dummy
execute unless data storage zx:config obj_em_seen run data modify storage zx:config obj_em_seen set value 1b
execute unless data storage zx:config obj_em_mana50 run data modify storage zx:config obj_em_mana50 set value 1b
