# 我的世界 Java 1.21.5 数据包工作区

这里放着两个配套的数据包，加一套文档。**先读这份，再读 `使用教程.md`。**

## 里面有什么

| 路径 | 是什么 |
| --- | --- |
| `manacore-1.0.0/` | **前置包**：魔力 / 属性面板 / 伤害计算 / 冷却 / 术阵 / 回魔 的通用框架，跟具体玩法无关 |
| `sweetdream/` | **应用层**：具体的东西。目前有流光（武器）和观测镜（数值面板道具） |
| `使用教程.md` | 完整教程：接口怎么调、技能怎么写、属性怎么加减、踩过的坑 |
| `sweetdream/README.md` | 应用层的目录结构 + 新增一件道具的步骤 |

## 怎么装进游戏

两个包必须**同时**放进存档的 `datapacks` 目录，缺一个都不行（应用层依赖前置包）：

```
<saves>/<存档名>/datapacks/
├── manacore-1.0.0/
└── sweetdream/
```

然后 `/reload`。**这两个目录是复制进去的，不是链接** —— 在本目录改完代码，
必须重新复制一遍再 `/reload`，否则游戏里跑的还是旧版本。

本机的游戏目录：
`D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\saves\<存档名>\datapacks\`
（注意存档在**版本目录**下面，不在 `.minecraft\saves`。）

**省事的办法：双击 `部署到存档.bat`。**

- 直接双击 → 部署到默认存档 `sweetdream_test`
- 把别的**存档文件夹**（里面有 `level.dat` 的那个）拖到它图标上 → 部署到那个存档
- 它用 `robocopy /MIR` 镜像复制，所以源里删掉的文件目标里也会跟着删，
  不会留下旧版本的残留函数；部署完进游戏 `/reload` 就行
- 拖错目录会直接报错退出，不会乱建文件夹

> `部署到存档.bat` 只是个 ASCII 启动器，真正的逻辑在 `deploy.ps1`。
> 为什么不写在一个 `.bat` 里：**中文写进 `.bat` 会被 cmd 按 GBK 解码成乱码**，
> cmd 会把乱码碎片当命令执行。所以启动器保持纯 ASCII，中文放在
> 带 BOM 的 `.ps1` 里（这个坑实测踩过）。

## 约定

| 东西 | 用什么 | 说明 |
| --- | --- | --- |
| 命名空间 | `sweetdream:` | 应用层的函数、进度、标签 |
| 存储 | `zx:` | `zx:data`（存东西）/ `zx:work`（临时）/ `zx:out` / `zx:config` |
| 计分板 | `zx.meta` | 应用层内部用 |
| 前置包 | `manacore:*` | 那是它的地盘，别混用 |

玩家数据一律**按 UUID 分键**存在 `manacore:players."<uuid>"` 下面，
所以每个人的魔力、攻击、冷却都是独立的。

改完代码跑一遍静态自检，这几条是历史上真出过事的：

1. 含 `$(变量)` 的行必须以 `$` 开头；不含变量的行绝对不能加 `$`
2. `data get/modify/remove entity` 的选择器必须是**单个实体**（`limit=1`）
3. 进度奖励函数第一行必须 `advancement revoke @s only <自己那条进度>`
4. `function` / `schedule function` 引用的目标文件必须存在

## 当前状态

- **前置包**：属性面板、魔力（含恢复修正 / 倍率 / 禁用）、冷却（秒级 / tick 级 / 多技能 / 缩减 / 重置）、
  术阵（创建 / 删除 / 查数 / 续时 / 上限可改）、伤害计算、事件标签，都可用。
- **流光**：右键锁定 8 格内一个随机生物，3 秒后造成基础攻击 ×2（保底 6）的伤害，
  冷却 20 秒，消耗 20 魔力。诊断入口 `/function sweetdream:equipment/sword/liuguang/diagnose`。
- **观测镜**：`/function sweetdream:equipment/tool/look/give` 拿一个，右键开关动作栏面板
  （攻击 / 生命 / 魔力 / 术阵 / 最近技能的冷却）。
- **横刀**：`/function sweetdream:equipment/sword/hengdao/give`。消耗 15 魔力、20 秒冷却，
  向前突进最多 3 格（撞到生物或障碍停下），对落点 2 格内全部生物造成
  自身最大魔力 × 0.08 的伤害。
- **深海的回响**：`/function sweetdream:equipment/sword/deepsea_echo/give`。
  标记 12 格内最近的生物并附加「渊海」，1 秒后开始**连锁扩散**（一波 → 1 秒 → 下一波），
  每波对每个"源"周围 3 格造成当前魔力 ×0.15 的伤害，重复 2 次（每次额外 110 魔力）。
  诊断入口 `/function sweetdream:equipment/sword/deepsea_echo/diagnose`。
- **护甲三件**：静脉泵（胸甲，魔力上限 +120 / 满血回魔）、体外供能装置（护腿，
  生命上限 +8 / 满魔再生）、狄俄尼索斯之桂冠（头盔，魔力上限 +200 /
  受伤 20% 触发反胃 III + 力量 III + 每秒回 80 魔力共 3 秒）。
  静脉泵 + 体外 = 套装（魔力上限再 +120、生命上限再 +15、双满给力量迅捷）。
  自检入口 `/function sweetdream:equipment/armor/intravenous_pump/diagnose`。
- **右键分派**：右键被拆成两条独立的线 —— 通用的"回手线"和每把武器自己的
  "技能线"，所以现在可以做第二、第三把武器了。新增一把武器 = 三个文件
  （give / advancement / cast），三处名字必须一致，写法见 `使用教程.md` §9.5。

## 已知问题

- **玩家 UUID 只算出 8 位**（例如 `0000000f`），正常应该是 36 位。
  入口在 `manacore-1.0.0/data/manacore/function/internal/uuid/build.mcfunction`。
  目前不影响使用（所有键都用同一个值，自洽），但这是个真的要修的 bug。
- ~~原版没有"绕过无敌帧"的伤害类型标签~~ **已解决。** 原版其实**有**这个标签：
  `minecraft:bypasses_cooldown`（1.21.5 里由 `DamageTypeTags` 注册，只是原版一个
  伤害类型都没往里放，所以平时看不出它存在）。sweetdream 现在注册了自己的类型
  `sweetdream:skill`（`data/sweetdream/damage_type/skill.json`）并把它挂进这个标签 ——
  技能伤害**不再被受伤无敌帧吃掉**，所有技能默认都用它（照样吃护甲/保护附魔/抗性）。
  副作用：同一 tick 的多段伤害现在会全部结算，以前"只算第一段"的技能会明显变强
  （风行的"3 个术阵"以前只能看到 3 次伤害，现在才是真的 9 次），击退也会叠加 ——
  以后做平衡时按"多段全额生效"来算。
- ~~武器放副手右键会顶掉主手的武器~~ **已解决。** 回手写死了 `weapon.mainhand`：
  副手那把从来没被备份过（用完就消失），而盔甲架主手槽里留着上一次主手那把，
  回手时又被塞进主手 —— `item replace` 是覆盖式的，主手的东西**直接没了，不会掉地上**。
  现在主手/副手各备份一份（盔甲架两个槽位），触发那一瞬间记录用的是哪只手，
  回手按标签分叉写回对应槽位，并且回手前先确认架子上有东西。
  观测镜不走通用线，但它自己的 `return_item` 是同一个毛病，一并改了。
  自查入口 `/function sweetdream:debug/offhand`。详见 `使用教程.md` §9.5。
- **⚠️ 新增伤害类型后必须"退出世界重进"，症状是"就那两处技能没伤害"。**
  `damage_type` 是"注册表"类内容，只在进世界时加载，`/reload` 不会补上它。
  本包的 `sweetdream:true_damage`（异彩的效果二 + 幻昼的时停结束伤害）就是新增的；
  没重进世界时这两处的 `/damage` 会**静默失败** —— 不报错、不写日志，只表现为
  "技能放出来了但一点伤害都没有"。其它技能走早就注册好的 `sweetdream:skill`，
  所以症状必然是"别的都正常，就这两处哑火"。
  一秒判定：`/function sweetdream:debug/true_damage`。
  第一次装（或改了 `data/sweetdream/damage_type/skill.json`）之后必须**退出世界再进来**。
  只 `/reload` 的话日志里会出现
  `Couldn't load tag minecraft:bypasses_cooldown ... sweetdream:skill (from file/sweetdream)`，
  **症状是所有技能一点伤害都没有**（`/damage` 拿到不存在的类型就整条失败）。
  保险开关（万一类型没生效）：
  ```mcfunction
  /data modify storage zx:config damage_type set value "minecraft:player_attack"
  /reload
  ```
  这是"退回原版平砍类型"的应急按钮，代价是多段伤害又会撞无敌帧。
- **同一类坑：改了附魔 `enchantment/*.json` 也要退出世界重进。**
  寒鸦的命中判定完全靠附魔「霜矢」（`data/sweetdream/enchantment/cold_crow.json`）。
  改完它的效果表只 `/reload` **不会注册**，症状和上面那条很像：
  "寒鸦能射、扣了魔力，打中什么都没发生"；严重时那条 `give` 自己都会加载不出来。
  改完必须**退出世界重进 + 重新 give 一把**（老物品不会自己长出附魔）。
  一秒判定：`/function sweetdream:debug/cold_crow`（看 ① ② 两行）。
- ~~寒鸦按射手保存"最近一发"，在途旧箭会被后发覆盖~~ **已解决。** 改成**逐箭快照**：
  每支箭随身带自己那一发（存实体 `data.zx.cc`）。`core/tick` 每刻先给场上已有的箭打
  `zx.cc_seen`，所以 `shot` 里"唯一没带这个标记的那支箭"就是刚射出去的（多重射击那 3 支一起抓）；
  命中时 `snap_prep` 先铺"射手最近一发"、再用箭自己那份整个覆盖。射手名下那份**保留为兜底**
  （认不到箭时退化成旧行为，不会没效果）。附魔效果表新增 `affected:"damaging_entity"`
  （= 那支箭）用来把箭交给 `hook_arrow`。**这次改动必须退出世界重进才生效。**
  自检：`/function sweetdream:debug/cold_crow` 的 ⑤。
- ~~幻昼可能把效果施加给错误的生物~~ **已解决。** 改用生物自己的 `last_hurt_by_player`
  （原版为了"怪报复玩家"记的字段：受伤那一刻写入打人者的 UUID，5 秒后清）精确匹配，
  `HurtTime` 10/9 只负责钉住"就是刚才这一下"；顺带删掉 16 格距离限制，修掉远程命中漏选。
  老的就近启发式保留为兜底（摔落之类没有"动手的人"的伤害会走它）。
- ~~概率与坐标 / 攻击节奏绑定~~ **已解决。** 新增 `sweetdream:lib/rnd`（全局 LCG，
  出参 `0..32767` 非负）：每调用一次推进一步，连调两次就是两次**独立**抽样。
  幻昼的两次 20%、异彩的"5 选 2"全部改从它取样，和坐标、攻击间隔彻底脱钩 ——
  以前"站着不动 + 间隔是 5 的倍数"会让 20% 变成"要么一直中、要么一直不中"。
- ~~副手引梦镰会扣费却不释放~~ **已解决。** 在 `cast`（`consume_item` 那一瞬间）判定
  "这一下用的是哪只手"并写进施法快照 `hand`；`wait` / `check` / `normal` / `heavy` / `restore`
  全部按它走（`normal` / `heavy` 因此从写死主手改成宏函数 `$(hand)`，几十行都要补 `$`）。
  `check` 的 `SelectedItemSlot` 校验改成只在主手施法时做 —— 副手拿镰刀时换快捷栏不影响它。
- **⚠️ 一行命令解析不了 = 整个函数不可用（不是"少那一句"）。**
  普通函数会**加载失败**（日志 `Failed to load function ...`），宏函数则是
  **整个函数一条命令都不跑**（Minecraft Wiki「Function (Java Edition)」）。踩过两次：
  1. **dust 粒子必须写花括号选项**：`particle minecraft:dust{color:[r,g,b],scale:s} …`。
     老式位置参数写法（`particle minecraft:dust 0.9 0.8 1.0 1.2 …`）会让整个函数加载失败
     —— 幻昼 `ts_dmg` 就栽在这，表现为"时停结束了一点伤害都没有"。
  2. **`tellraw`/`title` 组件里别混进未转义的 ASCII 双引号**（中文引号用 `「」`，或写 `\"`）。
     `debug/true_damage` 曾因此整支加载失败，连带"诊断工具在最需要时不可用"。
  3. **只认玩家的命令不能配 `@e`**：`tellraw`/`title`/`clear`/`give`/`xp`/`advancement`
     的"目标"在命令树里是 **players-only**，写 `tellraw @e[tag=xxx]` 是**解析期**失败
     （日志：`只有玩家会受此命令的影响，但提供的选择器包括其他实体`）。
     `debug/cold_crow_probe` 要对**箭**说话（那一刻 `@s` 是箭）就这么栽过一次 ——
     整个诊断函数不加载，第 ⑤ 项永远没输出。改用 `@a[tag=…,limit=1]`（本包既有范式）。
  `.workbuddy/check.py` 第 9、10、12 项会抓这三类（第 13 项另抓 `as` 非玩家 + `tellraw @s`
  这种**运行时静默失效**）；**因为"解析失败"会连坐整个文件，
  所以改完务必看日志有没有 `Failed to load function`**。
- **别把"替换"写成"新增"**：给某一行加包装时旧那行没删掉，就会前后脚跑两遍，
  而且不报错、日志干净、数值看着正常。`internal/damage/go` 踩过一次 ——
  `/damage` 被执行两遍 = **全包所有伤害翻倍**，两遍都带 `store success`，
  连 `#dbg_dmg` 都一样，肉眼完全看不出来。check.py 第 11 项专抓这个
  （"命令流里紧挨着的两条相同命令"；有意重复的在那行上面写 `dup-ok: 理由` 豁免）。
- **★ 改了源目录 ≠ 游戏里生效**：让用户进游戏测之前必须重新部署（`部署到存档.bat`）。
  报错日志里的**行号和源文件对不上**，就是"游戏读的是旧版"的最强信号 ——
  先 `diff -rq D:\数据包\<包> "<存档>\datapacks\<包>"`，别急着当代码 bug 查。

## 新开一个对话怎么接着干

把下面这段直接发给新对话就行：

```
工作目录是 D:\数据包，先读 D:\数据包\README.md 和 D:\数据包\使用教程.md，再动手。
这是两个配套的 Minecraft Java 1.21.5 数据包：manacore-1.0.0（前置框架）和
sweetdream（应用层）。改完记得做静态自检，并用中文详细注释。
```

新对话不会记得我们聊过什么，**文档就是交接内容** —— 所以约定、踩过的坑、
当前状态都写在这两个文件里。要是想到什么该记的事，先补进 `使用教程.md` 再走。
