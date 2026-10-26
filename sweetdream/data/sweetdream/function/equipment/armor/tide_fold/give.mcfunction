# ============================================================
# sweetdream:equipment/armor/tide_fold/give —— 给一件「折潮」（传说 · 头盔）
# ------------------------------------------------------------
# 【custom_data】"tide_fold" -> 装备 id; 判定写 custom_data~{zx:["tide_fold"]}
# 【机制】消耗「渊海」或累计消耗 150 魔力 ⇒ 在自身位置生成一面长 8 格（垂直于视线）、
#   持续 10 秒的水墙，同时最多 4 个；生物穿过 ⇒ 附加「渊海」+3 秒缓慢Ⅱ；自己穿过 ⇒ 3 秒迅捷Ⅱ
#   + 每 2 秒可回 1% 最大魔力；自身法术穿过墙并造成伤害 ⇒ 额外附加最大魔力 ×0.02 固定伤害 +「渊海」。
# 【★ 实装必读 ★】
#   ① 朝向必须定死（本稿 = 生成时垂直于视线的一道横墙，高 5 格），否则无从下手。
#   ② "穿过"用逐刻位置前后差与墙面线段相交判定（轨迹逐刻就地采样，别写死检测窗口）；
#      同一刻同一面墙只结算一次穿越；每2秒回魔的门控独立。
#   ③ "法术"口径要窄（本稿 = 法杖普攻法球 + 法杖主动法球），不含箭矢/斩击/光束/爆炸。
#   ④ 水墙**不是领域**，不占术阵位；它是私有资源，不进标签词表。
# 【外观】已接入8×5格流水水幕；耗魔每笔最多1面，不逐刻兑现积压。
# ============================================================
give @s netherite_helmet[item_name={text:"折潮",bold:true,color:blue},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +180。自身在消耗","color":"gray","italic":false},{"text":"「渊海」或累计消耗 150 魔力值后，在自","color":"gray","italic":false},{"text":"身位置生成一面长 8 格、高 5 格、持续","color":"gray","italic":false},{"text":"10 秒的水墙，同时最多存在 4 面。每次","color":"gray","italic":false},{"text":"实际消耗魔力最多生成 1 面水墙，超额消","color":"gray","italic":false},{"text":"耗仅保留不足 150 魔力值的零头，不会连","color":"gray","italic":false},{"text":"续补出水墙。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 水墙","color":"gold","bold":true,"italic":false},{"text":"穿过水墙的生物会被附加「渊海」并获得","color":"gray","italic":false},{"text":"3 秒缓慢Ⅱ，自身穿过水墙时获得 3 秒迅","color":"gray","italic":false},{"text":"捷Ⅱ，且每 2 秒穿过时可以恢复自身相当","color":"gray","italic":false},{"text":"于自身最大魔力值 1% 的魔力值。自身释","color":"gray","italic":false},{"text":"放的法术若穿过了水墙并对生物造成伤害","color":"gray","italic":false},{"text":"后则额外对受到伤害的生物附加相当于自","color":"gray","italic":false},{"text":"身最大魔力值 ×0.02 的固定伤害并使其附","color":"gray","italic":false},{"text":"加「渊海」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 折潮","color":"gray","italic":false},{"text":"● 返汐","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身获得迅捷Ⅰ效果。自身在海浪上时每","color":"gray","italic":false},{"text":"秒恢复 20 魔力值。若水墙在海浪上，则","color":"gray","italic":false},{"text":"海浪扩张至水墙所在的位置，且持续至水","color":"gray","italic":false},{"text":"墙结束。在这片海浪上的自身移速改为每","color":"gray","italic":false},{"text":"秒 +2%，生物每秒 -2%。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["tide_fold","helmet","armor"],tags:["yuanhai","max_mana","cur_mana","summon","apply","slow","debuff","buff","flat"]},tooltip_display={hidden_components:["unbreakable"]}]
