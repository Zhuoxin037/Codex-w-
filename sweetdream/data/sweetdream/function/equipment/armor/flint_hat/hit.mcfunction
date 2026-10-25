# ============================================================
# sweetdream:equipment/armor/flint_hat/hit —— 燧帽: 近战命中给目标点「流火」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/flint_hat_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +40。普通近战命中了未附有「流火」且仍存活的
#   生物后，若魔力足够，则消耗 20 魔力并使其附加「流火」。该效果 8 秒内最多触发一次。
# 【★ "且仍存活" 是天然满足的 ★】进度在**伤害打完之后**才抛；目标若被这一下打死，
#   它已从世界移除 ⇒ 下面的 victim 定位挑不出东西、直接收工（同归息 hit 的注释）。
# 【★ 附加是"附着"不是"消耗" ★】走 tag/mark（**不走** mark_consume）—— 走消耗入口
#   会把执行者当成"消耗者"，白给余烬 / 回潮扣 / 烛跬那一串被动（刺纹 hit 同款坑）。
# 【★ "若魔力足够" 交给 api/mana/consume 判 ★】它自带"够才扣、不够一个字节都不扣"
#   的语义（out.success），所以**不需要**先读面板魔力再比大小 —— 少一次跨包调用，
#   也天然避免"读到的值与扣款不是同一刻"的偏差。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/flint_hat_hit

# ---- 满蓄力闸（全包统一口径：平A 没蓄满力这一发不触发；见 lib/atk_charge 头部） ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿燧帽就没这事（头盔）
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["flint_hat"]}] run return 0

# ② 8 秒节流（账本存"下次可触发刻"，口径同归息 zx.lb_cd / 刺纹 zx.thorn_cd）
scoreboard players set #fh_due zx.meta 0
execute store result score #fh_due zx.meta run scoreboard players get @s zx.fh_cd
execute if score #fh_due zx.meta > #now manacore.meta run return 0

# ③ 定位"刚才这一下平A打的是哪一只"（lib/victim：last_hurt_by_player + HurtTime 收窄）
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ④ 它必须**未**带「流火」（已经烧着的不用再点一次）
execute as @e[tag=zx.victim,distance=0..,limit=1] if entity @s[tag=zx.status.liuhuo] run return 0

# ⑤ 拿 uuid（下面扣魔力的公共输入口要它）
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ⑥ 消耗 20 魔力（够才扣；不够就直接收工，什么都不做）
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ⑦ 给它附加「流火」（附着 -> tag/mark；tag/mark 内部会一并挂上 15 秒计时与图标）
data modify storage zx:work ic set value {target:"@e[tag=zx.victim,limit=1]",mark:"liuhuo"}
function sweetdream:tag/mark with storage zx:work ic

# ⑧ 表现
execute at @e[tag=zx.victim,limit=1] run particle minecraft:flame ~ ~0.6 ~ 0.3 0.4 0.3 0.01 8 normal
execute at @s run playsound minecraft:item.flintandsteel.use player @a ~ ~ ~ 0.6 1.2

# ⑨ 记下"下次可触发刻"（现在 + 160 刻 = 8 秒）
scoreboard players operation @s zx.fh_cd = #now manacore.meta
scoreboard players operation @s zx.fh_cd += #160 zx.meta

# ⑩ 收尾
tag @e[tag=zx.victim] remove zx.victim
