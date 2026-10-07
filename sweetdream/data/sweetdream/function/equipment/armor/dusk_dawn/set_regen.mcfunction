# ============================================================
# sweetdream:equipment/armor/dusk_dawn/set_regen —— 套装: 每 3 秒恢复 1% 魔力
# ------------------------------------------------------------
# 【执行者】穿着套装的玩家(由 second 每 3 秒挑一次)
# 【1% 怎么算】把上限按 x100 读成整数 -> 除以 100 回到原值 -> 再除以 100 取 1%。
#   两次整数除法的精度损失最多 1 点, 对这种"每 3 秒回一点"的效果足够了。
#   (计分板没有小数, 所以只能这么算)
#
# 【★★ 必须自己取一次 uuid ★★】second ④ 排在 ① passive(`execute as @a`, 逐个
#   取 uuid)之后 —— 轮到这里时 zx:data self.uuid 里留的是**最后一个玩家**的。
#   多人时变成"两个人都按同一个人的 UUID 回蓝": 那人拿双倍、另一人完全不回
#   (账本 zx.regen_extra 还记在本人的账上, 对不上账)。同 apply_mana 那条注释。
#   群星挽歌的 regen.mcfunction 顶部有同样一段说明, 那件是对的、这件漏了。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #mz zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #mz zx.meta /= #100 manacore.meta
# dup-ok: 两次整数除法是有意的 —— 第一次从"×100 的整数"回到原值, 第二次取 1%
scoreboard players operation #mz zx.meta /= #100 manacore.meta

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #mz zx.meta
function manacore:api/mana/add

# 记进"装备额外回魔"账本(见 core/load 的注释)。
#   这一笔是"每 3 秒回 1% 上限", 数额随上限浮动, 所以直接搬 #mz 的原值,
#   不写死数字 —— 以后改回魔公式这里不用跟着改。
scoreboard players operation @s zx.regen_extra += #mz zx.meta
