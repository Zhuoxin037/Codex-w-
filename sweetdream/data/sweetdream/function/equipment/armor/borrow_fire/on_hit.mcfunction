# ============================================================
# sweetdream:equipment/armor/borrow_fire/on_hit —— 打中"在燃烧"的生物 ⇒ 充能(借火)
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one:`... run function ... with storage zx:work ob`
# 【执行者】被打中的那只生物(@s 就是它)  【宏参数】$(u0)..$(u3) = 施法者 UUID
# 【文案】自身对在燃烧的生物造成伤害后则下一次普通攻击未附有「流火」的生物时…
# 【★ 燃烧判定 ★】`{Fire:1..}` 这种 NBT 过滤器在 1.21.5 **不接受范围写法**, 会让
#   整个函数加载失败(blaze_armor/hurt 头的老教训)。改成 data get 出来存分数再判:
#   没在烧时 Fire 字段不存在 ⇒ data get 失败 ⇒ 分数保持 0。
# 【★ 先判燃烧再反查人 ★】燃烧判定只是一个小 NBT 读, 反查要动 4 个计分项;
#   把便宜的那条排在前面, 绝大多数伤害在这里就收工了。
# ============================================================

scoreboard players set #bf_f zx.meta 0
execute store result score #bf_f zx.meta run data get entity @s Fire
execute if score #bf_f zx.meta matches ..0 run return 0

#   ★ 施法者 UUID 走**宏参数** $(u0)..$(u3), 不去读 zx:work ob ——
#     ob 是 internal/damage 那条链的专用基准节点, 别的函数一碰就会污染它
#     (smoke_step/set_burn、crimson_seam/set_true_hit 都是这个写法)。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

execute as @a[tag=zx.ub,limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["borrow_fire"]}] run scoreboard players set @s zx.bf_rdy 1
