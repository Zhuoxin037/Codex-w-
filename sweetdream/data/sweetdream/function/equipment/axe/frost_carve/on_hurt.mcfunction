# ============================================================
# sweetdream:equipment/axe/frost_carve/on_hurt —— 超限·剜霜: 受击消耗「披霜」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/frost_carve_hurt(entity_hurt_player)
# 【执行者】挨打的玩家   【位置】他身上
# 【设计原文】"自身每受到一次伤害则自身消耗一层「披霜」并使攻击自己的生物及其
#   3 格内的全部生物冰冻 2 秒。"
# 【★ 为什么挂进度而不是 internal/damage/deal ★】
#   deal 只覆盖"本包投递"的伤害; 怪物平A / 摔落 / 岩浆全走原版, 根本不经过 deal。
#   文案写的是"每受到一次伤害"(不限来源) ⇒ 必须用 entity_hurt_player。
# 【★ "攻击自己的生物"怎么找 ★】进度只说"玩家受伤了", 不给攻击者实体。
#   照抄 blaze_armor / immolate 那套笨办法: 由近到远找最近的非玩家实体
#   (3 格 -> 6 格); 远程(箭/法术)找不到实体就按"没有攻击者"处理 —— 层数照扣,
#   但谁都不冻(文案的对象是"攻击自己的生物", 找不到就不冻)。
# 【★ 层数在这之前就要扣 ★】文案是"消耗一层**并**使…冰冻"; 就算攻击者找不到,
#   这一层也已经花掉了(受击就是代价)。所以扣层排在找攻击者之前。
# ============================================================

# ⓪ 自撤销型进度: 不 revoke 下一拳就不会再触发
advancement revoke @s only sweetdream:equipment/axe/frost_carve_hurt

# ① 身上没有「披霜」-> 整段不发生
execute unless score @s zx.frc_fr matches 1.. run return 0

# ② 扣一层(扣到 0 时把时长一起归零, 免得计时器还在走)
scoreboard players remove @s zx.frc_fr 1
execute if score @s zx.frc_fr matches ..0 run scoreboard players set @s zx.frc_fr 0

# ③ 找"攻击自己的生物": 3 格内最近的非玩家实体, 没有就放宽到 6 格
tag @e[tag=zx.frc_atk,distance=0..] remove zx.frc_atk
execute at @s run tag @e[type=!#sweetdream:hit_scan_exclude,distance=..3,sort=nearest,limit=1] add zx.frc_atk
execute unless entity @e[tag=zx.frc_atk,distance=0..,limit=1] at @s run tag @e[type=!#sweetdream:hit_scan_exclude,distance=..6,sort=nearest,limit=1] add zx.frc_atk

# ④ 冻它 + 它 3 格内的全部生物(ol_ice 里做; 找不到就什么都不冻)
execute at @e[tag=zx.frc_atk,distance=0..,limit=1] run function sweetdream:equipment/axe/frost_carve/ol_ice

# ⑤ 收尾
tag @e[tag=zx.frc_atk,distance=0..] remove zx.frc_atk
