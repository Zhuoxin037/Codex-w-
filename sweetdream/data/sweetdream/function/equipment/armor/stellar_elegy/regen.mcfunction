# ============================================================
# sweetdream:equipment/armor/stellar_elegy/regen —— 受击后的"每秒回魔力"
# ------------------------------------------------------------
# 【执行者】zx.se_regen >= 1 的玩家(每秒跑一次)
# 【原版】每秒回 10 点。  【超限版】每秒回 2% 魔力值(按**上限**算, 不是当前值)。
# 【为什么走 api/mana/add】它是"直接加魔力", 不会超过上限, 也不受"禁止恢复"影响
#   —— 和静脉泵那个"每秒回 3"是同一套写法, 保持手感一致。
# 【★ 这里必须自己调 lib/uuid ★】second 里 regen 排在 passive 之后, 而 passive 是
#   `execute as @a` 逐个跑的 —— 跑到 regen 时 zx:data self.uuid 里留的是
#   **最后一个玩家**的 UUID(passive 里最后一次 lib/uuid 的结果)。
#   多人时这会"给别人回魔"; 单人时碰巧正确, 所以一直没暴露。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
# 【★★ 还得判"是不是还穿着" ★★】is_ol 只在"穿着**且**超限"时给 1,
#   **没穿也返回 0** —— 光靠 `unless #se_ol=1` 拦不住脱下装备的人:
#   脱了护腿(或换成任意别的护腿)只要 zx.se_regen 还没数完, 每秒照样 +10,
#   白拿最多 5 秒。文案是"穿戴时受击后…", 所以这里必须自带门控(坑 59
#   equipgate: 被 as 换身份调用的被动都得自己确认穿着)。
#   同套的 dusk_dawn/low_mana 第一行就是这道门控, 那件是对的、这件漏了。
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["stellar_elegy"]}] run return 0
function sweetdream:equipment/armor/stellar_elegy/is_ol

# 原版: 固定 10
execute unless score #se_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",value:10.0}
execute unless score #se_ol zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute unless score #se_ol zx.meta matches 1 run function manacore:api/mana/add
execute unless score #se_ol zx.meta matches 1 run scoreboard players add @s zx.regen_extra 10

# 超限版: 最大魔力 ×2%
execute if score #se_ol zx.meta matches 1 run function sweetdream:equipment/armor/stellar_elegy/regen_pct

scoreboard players remove @s zx.se_regen 1
