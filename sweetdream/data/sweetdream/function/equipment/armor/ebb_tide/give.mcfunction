# ============================================================
# sweetdream:equipment/armor/backflow/give —— 给一件「返汐」（传说 · 靴子）
# ------------------------------------------------------------
# 【custom_data】"ebb_tide" -> 装备 id; 判定写 custom_data~{zx:["ebb_tide"]}
#   ★ 别写成 backflow —— 包里已有一把剑叫 backflow_tide（回潮），名字太近容易看串。
# 【机制】8 格内有带「渊海」的生物 ⇒ 在其移动后的位置留 5 秒海浪；自己在浪上移速每秒 +1%（最多 +20%），
#   生物每秒 -1%（最多 -30%）；离开急速衰减；自身"最大魔力相关技能伤害"按自身移速增量增加
#   （每快 10% ⇒ +5%），生物受到的伤害按其减速量增加（每慢 10% ⇒ +3%）。
# 【★ 实装必读：字面量禁区 ★】
#   移速百分比同样**不能吃计分项** ⇒ +1%..+20% 需要 20 条、-1%..-30% 需要 30 条
#   attribute modifier（切换时先 remove 上一档）。表必须一次写全 —— 漏一档就会"到顶后掉回初值"
#   （折径 pick_mul 少了 m7/m8 就是这个毛病）。
# 【★ 其余 ★】海浪每 0.5 秒采样一次（位移 >0.8 格才补片），每只渊海生物各留一片、最多 6 片；
#   衰减量化为每秒回落 10 个百分点（不是立刻清零，否则拉扯进出没手感）。
# 【外观】未画（无 item_model / equippable）。
# ============================================================
give @s netherite_boots[item_name={text:"返汐",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +180，移动速度 +10%。","color":"gray","italic":false},{"text":"自身 8 格内若有附加了「渊海」的生物则","color":"gray","italic":false},{"text":"使其在移动后的位置留下持续 5 秒的海浪。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 海浪","color":"gold","bold":true,"italic":false},{"text":"自身在海浪上移速将每秒增加 1%，最多增","color":"gray","italic":false},{"text":"加 20%，生物在海浪上移速将每秒减少 1%，","color":"gray","italic":false},{"text":"最多减少 30%。离开海浪后增益或减益将","color":"gray","italic":false},{"text":"极速衰减。且自身最大魔力值相关的技能","color":"gray","italic":false},{"text":"伤害将根据在海浪上的移速来增加，每比","color":"gray","italic":false},{"text":"初始数值快 10% 则伤害 +5%。生物受到的","color":"gray","italic":false},{"text":"伤害也将根据在海浪上的移速来增加，每","color":"gray","italic":false},{"text":"比初始数值慢 10% 则其受到的伤害 +3%。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 折潮","color":"gray","italic":false},{"text":"● 返汐","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身获得迅捷Ⅰ效果。自身在海浪上时每","color":"gray","italic":false},{"text":"秒恢复 20 魔力值。若水墙在海浪上，则","color":"gray","italic":false},{"text":"海浪扩张至水墙所在的位置，且持续至水","color":"gray","italic":false},{"text":"墙结束。在这片海浪上的自身移速改为每","color":"gray","italic":false},{"text":"秒 +2%，生物每秒 -2%。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["ebb_tide","boots","armor"],tags:["yuanhai","max_mana","summon","slow","debuff","buff","indep_mul"]},tooltip_display={hidden_components:["unbreakable"]}]
