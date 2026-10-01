# ============================================================
# sweetdream:internal/damage/one —— 对"一个"目标打伤害(宏 {num_str,type,u0..u3})
# ------------------------------------------------------------
# 【执行者】被打的那一只(由 with_from 用 execute as 逐个送进来)
# 【顺序很重要】
#   ① 先看它身上有没有 5 个通用标签 —— 生物一死就查不到了, 所以必须打之前看
#   ② 打伤害(带 by <攻击者>, 击杀才算玩家头上)
#   ③ 如果"带标签"且"这一下把它打死了"(Health 被夹到 0.0f), 就让攻击者补 +100
#      —— 走的是和进度回调**同一条**逻辑(kill_mark_go), 那边是"差值记账",
#         所以两条路都跑也不会加两遍。
# ============================================================

# ① 打之前: 它身上有任意一个通用标签吗?
scoreboard players set #dmk zx.meta 0
execute if entity @s[tag=zx.status.yuanhai] run scoreboard players set #dmk zx.meta 1
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players set #dmk zx.meta 1
execute if entity @s[tag=zx.status.yehuo] run scoreboard players set #dmk zx.meta 1
execute if entity @s[tag=zx.status.shixin] run scoreboard players set #dmk zx.meta 1
execute if entity @s[tag=zx.status.dream] run scoreboard players set #dmk zx.meta 1

# ② 打伤害(有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来)
$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run damage @s $(num_str) $(type) by @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1]
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run damage @s $(num_str) $(type)

# ③ 带标签 + 这一下打死了 -> 让攻击者补 +100
execute if score #dmk zx.meta matches 1 if data entity @s {Health:0.0f} run function sweetdream:equipment/armor/dusk_dawn/kill_mark_from_skill with storage zx:work a
