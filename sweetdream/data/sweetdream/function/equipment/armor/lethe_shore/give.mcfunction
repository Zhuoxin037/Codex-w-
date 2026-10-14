# ============================================================
# sweetdream:equipment/armor/lethe_shore/give —— 给一件「沉溺忘川彼岸」（靴子）
# ------------------------------------------------------------
# 【custom_data】"lethe_shore" -> 装备 id
#   ★ 判定一律写成 custom_data~{zx:["lethe_shore"]}(部分匹配 + 独有标记)
# 【数值要和实现对上】魔力上限 +180; 触发需要攻击 8 次(可被削到最低 3 次);
#   「残念」持续 3 秒 / 每秒回 20 魔力 / 基础速度翻倍;
#   解除时 3 格内随机 6 个生物 最大魔力 ×0.06(可增幅且不消耗增幅) + 附加「噬心」;
#   命中带「噬心」的目标 -> 所需攻击次数 -1; 20 秒内未触发则重置回 8 次。
# 【★ 效果已实装(2026-10-06 晚)★】本目录 second/passive/apply_mana/hit/begin/
#   end_lethe/clear/regen/apply_speed/set_bonus 都已就位: second 挂在
#   manacore:event/second, 攻击计数由进度 lethe_shore_hit 驱动(见 hit)。
#   (此前的"效果尚未实现"注释是过时的, 2026-10-06 修正。)
# 【★ 套装是和头盔 styx_walk 联动】解除「残念」时若人在“暗海”内 -> 伤害 +100%(独立乘区)
#   + 下一次最大魔力值技能伤害 +20%(不可叠加)。做效果时要能查到"释放者生成的暗海"。
# 【「残念」是专属状态 → 单独分段】「噬心」是共用标签, 不分段(照 2026-10-06 定的规矩)。
# 【模型】不写 item_model —— 盔甲走原版 netherite 外观。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s netherite_boots[item_name={text:"沉溺忘川彼岸",bold:true,color:dark_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +180。自身攻击了 8 次","color":"gray","italic":false},{"text":"生物后，自身进入「残念」状态，持续 3","color":"gray","italic":false},{"text":"秒。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 残念","color":"gold","bold":true,"italic":false},{"text":"在此状态下时，自身每秒恢复 20 魔力值，","color":"gray","italic":false},{"text":"且自身基础速度翻倍。自身解除该状态时，","color":"gray","italic":false},{"text":"对自身 3 格内的随机 6 个生物造成相当","color":"gray","italic":false},{"text":"于自身最大魔力值 ×0.06 的伤害（该伤害","color":"gray","italic":false},{"text":"可以被增幅，且不会消耗增幅），之后为","color":"gray","italic":false},{"text":"受到伤害的生物附加「噬心」。若该被动","color":"gray","italic":false},{"text":"伤害对附有「噬心」的生物造成了伤害，","color":"gray","italic":false},{"text":"则进入「残念」状态所需攻击次数 -1","color":"gray","italic":false},{"text":"（最低为 3），直至 20 秒内未触发该被","color":"gray","italic":false},{"text":"动。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 漫步冥河之上","color":"gray","italic":false},{"text":"● 沉溺忘川彼岸","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身解除「残念」效果时若自身处于“暗","color":"gray","italic":false},{"text":"海”时，则本次被动伤害提高 100%","color":"gray","italic":false},{"text":"（独立乘区），之后自身下一次使用关于","color":"gray","italic":false},{"text":"最大魔力值的技能时技能伤害 +20%","color":"gray","italic":false},{"text":"（不可叠加）。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["lethe_shore","boots","armor"],tags:["shixin","max_mana","buff","apply","indep_mul","summon"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_lethe_shore",equippable={slot:"feet",asset_id:"sweetdream:armor_lethe_shore",equip_sound:"minecraft:item.armor.equip_netherite"}]
