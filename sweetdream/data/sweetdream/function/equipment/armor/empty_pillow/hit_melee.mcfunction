# ============================================================
# sweetdream:equipment/armor/empty_pillow/hit_melee —— 空枕: 平A 命中入口
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/empty_pillow_hit（player_hurt_entity，
#   只算 `is_player_attack` = 近战普攻）
# 【执行者】动手的玩家
# 【★ 为什么还需要这一条 ★】
#   空枕的「造成伤害」判定挂在 internal/damage/deal（自定义投递），它覆盖了
#   技能真伤 / 法球 / 弩 —— 但**原版近战普攻不走 deal**，所以「静息」的兑现
#   （附「白昼梦」）在普攻上永远不触发（用户实测：技能和法球有用，平A没反应）。
#   这里补上原版事件这一半，两边合起来才是"下一次**攻击**生物"。
# 【和 deal 会不会重复】近战不进 deal，两条路互斥；即便某天重叠，on_deal 里
#   「有静息才兑现、兑现即摘标签」本身幂等，最多多刷一次 ep_hit 时刻。
# 【★ 受害者怎么拿 ★】进度不能把实体传进函数 → lib/victim 用
#   last_hurt_by_player + HurtTime 反查"刚才这一下打的是哪只"（失血/回旋同款）。
# ============================================================

# ① 撤销自己的进度（自撤销型，首行必须 revoke）
advancement revoke @s only sweetdream:equipment/armor/empty_pillow_hit

# ② 没戴空枕就当没这回事
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["empty_pillow"]}] run return 0

# ③ 钉死刚命中的那一只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ④ 交给 on_deal（它认 zx.ep_vic：记"造成伤害时刻" + 兑现静息）
tag @e[tag=zx.victim] add zx.ep_vic
function sweetdream:equipment/armor/empty_pillow/on_deal
tag @e[tag=zx.ep_vic] remove zx.ep_vic

# ⑤ 清掉受害者的临时标签（lib/victim 自己会清，这里只是兜底）
tag @e[tag=zx.victim] remove zx.victim
