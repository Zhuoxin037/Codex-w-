# ============================================================
# sweetdream:overlimit/item/sculk_echo —— 给一块「超限·幽匿残响」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_sculk_echo :
#   进度 advancement/overlimit/sculk_echo 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[44.0f]}(八芒星, 编号 44)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「幽匿残响」能敲(见 overlimit/api/fit: 副手 zx 必须含 sculk_echo
#   且这件还没敲过 ol)。
# 【★ 机制落在哪(2026-10-10 实装) ★】超限版改三处数值 ——
#   ① 每次射击积攒 悲鸣 10 -> **20** 点、上限 50 -> **100**;
#   ② 命中范围 / 路径范围 **2 格 -> 3 格**;
#   ③ 三倍概率 **1%/点 -> 0.5%/点**(满层同样 50%)。
#   三处都读**离弦那一刻**拍下来的 `zx:work se.ol`(随快照带到命中点), 见
#   equipment/bow/sculk_echo/{shot,fire,roll_triple,tick_live,path_roll}。
#   ★ 为什么必须随快照: 命中结算要等箭落地才跑、路径伤更是整段飞行期都在算,
#     那时手里拿的未必还是这把弩(与「蚀骨」同款)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·幽匿残响",bold:true,color:light_purple},custom_model_data={floats:[44.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"幽匿残响","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后幽匿残响更名为「超限·幽匿残响」，","color":"gray","italic":false},{"text":"主动技能变为：每次射击会额外积攒 20","color":"gray","italic":false},{"text":"点「悲鸣」（上限 100 点），而每次射击","color":"gray","italic":false},{"text":"后都会对被射击的生物的 3 格内额外造成","color":"gray","italic":false},{"text":"相当于自身基础攻击力 ×「悲鸣」值 ×0.1","color":"gray","italic":false},{"text":"的伤害，同时对发射路径周围 3 格的敌人","color":"gray","italic":false},{"text":"每刻造成相当于「悲鸣」值 ×0.1 的伤害。","color":"gray","italic":false},{"text":"每 1 点「悲鸣」会使该伤害有 0.5% 概率","color":"gray","italic":false},{"text":"造成三倍伤害，触发后清除全部「悲鸣」。","color":"gray","italic":false}],custom_data={zx:["ol_sculk_echo"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
