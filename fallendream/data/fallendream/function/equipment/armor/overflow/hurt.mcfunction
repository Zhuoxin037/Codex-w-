# ============================================================
# fallendream:equipment/armor/overflow/hurt —— 超限·溢流：临时生命被生物打掉
# ------------------------------------------------------------
# 【谁调它】batch21/hurt（player_hurt_entity，执行者 = 玩家，攻击者已打 zx.s2_source）
# 【文案】"自身临时生命值减少时，自身恢复 1% 最大魔力值。若是因为被生物攻击而
#   损失则使其附加「渊海」。"
# 【★ 怎么知道"这一次确实掉了吸收" ★】吸收值在本刻受伤后才变，读当前
#   AbsorptionAmount 与"上次记账的临时生命"比 —— 相等(或是 0)就说明没掉到临时生命，
#   别白给回蓝和渊海。读玩家 NBT 只在"穿超限溢流 + 刚被打"时进行（热路径开销可控）。
# 【★ 同步 zx.ov_last ★】second 里还有一条每秒兜底检测，这里更新后那边不会重复给。
# ============================================================

execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"],ol:"overflow"}] run return 0

scoreboard players set #ovf_real zx.meta 0
execute store result score #ovf_real zx.meta run data get entity @s AbsorptionAmount 100
scoreboard players add @s zx.thp 0
scoreboard players operation #ovf_ledger zx.meta = @s zx.thp
scoreboard players operation #ovf_ledger zx.meta *= #100 zx.meta
execute unless score #ovf_real zx.meta < #ovf_ledger zx.meta run return 0
scoreboard players operation @s zx.ov_last = #ovf_real zx.meta

function fallendream:equipment/armor/overflow/loss_reward

# 攻击者就是 batch21/hurt 打过标的那个；给它「渊海」走统一入口（自带时长与图标）
function fallendream:tag/mark {target:"@e[tag=zx.s2_source,limit=1]",mark:"yuanhai"}
