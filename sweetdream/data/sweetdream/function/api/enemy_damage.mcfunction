# ============================================================
# sweetdream:api/enemy_damage —— 敌方技能伤害的入口(2026-10-06 预留)
# ------------------------------------------------------------
# 【契约】和 api/damage 完全一样(入参 target / damage / type / read), 只是**把来源标成敌方**:
#   zx:work a.src = "enemy"(默认是 "ally", 见 api/damage)。
# 【出参】同 api/damage:zx:out r.applied / r.damage / r.src(这时 r.src = "enemy")。
#
# 【★ 为什么单独开一个入口, 而不是让敌人也调 api/damage ★】
#   "敌人放的技能"以后要能跟"玩家放的技能"区分开, 才能:
#     · 让「夜火」(受到技能伤害 +15%)把敌方技能也算作"技能伤害"(见 internal/damage/one
#       的两条互斥分支);
#     · 让「白昼梦」(自身技能伤害 −20%)在**敌方施法者身上**生效 —— 它本来就是按
#       "施法者 @s 带不带标签"判的, 所以只要敌方技能从本入口进来就天然可用;
#     · 以后加玩家侧防御(护盾 / 减伤 / 反击 / 受击进度)时有唯一的落点。
#   走本入口 = src:"enemy", 之后完全复用 api/damage 的链路(internal/damage/with_from →
#   one → deal), 结算口径与玩家技能一模一样, 不会出现"两套伤害算法"。
#
# 【★ 现在包里还没有任何敌方技能 ★】所以这是一条**面向未来的通道**: 敌方技能实装时,
#   把它的数值按 api/damage 的模板写进 zx:in arg 再调本函数即可(见下面的用法)。
#   如果哪天希望"敌方技能"在类型上也独立(而不是靠 src 标记), 再照 damage_type/skill.json
#   加一份 sweetdream:enemy_skill 并进 bypasses_cooldown 标签 —— 那需要退世界重进,
#   目前刻意不做(用标记就够了, 改注册表反而更麻烦)。
#
# 【用法】
#   data modify storage zx:in arg set value {target:"@p[distance=..3]", damage:8.0}
#   function sweetdream:api/enemy_damage
# ============================================================

# 先写进"调用方的入参节点"——api/damage 会把 zx:in arg 整份 merge 进 zx:work a,
#   所以在这里写 src 就等于给它一个"来源标记"(调用方自己写了 src 也以调用方为准,
#   但那是非预期用法; 敌方技能一律用本入口)。
data modify storage zx:in arg.src set value "enemy"
function sweetdream:api/damage
