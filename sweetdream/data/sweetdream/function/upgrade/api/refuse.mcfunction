# ============================================================
# sweetdream:upgrade/api/refuse —— 敲失败了, 说明原因(宏 {id})
# ------------------------------------------------------------
# 【入参】zx:out r.reason = cat|full|dup|req|no_def
# 【为什么按 reason 分开说】"装不上"这四个字对排查毫无帮助 ——
#   玩家得知道到底是"类别不对"、"槽位满了"、"已经敲过"还是"缺前置"。
#   材料已经由调用方(apply/<id>)还回去了, 这里只管说话。
# 【前置那条为什么再转一层】要显示"需要先敲上「魔力提升·α」",
#   而 req 是定义表里存的一个 id —— 得先把它取出来, 再拿它去查中文名。
# ============================================================

$execute if data storage zx:out r{reason:"cat"} run data modify storage zx:work up.msg set from storage zx:config updef."$(id)".cat
execute if data storage zx:out r{reason:"cat"} run tellraw @s [{"text":"✘ 这件装备装不上：需要类别 ","color":"red"},{"nbt":"up.msg","storage":"zx:work","color":"yellow"}]
execute if data storage zx:out r{reason:"full"} run tellraw @s [{"text":"✘ 这件装备的升级槽满了（最多 4 条）","color":"red"}]
execute if data storage zx:out r{reason:"dup"} run tellraw @s [{"text":"✘ 这件装备已经敲过这条升级了","color":"red"}]
execute if data storage zx:out r{reason:"no_def"} run tellraw @s [{"text":"✘ 这条升级没有定义（定义表缺条目）","color":"red"}]

$data modify storage zx:work up.req set from storage zx:config updef."$(id)".req
execute if data storage zx:out r{reason:"req"} run function sweetdream:upgrade/api/refuse_req with storage zx:work up

playsound minecraft:entity.villager.no player @s ~ ~ ~ 0.7 1.0
