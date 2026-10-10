# ============================================================
# sweetdream:equipment/armor/styx_walk/give —— 给一件「漫步冥河之上」（头盔）
# ------------------------------------------------------------
# 【custom_data】"styx_walk" -> 装备 id
#   ★ 判定一律写成 custom_data~{zx:["styx_walk"]}(部分匹配 + 独有标记)
# 【数值要和实现对上】魔力上限 +210; 暗海(攻击触发) 持续 5 秒 / 半径 3 格 / 内置 CD 8 秒;
#   暗海每秒伤害 释放者最大魔力 ×0.06; 结附「噬心」需停留 2 秒;
#   次级暗海 持续 3 秒 / 半径 2 格; 全部暗海 +2 秒(★ 每片最多存在 10 秒 = 硬上限);
#   缓慢Ⅱ + 虚弱Ⅲ; 自身加成 +30%。
#   ★ 寿命口径(2026-10-06 用户): 基础寿命保持文案值(5 秒 / 3 秒), 但**上限 10 秒**
#     —— 续命只能续到 cap, 见 sea_spawn/sea_spawn_small/sea_extend 里的 sea_cap。
# 【★ 效果已实装(2026-10-06 晚)★】本目录各文件 + 进度 styx_walk_hit 都已就位,
#   挂载: manacore:event/second(styx_walk/second) + manacore:event/damage_calc(hook_calc)。
#   "暗海"本体 = item_display + **三形态随机**模型 sweetdream:sea_a/b/c(墨黑蓝底
#   + 16 帧幽蓝波纹, 主片直径 6 格 / 次级片 4 格; 三形态都是**自然湖泊**式的不规则
#   缓岸 —— a 缓湾湖 / b 长湖 / c 半月湖, 无尖角/无挖洞/无缺口),
#   入场铺开与退场收拢都走通用逐帧库 lib/anim_step。
#   面板侧的 +30% 显示在 lib/skill_mul/scan -> styx_walk/scan_mul。
# 【"暗海"是物件不是标签】用户原文用弯引号 “暗海”, 标签才用「」 —— 排版别混。
#   「噬心」是共用状态标签(不单独分段), “暗海”是本装备专属物件(单独分段)。
# 【★ 分段只有三段(用户 2026-10-06 纠正)】被动技能 / 暗海 / 套装效果。
#   ① "自身在暗海内技能伤害 +30%" 是暗海的效果 ⇒ 并入「暗海」段, **不另起「冥河」段**
#      (原文从没提过"冥河"这个名, 是我自己起的 —— 不许自己发明段名)。
#   ② 「暗海」段**不许用 ● 分条**, 三条规则连写成一段正文即可(● 只用于套装段的部件列表)。
#   ③ 套装段不能丢: 和靴子 lethe_shore 联动, 两段文字必须完全一致。
# 【模型】不写 item_model —— 盔甲走原版 netherite 外观。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s netherite_helmet[item_name={text:"漫步冥河之上",bold:true,color:dark_aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +210。自身攻击附有","color":"gray","italic":false},{"text":"「噬心」的生物后在其位置生成一个持续","color":"gray","italic":false},{"text":"5 秒、半径 3 格的“暗海”，之后 8 秒","color":"gray","italic":false},{"text":"不可再次触发该效果。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 暗海","color":"gold","bold":true,"italic":false},{"text":"未附有「噬心」的生物在“暗海”内每秒","color":"gray","italic":false},{"text":"受到相当于释放者最大魔力值 ×0.06 的伤","color":"gray","italic":false},{"text":"害，停留 2 秒后将结附「噬心」并在自身","color":"gray","italic":false},{"text":"位置生成一个持续 3 秒、半径 2 格的“","color":"gray","italic":false},{"text":"暗海”，之后将释放者生成的全部“暗海","color":"gray","italic":false},{"text":"”持续时间 +2 秒（每片最多 10 秒）。","color":"gray","italic":false},{"text":"附有「噬心」的生物在“暗海”内获得缓","color":"gray","italic":false},{"text":"慢Ⅱ和虚弱Ⅲ效果。自身在“暗海”内使","color":"gray","italic":false},{"text":"用关于最大魔力值的技能时技能伤害 +30%。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 漫步冥河之上","color":"gray","italic":false},{"text":"● 沉溺忘川彼岸","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身解除「残念」效果时若自身处于“暗","color":"gray","italic":false},{"text":"海”时，则本次被动伤害提高 100%","color":"gray","italic":false},{"text":"（独立乘区），之后自身下一次使用关于","color":"gray","italic":false},{"text":"最大魔力值的技能时技能伤害 +20%","color":"gray","italic":false},{"text":"（不可叠加）。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["styx_walk","helmet","armor"],tags:["shixin","max_mana","summon","apply","slow","debuff","indep_mul"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_styx_walk",equippable={slot:"head",asset_id:"sweetdream:armor_styx_walk",equip_sound:"minecraft:item.armor.equip_netherite"}]
