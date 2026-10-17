# ============================================================
# sweetdream:equipment/armor/light_pillow/second —— 浅梦: "4 秒内每秒额外回 5 魔力"
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second（对 @a 广播）
# 【执行者】每个玩家
# 【文案(套装段)】…并在这 4 秒内每秒额外回复 5 魔力。
# 【★ 为什么对全部玩家跑 ★】"是不是还要继续回"取决于每人自己的 zx.lp_regen_end,
#   只筛穿轻枕的人会让"刚好在那一秒脱下"的玩家漏掉收尾(虽然只是回蓝, 影响小),
#   更重要的是**清到期刻**必须人人都能走到 —— 否则残留值会一直留着。
# 【★ 早退省调用 ★】本函数被广播给 @a, 绝大多数玩家没穿浅梦两件 ——
#   顶部先做一次"轻枕在手吗"的判定再 return（check.py 的"@a 广播必须自带穿着门控"
#   规则也要求函数体内出现 `items entity @s`）。
# 【★ 拆件即清 ★】用户稿总则:"拆去任一成员后，套装增益和私有积攒立即清除" ⇒
#   没穿齐就把到期刻清 0, 那 4 秒的额外回蓝立刻停。
# ============================================================

# ① 拆件即清：没穿轻枕 / 没穿镜寐时, 把到期刻归零
#    ★ 只对"确实有残留(≥1)"的人写, 避免每秒给全体玩家凭空建一个计分项
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["light_pillow"]}] if score @s zx.lp_regen_end matches 1.. run scoreboard players set @s zx.lp_regen_end 0
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mirror_sleep"]}] if score @s zx.lp_regen_end matches 1.. run scoreboard players set @s zx.lp_regen_end 0

# ② 穿着门控（广播件早退 —— 省掉下面那次 lib/uuid + 跨包 add）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["light_pillow"]}] run return 0
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mirror_sleep"]}] run return 0

# ③ 过了那 4 秒 -> 清掉到期刻并收工
execute if score @s zx.lp_regen_end < #now manacore.meta run scoreboard players set @s zx.lp_regen_end 0
execute unless score @s zx.lp_regen_end matches 1.. run return 0

# ④ 还在窗口内 -> 这一秒额外回 5 点魔力
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
