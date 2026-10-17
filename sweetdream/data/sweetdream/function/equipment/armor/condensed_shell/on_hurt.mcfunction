# ============================================================
# sweetdream:equipment/armor/condensed_shell/on_hurt —— 凝壳: 挨打就给自己糊一层壳
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/condensed_shell_hurt
#   触发器 entity_hurt_player，**不过滤伤害类型** —— 文案写的是"受到伤害后"，
#   近战 / 火焰 / 摔落 / 法术都算。无过滤先例 = 幻昼 iridescent_hurt(同样裸 trigger)。
# 【执行者】玩家(挨打的那个人)
# 【文案(lore 逐字)】
#   ✦ 被动技能: 自身魔力值上限 +160。受到伤害后，若魔力足够且术阵位有空缺，
#     则消耗 80 魔力并占用 1 个术阵位，在自身位置生成半径 3 格、持续 4 秒的领域。
#     该效果 20 秒内不可再次触发。
#   ✦ 领域: 生物首次进入本次领域时冰冻 1 秒，每名生物整次领域最多触发一次冰冻。
#     领域每秒对其中的生物造成一次相当于自身基础攻击力 ×4 的伤害。
# 【"魔力上限 +160"不在这个文件】那是常驻被动，走 armor_mana 的每秒差值注册
#   (见 equipment/armor/armor_mana/passive 里本轮新加的那一行)。
# 【★ 两个前提都在"花魔力"之前判 ★】
#   文案是"若魔力足够**且**术阵位有空缺, 则消耗 80 魔力**并**占用 1 个术阵位"
#   ⇒ 任一不满足就**整段不发生**: 魔力一点不扣、术阵位一点不占、20 秒 CD 也不起。
#   顺序: ① 穿没穿 ② 20 秒闸 ③ 术阵位(只读) ④ 扣魔力(扣不动就 return) ⑤ 才落 CD。
#   先例 = wind_ontheground/skill 的 ⑤(formation/check -> ..0 就 return 0)。
# 【★ 吃伤害也吃"没穿凝壳"】进度是无条件触发的(玩家的任何受伤都会点亮它),
#   所以第 ① 步必须自己查胸甲槽 —— 这也是包里所有 armor_hurt 类进度的统一写法。
# ============================================================

# ⓪ 撤销自己的进度(自撤销型: 不撤销下一次就不会再触发 —— 守门会查它有没有进 lib/rearm)
advancement revoke @s only sweetdream:equipment/armor/condensed_shell_hurt

# ① 没穿凝壳就没这事(胸甲)
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["condensed_shell"]}] run return 0

# ② 20 秒再触发闸(记在**玩家**身上, 存的是"下次可以触发的 #now 时刻")
#   ★ 先 `add 0` 把计分项建出来: 没分数时 `if score` 判不成立, 第一次会永远触发不了。
#   ★ 这里只比"到点没到点", 不"取较长" —— 它是再触发闸, 不是持续时间(和冷冻的语义不同)。
scoreboard players add @s zx.cs_cd 0
execute if score @s zx.cs_cd > #now manacore.meta run return 0

# ③ 拿 uuid(后面查术阵位、扣魔力、登记术阵都要)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ④ 有术阵位吗(只读检查, 不产生任何副作用)? 满了就整段不发生
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/check
execute unless data storage manacore:out r{can_create:1b} run return 0

# ⑤ 扣 80 魔力(魔力不足的分支: 一个字节都不扣, 也不起 CD、不占术阵位)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute unless data storage manacore:out r{success:1b} run return 0

# ⑥ 起 20 秒 CD(走到这里 = "这一次真的发生了")
scoreboard players operation @s zx.cs_cd = #now manacore.meta
scoreboard players operation @s zx.cs_cd += #400 zx.meta

# ⑦ 先把"领域每秒那一段"的伤害算好: 基础攻击力 ×4
#   ★ 施放那刻算好写进 marker NBT —— 之后施法者换装/死亡都不影响这次领域
#     (和神裁领域 / 崩裂裂缝同一路子)。
#   ★ 走的是 attack_mul 通道 ⇒ lib/skill_mul/def 的 wchan.condensed_shell 必须标 atk:1b,
#     否则面板会漏显示/归错列(check 的 chandef 规则会直接报)。
data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work csf.dmg set from storage manacore:out r.damage

# ⑧ 组装领域 marker 的宏参数(uuid 文本 + 四个整数)
data modify storage zx:work csf.uu set from storage zx:data self.uuid
data modify storage zx:work csf.u0 set from entity @s UUID[0]
data modify storage zx:work csf.u1 set from entity @s UUID[1]
data modify storage zx:work csf.u2 set from entity @s UUID[2]
data modify storage zx:work csf.u3 set from entity @s UUID[3]

# ⑨ 在自身位置生成领域 marker
execute at @s run function sweetdream:equipment/armor/condensed_shell/field_one with storage zx:work csf

# ⑩ 在**框架里**登记一个真术阵(这才叫"占用 1 个术阵位": 观测镜的"术阵 n/上限"、
#    术阵上限、以及「无效」/「共振」这类"看术阵行事"的装备都靠它认出来)。
#   【为什么 duration_seconds 是 4.0, 不是 0.0】0.0 = **永久术阵**(坑 46) —— 会白占槽位
#     永远不释放。这里给 4.0, 4 秒后由 field_end 显式删掉。
#   【为什么不看返回值】④ 已经查过 can_create; 就算极端竞态下 create 失败, 领域判定
#     只看 marker, 技能本身照常生效(thunderclap/open ⑤ 同款注释)。
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:condensed_shell",type:"frostshell",duration_seconds:4.0,data:{radius:3.0}}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑪ 表现: 脚下炸开一圈霜白
#   ★ 粒子名必须是 1.21.5 客户端 jar 里真实存在的(共 103 个) —— 这里用 snowflake / poof。
#     曾经想用 item_snowball, 但它在 jar 里**不存在**(check.py 的 KNOWN_PARTICLES 有假阳性),
#     写下去只会静默什么都不出。以后挑粒子请照 _gen_staff_particles.py 里那份做法核名。
particle minecraft:snowflake ~ ~0.3 ~ 1.4 0.2 1.4 0.05 40 normal
particle minecraft:poof ~ ~0.4 ~ 1.0 0.2 1.0 0.06 30 normal
playsound minecraft:block.powder_snow.break player @a ~ ~ ~ 1.0 0.8
