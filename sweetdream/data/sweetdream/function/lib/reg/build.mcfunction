# ============================================================
# sweetdream:lib/reg/build —— 「通用数值注册表」的构建(在 core/load 里跑一次)
# ------------------------------------------------------------
# 【这是干嘛的】
#   以前 debug/stats 里把"要显示哪些装备加成"**写死在代码里**
#   (只写死了静脉泵/桂冠/体外那几件), 所以新做的装备加了属性也看不见,
#   风行还单独占一个板块 —— 又乱又不通用。
#   现在改成: 显示什么由**这张表**决定, 代码只负责按表渲染。
#
# 【★ 2026-10-03 加了 e 字段: "穿着什么报什么" ★】
#   e = 这行加成**属于哪件装备**(就是 custom_data.zx[0] 那一段英文 id)。
#   debug/stats 每次都先扫一遍身上 6 个槽位, 只有"这件装备确实在身上"
#   的那些行才会被打印 —— 不再把所有装备一股脑全叠上来。
#     e:"intravenous_pump"    = 只有静脉泵穿在身上才显示
#     e:"all"                 = 全局行, 永远显示(合计账本/不属于单件的东西)
#   ⚠️ **漏写 e 的那一行永远不显示, 而且不报错** —— check.py 会抓。
#
# 【l 只写"分类", 别写装备名】
#   屏幕上长这样: "魔力上限 · 静脉泵    120"
#                  ^l    ^从 names 表查的全名
#   装备名统一从 names 表取 —— 想改名只改 names 一处, 这张表不用动。
#   全局行(e:"all")的 l 就是完整文字(因为没有装备名可拼)。
#
# 【★ 以后加了新装备/新武器有加成, 只要在下面加一行 ★】
#     data modify storage zx:reg b append value {l:"魔力上限",o:"zx.计分项",c:"aqua",n:"",e:"<装备id>"}
#   不用改任何别的文件。前提: ① 那个计分项得先在 core/load 里建出来
#   ② 装备 id 得在下面的 names 表里登记过。
#
# 【两张数值表】
#   b = 数值为 0 就不显示(账本类 —— 没穿的装备不该占地方)
#   a = 永远显示(状态类 —— 0 也是有效信息, 比如"风声 0")
#   ⚠️ 一行的字段(l/o/c/n/e)必须**都写全**: 宏参数少一个, 那条命令直接不跑
#      (不会报错, 更难查)。
#   ⚠️ l / n 会被塞进 tellraw 的 JSON 字符串里, **不要写英文双引号和反斜杠**。
#
# 【表位上限】b 最多 48 行, a 最多 8 行, menu 最多 12 行。
#   加超了就把 debug/reg_unroll 里的槽数补上, 同时改这里的 cap 和
#   .workbuddy/gen_reg_unroll.py 顶上的常量, 再跑一次那个脚本。
#   (check.py 会帮你数, 超了会报警。)
#
# 【另外两张表】
#   tg.*  = 每个 /trigger 调试入口(name 显示名 / fn 实际干的函数 / obj 计分项)
#   menu  = 菜单里按顺序列出来的入口(指向 tg 的键)
# ============================================================

# ---------- 建空表 ----------
#   【为什么要先 set []】debug/worn 之类会读 names, 而 load 可能被 reload 重跑;
#   不重置的话表会一直 append, 越滚越长(而且全是重复行)。
data modify storage zx:reg b set value []
data modify storage zx:reg a set value []
data modify storage zx:reg menu set value []
data modify storage zx:reg names set value {}

# ============================================================
# b: 数值为 0 就不显示 —— **按装备分组排序**, 同一件的行挨在一起
# ============================================================

# ---- 静脉泵 (intravenous_pump) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.pump_mana",c:"aqua",n:"",e:"intravenous_pump"}

# ---- 静脉泵 + 体外供能装置 的两件套装 ----
#   【为什么是 e:"all"】套装要求两件都在, 账本非 0 本身就说明都穿着了,
#   绑到哪一件都会在"只穿另一件"时把账藏掉, 所以放全局。
data modify storage zx:reg b append value {l:"套装魔力上限",o:"zx.set_mana",c:"aqua",n:"",e:"all"}
data modify storage zx:reg b append value {l:"套装生命上限",o:"zx.set_hp",c:"red",n:"",e:"all"}

# ---- 回魔账本(合计; 来源有静脉泵/桂冠/挽歌/黄昏套装, 不属于单件) ----
data modify storage zx:reg b append value {l:"回魔 · 装备额外",o:"zx.regen_last",c:"green",n:"/秒 (上一秒实收)",e:"all"}

# ---- 体外供能装置 (external_power) ----
data modify storage zx:reg b append value {l:"生命上限",o:"zx.power_hp",c:"red",n:"",e:"external_power"}

# ---- 狄俄尼索斯之桂冠 (dionysus_helmet) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.dio_mana",c:"aqua",n:"",e:"dionysus_helmet"}
data modify storage zx:reg b append value {l:"回魔 · 剩余",o:"zx.dio_regen",c:"green",n:"秒 (期间每秒 +80)",e:"dionysus_helmet"}

# ---- 脑髓蛭 (brain_leech) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.bl_mana",c:"aqua",n:"",e:"brain_leech"}
data modify storage zx:reg b append value {l:"基础攻击力",o:"zx.bl_atk",c:"gold",n:"",e:"brain_leech"}
data modify storage zx:reg b append value {l:"回魔修正",o:"zx.bl_regen",c:"green",n:"(1 = 已挂 +3/秒 的速率修正)",e:"brain_leech"}

# ---- 脊骨共生 (spine_symbiote) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.ss_mana",c:"aqua",n:"(负 = 拿上限换别的)",e:"spine_symbiote"}
data modify storage zx:reg b append value {l:"生命上限",o:"zx.ss_hp",c:"red",n:"",e:"spine_symbiote"}
data modify storage zx:reg b append value {l:"护甲",o:"zx.ss_armor",c:"white",n:"",e:"spine_symbiote"}

# ---- 群星坠落之挽歌 (stellar_elegy) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.se_mana",c:"aqua",n:"",e:"stellar_elegy"}
data modify storage zx:reg b append value {l:"回魔 · 剩余",o:"zx.se_regen",c:"green",n:"秒 (期间每秒 +10)",e:"stellar_elegy"}

# ---- 黄昏黎明之交界 (dusk_dawn) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.dd_mana",c:"aqua",n:"",e:"dusk_dawn"}
data modify storage zx:reg b append value {l:"套装魔力上限",o:"zx.dd_set",c:"aqua",n:"",e:"dusk_dawn"}
data modify storage zx:reg b append value {l:"击杀后临时魔力上限",o:"zx.dd_temp",c:"aqua",n:"",e:"dusk_dawn"}

# ---- 余烬 (ember) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.em_mana",c:"aqua",n:"",e:"ember"}

# ---- 焚舟 (immolate) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.im_mk",c:"aqua",n:"",e:"immolate"}
data modify storage zx:reg b append value {l:"套装 buff 剩余",o:"zx.im_buff",c:"gold",n:"秒 (期间 魔力上限 +100)",e:"immolate"}

# ---- 异彩 (iridescent) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.ir_mana",c:"aqua",n:"",e:"iridescent"}

# ---- 幻昼 (mirage) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.mr_mana",c:"aqua",n:"",e:"mirage"}
data modify storage zx:reg b append value {l:"基础攻击力",o:"zx.mr_atk",c:"gold",n:"",e:"mirage"}
data modify storage zx:reg b append value {l:"基础攻击力 · A层",o:"zx.mr_atk1",c:"gold",n:"",e:"mirage"}
data modify storage zx:reg b append value {l:"基础攻击力 · B层",o:"zx.mr_atk2",c:"gold",n:"",e:"mirage"}

# ---- 风行于大地之上 (wind_ontheground) ----
data modify storage zx:reg b append value {l:"回响期间魔力上限",o:"zx.wg_mana",c:"aqua",n:"",e:"wind_ontheground"}
data modify storage zx:reg b append value {l:"回响剩余",o:"zx.wg_aura",c:"light_purple",n:"秒",e:"wind_ontheground"}
data modify storage zx:reg b append value {l:"爆发剩余",o:"zx.wg_burst",c:"light_purple",n:"轮",e:"wind_ontheground"}

# ---- 寒鸦 (cold_crow) ----
data modify storage zx:reg b append value {l:"冰凌层数",o:"zx.cc_ice",c:"blue",n:"(0..3)",e:"cold_crow"}

# ---- 燎原 (liaoyuan) ----
data modify storage zx:reg b append value {l:"光环剩余",o:"zx.ly_aura",c:"gold",n:"秒",e:"liaoyuan"}
data modify storage zx:reg b append value {l:"离下次灼烧",o:"zx.ly_timer",c:"gold",n:"秒",e:"liaoyuan"}

# ---- 引梦镰 (sickle_dreams) ----
data modify storage zx:reg b append value {l:"强化锁定",o:"zx.sd_lock",c:"light_purple",n:"秒",e:"sickle_dreams"}

# ---- 烈火, 残躯 (flame_brokenbody) ----
data modify storage zx:reg b append value {l:"熔浆",o:"zx.fb_lava",c:"red",n:"层",e:"flame_brokenbody"}

# ---- 超·负·荷 (charge) ----
data modify storage zx:reg b append value {l:"超载剩余",o:"zx.chg_on",c:"yellow",n:"秒",e:"charge"}

# ---- 深海的回响 (deepsea_echo) ----
data modify storage zx:reg b append value {l:"下一波倒计时",o:"zx.de_t",c:"aqua",n:"tick (20 = 1 秒)",e:"deepsea_echo"}

# ---- 全局兜底类(平时是 0, 出现就说明有情况) ----
data modify storage zx:reg b append value {l:"魔力下限保护垫付",o:"zx.floor_mana",c:"dark_aqua",n:"(负 = 面板下限被救过)",e:"all"}

# ---- 升级系统(盔甲升级给的魔力上限, 账本就记在 zx.up_mana 上) ----
data modify storage zx:reg b append value {l:"升级·魔力上限",o:"zx.up_mana",c:"aqua",n:"(盔甲上的魔力提升 α/β/Ω)",e:"all"}

# ============================================================
# a: 永远显示(0 也有意义的) —— 同样要写 e, 只显示在身装备的
# ============================================================
data modify storage zx:reg a append value {l:"风声",o:"zx.wg_sound",c:"light_purple",n:"(超过 60 才有额外加成)",e:"wind_ontheground"}

# ============================================================
# names: 装备 id → 中文**全名**(worn / stats / name_row 都用它)
#   键 = give 里 custom_data 的 zx:[ "<id>" ] 那一段
#   ★ 做了新装备, 记得在这里补一行, 否则只显示英文 id ★
# ============================================================
data modify storage zx:reg names.intravenous_pump set value "静脉泵"
data modify storage zx:reg names.external_power set value "体外供能装置"
data modify storage zx:reg names.dionysus_helmet set value "狄俄尼索斯之桂冠"
data modify storage zx:reg names.brain_leech set value "脑髓蛭"
data modify storage zx:reg names.spine_symbiote set value "脊骨共生"
data modify storage zx:reg names.stellar_elegy set value "群星坠落之挽歌"
data modify storage zx:reg names.dusk_dawn set value "黄昏黎明之交界"
data modify storage zx:reg names.ember set value "余烬"
data modify storage zx:reg names.immolate set value "焚舟"
data modify storage zx:reg names.iridescent set value "异彩"
data modify storage zx:reg names.mirage set value "幻昼"
data modify storage zx:reg names.deepsea_echo set value "深海的回响"
data modify storage zx:reg names.flame_brokenbody set value "烈火, 残躯"
data modify storage zx:reg names.sickle_dreams set value "引梦镰"
data modify storage zx:reg names.cold_crow set value "寒鸦"
data modify storage zx:reg names.liaoyuan set value "燎原"
data modify storage zx:reg names.wind_ontheground set value "风行于大地之上"
data modify storage zx:reg names.liuguang set value "流光"
data modify storage zx:reg names.hengdao set value "横刀"
data modify storage zx:reg names.charge set value "超·负·荷"
data modify storage zx:reg names.look set value "观测镜"

# ============================================================
# tg: 每个 /trigger 调试入口
#   obj  = 计分项(core/load 里建的 trigger 型)
#   name = 菜单上显示的名字
#   fn   = 真正干活的那个函数(tg_xxx 那层只做归零/enable 的收尾)
#   ★ 加新入口: ① core/load 建 trigger 计分项 ② lib/reg/build 这里加一条
#              ③ debug/tg_router 加一行路由 ④ debug/second 加一行 enable
#              ⑤ 想上菜单就把键名写进 menu
# ============================================================
data modify storage zx:reg tg.stats set value {obj:"zx.dbg_stats",name:"查看自己的全部数值",fn:"sweetdream:debug/stats"}
data modify storage zx:reg tg.worn set value {obj:"zx.dbg_worn",name:"身上穿了什么装备",fn:"sweetdream:debug/worn"}
data modify storage zx:reg tg.diff set value {obj:"zx.dbg_diff",name:"对比上次快照: 变了什么",fn:"sweetdream:debug/diff"}
data modify storage zx:reg tg.raw set value {obj:"zx.dbg_raw",name:"原始面板数据(全部字段)",fn:"sweetdream:debug/raw"}
data modify storage zx:reg tg.cd set value {obj:"zx.dbg_cd",name:"立刻结束主手武器冷却",fn:"sweetdream:debug/cd_clear"}
data modify storage zx:reg tg.mana set value {obj:"zx.dbg_mana",name:"回满魔力(1000)",fn:"sweetdream:debug/recover_mana"}
data modify storage zx:reg tg.menu set value {obj:"zx.dbg_menu",name:"打开这个调试菜单",fn:"sweetdream:debug/menu"}
data modify storage zx:reg tg.give set value {obj:"zx.dbg_give",name:"发一套潜影盒(全部东西)",fn:"sweetdream:debug/give_all"}

# ============================================================
# menu: 菜单里按顺序列出来(tg 的键名; 顺序 = 屏幕上从上到下)
#   n = 鼠标悬停时显示的说明
# ============================================================
data modify storage zx:reg menu append value {k:"stats",n:"魔力 / 伤害 / 原版属性 / 回魔 / 在身装备的加成"}
data modify storage zx:reg menu append value {k:"worn",n:"6 个槽位各穿了什么, id 有没有认出来"}
data modify storage zx:reg menu append value {k:"diff",n:"先按一次存快照, 换完装备再按一次看变了什么"}
data modify storage zx:reg menu append value {k:"cd",n:"把主手那把武器自己的冷却清掉"}
data modify storage zx:reg menu append value {k:"mana",n:"瞬间回 1000 魔力(被上限夹住 = 回满)"}
data modify storage zx:reg menu append value {k:"raw",n:"manacore:players 里那份原始数据 + 冷却表"}
data modify storage zx:reg menu append value {k:"menu",n:"重新打印这个菜单"}
data modify storage zx:reg menu append value {k:"give",n:"发两个潜影盒: 装备全集 21 件 + 强化材料 7 块"}

# ---------- 记录本版本的表位上限(给 gen_reg_unroll.py / check.py 数用) ----------
data modify storage zx:reg cap set value {b:48,a:8,menu:12}
