# ============================================================
# sweetdream:equipment/armor/eternity/reclaim —— 永恒: 花 50 魔力让标签"再次附着"
# ------------------------------------------------------------
# 【谁调用它】lib/mark_take ②(消耗标签的统一入口那一链;
#   执行者 = **消耗者** —— 由 as $(by) 换过去, 可能是本人, 也可能是
#   虹彩/清醒梦用 lib/find_by 反查出来的施法者)
# 【宏参数】target / mark(被消耗的标签在谁身上 / 是哪个标签)
# 【文案】"自身魔力值若高于 50 点则自身每次消耗了…任一标签则消耗 50 魔力值
#   并使其再次附着。"
# 【流程】⓪ 判"自己穿着永恒"(不穿直接收工) -> 判魔力 > 50 -> 用 api/mana/consume 扣 50
#   (带"够不够"的原子判定) -> 调 tag/mark 把标签原地刷回满租约
#   -> 写 zx:work mc.done=1b 告诉调用方"已补回"
# 【★ 魔力不足 / 扣款失败 = 静默放弃 ★】直接 return, 不写 done ——
#   调用方就会走正常的"消耗掉"分支, 余烬被动也照给。文案的"若高于 50 点"就是这个意思。
# 【★ 不许走 lib/uuid ★】它写的是全局的 zx:data self: ① 调用链上游(各武器)可能
#   正拿着它用; ② 这里的 @s 可能是**别人**(反查出来的施法者), 写进去就把现场污染成
#   他的 uuid 了。所以按 apocalypse/spend 的定式, 用前置包接口 + 自己的节点 zx:work etr。
# 【为什么调 tag/mark 而不是自己写 ttl】mark 是公共入口, 它会一并刷新
#   租约(zx.tt.<mark>)和头顶图标 —— 自己写会漏掉图标, 表现上就是"标签回来了但图标没了"。
# 【"本次附着的标签不可再触发该效果"】消耗只有"技能主动吃"一条路, 刷新后不会自动连锁;
#   同一个技能再打一次会再消耗一次、再扣 50 —— 这是文案"每次消耗了…就…"的字面意思。
# ============================================================

# ⓪ ★必须先确认"消耗者本人穿着永恒"★ —— 不然后果是: 任何魔力 > 50 的玩家
#   消耗标签都会被白扣 50 并把标签刷回(装备被动变成了人人都有)。判定写法与
#   eternity/passive 第 20 行逐字一致(槽位 armor.chest, 下界合金胸甲)。
#   此刻 @s = 消耗者(由 lib/mark_take 用 as $(by) 换过来的)。
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["eternity"]}] run return 0

# ① 拿自己的 uuid(走接口, 写进 zx:work etr —— 不碰 zx:data self, 见上)
data modify storage zx:work etr set value {uuid:"",ok:0b}
function manacore:api/player/self_uuid
execute if data storage manacore:out r.uuid unless data storage manacore:out r{uuid:""} run data modify storage zx:work etr.uuid set from storage manacore:out r.uuid
execute if data storage zx:work etr.uuid unless data storage zx:work etr{uuid:""} run data modify storage zx:work etr.ok set value 1b
execute unless data storage zx:work etr{ok:1b} run return 0

# ② 读当前魔力(★ 先归零再 store: data get 读不到时 store 不执行会留旧值)
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:work etr.uuid
function manacore:api/mana/get
scoreboard players set #mn zx.meta 0
execute store result score #mn zx.meta run data get storage manacore:out r.value 100

# ③ 必须**高于** 50 -> 定点 ×100 就是 > 5000
execute unless score #mn zx.meta matches 5001.. run return 0

# ③.5 ★★ "本次附着的标签不可再触发该效果"(lore 末句, 2026-10-08 补) ★★
#   旧实现只有"穿永恒就无限补" —— 于是同一个标签可以被永恒反复补回,
#   只要魔力够就永远掉不下来(玩家报: 和文本不符)。
#   【做法】每次永恒成功附着后, 给那只生物打一个"这是我补的"标记 zx.et_<标签名>;
#   下次这个标签再被消耗时, 认出标记 -> 本次**不**补(让它正常被消耗掉),
#   并把这个标记清掉 —— 于是"我补的那一次"用掉了, 之后正常途径附着的又能再补。
#   标记按标签名分开记, 免得"渊海补的那次"把"流火"也一起挡了。
scoreboard players set #et_again zx.meta 0
$execute as $(target) if entity @s[tag=zx.et_$(mark)] run scoreboard players add #et_again zx.meta 1
$execute as $(target) if entity @s[tag=zx.et_$(mark)] run tag @s remove zx.et_$(mark)
execute if score #et_again zx.meta matches 1.. run return 0

# ④ 扣 50(consume 保证"要么完整扣、要么不扣")
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:work etr.uuid
function sweetdream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ⑤ 再次附着: 公共接口刷新标签(租约 + 图标一起回来)
$function sweetdream:tag/mark {target:"$(target)",mark:"$(mark)"}
#   打上"这是我补的" —— 下一次这个标签被消耗时不再触发永恒(见 ③.5)
$execute as $(target) run tag @s add zx.et_$(mark)

# ⑥ 告诉调用方"已补回"(lib/mark_take 靠它决定不再摘标签、不给余烬被动)
data modify storage zx:work mc.done set value 1b

# ⑦ 表现
execute at @s run particle minecraft:enchant ~ ~1 ~ 0.4 0.5 0.4 0.05 12 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.4 1.8
