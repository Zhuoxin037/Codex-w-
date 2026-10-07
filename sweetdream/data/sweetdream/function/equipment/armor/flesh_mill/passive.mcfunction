# ============================================================
# sweetdream:equipment/armor/flesh_mill/passive —— 血肉磨坊·每秒结算
# ------------------------------------------------------------
# 【执行者】玩家(second 用 `as @a at @s` 送进来)
# 【技能原文(lore 逐字)】
#   被动: "穿戴时，自身受到伤害后则每秒获得 2 魔力值及再生Ⅱ效果，持续 5 秒。"
#   套装(魔化腰带+血肉磨坊): "自身魔力值上限 +80。每秒额外获得 1 魔力值。"
#      ★ 这套与「聚魔」(头盔+胸甲)是【两套独立】的 —— 2026-10-08 曾误合成四件套。
# 【拆分】
#   ① 「魔力值上限 +80」   -> 不在这里, 走 armor_mana/passive 的统一差值账本
#   ② 「每秒额外获得 1 魔力值」= **常驻**(文案没给它触发条件, 不擅自绑受伤窗口)
#   ③ 受伤窗口内(由 hurt 把 zx.fm_t 刷成 5): 每秒 +2 魔力 + 再生Ⅱ
#      => 窗口内本秒共回 1+2 = 3(有二件套) / 2(无二件套); 窗口外 1 或 0
# 【★ 为什么只调一次 api/mana/add ★】先算出"本秒该回多少"再一次性加:
#   分开加的话, 套装那条在窗口内会被加第二遍(常驻 +1 与"额外 +1"是同一条)。
# 【记账】回魔写进 zx.regen_extra —— debug 面板"回魔/秒"那一行读它
#   (由 debug/second 在列表最后翻页清零, 本函数不要自己清)。
# ============================================================

# ① 穿着门控(认装备用 ~ 部分匹配 + 独有标记)
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"]}] run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 二件套B 判定: 护腿是「魔化腰带」(自己已是靴) —— 只需两件, 【不关聚魔头盔/胸甲的事】
#   ★ 2026-10-08 事故: 这里曾写成"头盔+胸甲+护腿 三件都在才算"(误当成聚魔四件套),
#     那是凭空加的设定。正确 = 腰带 + 靴 两件。
scoreboard players set #fm_set zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["hex_belt"]}] run scoreboard players add #fm_set zx.meta 1
scoreboard players set #fm_gain zx.meta 0
execute if score #fm_set zx.meta matches 1 run scoreboard players set #fm_gain zx.meta 1

# ③ 本秒该回多少 = 常驻(四件套 1) + 窗口内 2
scoreboard players set #fm_add zx.meta 0
execute if score #fm_gain zx.meta matches 1 run scoreboard players add #fm_add zx.meta 1
execute if score @s zx.fm_t matches 1.. run scoreboard players add #fm_add zx.meta 2

# ④ 回魔(一笔加完, 并记进 debug 账本)
execute if score #fm_add zx.meta matches 1.. run scoreboard players operation @s zx.regen_extra += #fm_add zx.meta
execute if score #fm_add zx.meta matches 1.. run function sweetdream:equipment/armor/flesh_mill/gain

# ⑤ 窗口内额外给再生Ⅱ(1 秒, 等级 2, 隐藏粒子; 每秒续一次 = 覆盖式, 不会叠时长)
execute if score @s zx.fm_t matches 1.. run effect give @s minecraft:regeneration 1 1 true

# ⑥ 窗口 -1 秒(归零 = 窗口结束)
execute if score @s zx.fm_t matches 1.. run scoreboard players remove @s zx.fm_t 1
