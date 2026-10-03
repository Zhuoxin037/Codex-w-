# ============================================================
# sweetdream:overlimit/def/load —— 超限定义表(由 core/load 调用)
# ------------------------------------------------------------
# 【存在哪】zx:config oldef."<武器id>" = {label:"..", name:{..}, note:"..", dmg:.., mana:.., cd:.., lore:[..]}
#   label = 中文全名(纯文本, 只给脚本/文档看)
#   name  = 【★ 物品**改名**成什么 ★】直接就是 item_name 组件, 整段拷到物品上
#           (见 overlimit/api/name_seed)。所以这里的写法必须是完整的文本组件,
#           想加粗/上色就在这写: {"text":"超限·流光","bold":true,"color":"light_purple"}
#           ⚠️ 它是**数据**, 不走宏, 所以双引号随便用。
#   note  = 一句话备注(目前不显示, 只当注释)
#   dmg   = 超限后整把武器伤害乘区加算(0.25 = +25%) —— 乘进 skill_multiplier
#   mana  = 魔力消耗乘区加算(+0.30 = 耗蓝多 30%)   —— 乘进 check / consume 的 mana
#   cd    = 冷却乘区加算(+0.25 = 冷却长 25%)       —— 乘进 cooldown_seconds
#   lore  = 【★ 超限后的**整段描述**★】敲上之后物品的描述会被它**整段替换**,
#           不再是"原描述 + 追加一行"(玩家没法从追加行里看懂技能变成什么了)。
#           见 station/api/lore_refresh 的 ②。
#
# 【★ 超限 = 改名 + 整段换描述 ★】敲上之后物品会 ① 改名成 name 里的名字(超限·XX),
#   ② 描述整段换成 lore。原来那把武器的名字和描述都不再保留 ——
#   玩家拿在手里看到的就是"这是超限·流光, 它怎么用"。
#
# 【★ lore 必须和实装一致 ★】这三档数值由 overlimit/api/mod 在每个耗蓝/冷却/
#   技能倍率处真实乘进去(调用点见该函数注释)。所以 lore 里写的"魔力 325"
#   必须 = 原始 250 ×(1+0.30); 改了这个表, lore 里的数字要跟着改。
#
# 【每个武器一条】只有"和武器 id 对应的超限石"才敲得上(见 overlimit/api/fit)。
#   武器独有的那部分效果写在武器自己的超限钩子里(见文档)。
# 【字段写法限制】label / note / lore 里的字符串会被宏塞进 JSON 文本组件, 所以
#   不能出现英文双引号和反斜杠; 逗号、中文标点都可以。
# 【lore 排版】照抄 equipment/*/give:
#   ✦ 小标题(gold bold) / 拼色数值行 / 空行 {"text":" "} / 灰色正文(每行约 17.5~18.5 汉字宽硬切)。
#   ⚠️ **不要再写 "✦ 超限·XX" 这种总标题** —— 名字已经改成"超限·XX"了,
#      描述里再写一遍等于同一个名字印两行。
#   ⚠️ 也不要写"用法：……"这类收尾行 —— 右键怎么用是包内通用常识, 占地方。
# ============================================================

# 燎原: 伤害 +25% / 耗蓝 +30% / 冷却 +25%
#   -> 魔力 250 x1.30 = 325; 冷却 50 x1.25 = 62.5; 倍率 0.04 x1.25 = 0.05
data modify storage zx:config oldef."liaoyuan" set value {label:"超限·燎原",name:{"text":"超限·燎原","bold":true,"color":"light_purple"},note:"灼烧更强, 但更耗蓝、冷却更长",dmg:0.25,mana:0.30,cd:0.25,lore:[{"text":"","italic":false,"extra":[{"text":"伤害 ","color":"gray"},{"text":"+25%","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"耗蓝 ","color":"gray"},{"text":"+30%","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"+25%","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"325","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"62.5 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后自身获得「超限·燎原」：18 秒内","color":"gray","italic":false},{"text":"每 2 秒对自身 5 格内的生物造成一次相","color":"gray","italic":false},{"text":"当于自身最大魔力值 ×0.05 的伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 燎原","color":"gold","bold":true,"italic":false},{"text":"伤害每进行 3 次，其中第 3 次会额外使","color":"gray","italic":false},{"text":"受到伤害的生物附加「流火」。","color":"gray","italic":false}]}

# 风行: 伤害 +20% / 耗蓝 +20% / 冷却 +20%
#   -> 普攻 80 x1.20 = 96; 技能 550 x1.20 = 660; 冷却 120 x1.20 = 144
#      倍率 0.04 x1.20 = 0.048; 0.07 x1.20 = 0.084
data modify storage zx:config oldef."wind_ontheground" set value {label:"超限·风行于大地之上",name:{"text":"超限·风行于大地之上","bold":true,"color":"light_purple"},note:"风声相关效果增强",dmg:0.20,mana:0.20,cd:0.20,lore:[{"text":"","italic":false,"extra":[{"text":"伤害 ","color":"gray"},{"text":"+20%","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"耗蓝 ","color":"gray"},{"text":"+20%","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"+20%","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"96","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"当前魔力值 ×0.048","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻后自身获得 1 秒迅捷Ⅲ。若自身","color":"gray","italic":false},{"text":"术阵占用已满则本次攻击伤害 ×2.5。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"660","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"144 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤 X 个术阵（X 为自身当前剩余","color":"gray","italic":false},{"text":"的可召唤术阵数量）。每召唤一个术阵则","color":"gray","italic":false},{"text":"自身对自身 12 格内随机一个生物的 5 格","color":"gray","italic":false},{"text":"内的全部生物造成 3 次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.084 的伤害，每命中一个生物则","color":"gray","italic":false},{"text":"为自身积攒一点「风声」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 风声","color":"gold","bold":true,"italic":false},{"text":"召唤完术阵后自身若有超过 60 点","color":"gray","italic":false},{"text":"「风声」则每超出一点都会为下一次自身","color":"gray","italic":false},{"text":"使用最大魔力值相关的技能伤害提升 1%，","color":"gray","italic":false},{"text":"之后每有一点「风声」则自身最大魔力值","color":"gray","italic":false},{"text":"提升相当于「风声」×10 的数值并对自身","color":"gray","italic":false},{"text":"5 格内的生物造成 5 次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.048 的伤害，持续 20 秒。结束","color":"gray","italic":false},{"text":"后清除「风声」。","color":"gray","italic":false}]}

# 流光: 数值上不动(三个乘区都 0), 超限给的是**一个新技能** ——
#   敲上之后右键放的就是「超限·流光」, 见 equipment/sword/liuguang/overlimit。
#   所以它的 lore 是整段新技能描述, 原本那条"锁定 1 个 / 8 格 / ×2 / 保底 6"
#   会被完全替换掉。
data modify storage zx:config oldef."liuguang" set value {label:"超限·流光",name:{"text":"超限·流光","bold":true,"color":"light_purple"},note:"超限后右键放的是全新技能",dmg:0.0,mana:0.0,cd:0.0,lore:[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"120","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"8 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"随机锁定自身 10 格内的 4 个生物，其中","color":"gray","italic":false},{"text":"一个必定为离自身最近，期间其获得缓慢","color":"gray","italic":false},{"text":"Ⅲ。3 秒后对其造成相当于自身基础攻击","color":"gray","italic":false},{"text":"力 ×4 的伤害（保底 15）。若其身上附有","color":"gray","italic":false},{"text":"「流火」或「夜火」则伤害翻倍。","color":"gray","italic":false}]}
