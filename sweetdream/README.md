# sweetdream —— 应用层（装备 / 道具 / 技能）

配 `manacore-1.0.0`（数值框架）使用。这个包只做"具体的东西"：武器、道具、技能流程。

## 目录结构

```
sweetdream/
├─ data/minecraft/tags/function/   load / tick 两个入口
├─ data/manacore/tags/function/    挂在框架事件上的钩子(标签会与前置包合并)
└─ data/sweetdream/
   ├─ advancement/
   │  ├─ itembackup/               消耗型道具的"用完还手"三件套
   │  └─ equipment/                右键触发, 按下面的分类分层放
   ├─ function/
   │  ├─ core/      load / tick
   │  ├─ api/       公开接口(给别人调, 改要谨慎)
   │  ├─ internal/  内部实现(装备不要直接调)
   │  ├─ lib/       uuid、数字转字符串等小工具
   │  ├─ debug/     排错用
   │  ├─ example/   示例
   │  └─ equipment/ ★ 先分大类, 再一件一个文件夹
   │     ├─ sword/  剑类   liuguang(流光) / hengdao(横刀) / deepsea_echo(深海的回响)
   │     ├─ axe/    斧类   charge(超•负•荷)
   │     ├─ bow/    弓类   (空着, 见里面的 README)
   │     ├─ staff/  法杖   wind_ontheground(风行于大地之上)
   │     ├─ armor/  盔甲   dionysus_helmet / external_power / intravenous_pump
   │     └─ tool/   道具   look(观测镜)
   └─ tags/entity_type/no_damage.json   不该被打的实体(含玩家)
```

> 分类文件夹名必须是**英文**(`sword`/`axe`/`bow`/`staff`/`armor`/`tool`)：
> 函数路径只允许小写字母、数字和 `_ - . /`，**中文会让函数 id 非法、整个包加载失败**。
> 每件装备的文件夹名和装备的 id 保持一致（`equipment/sword/liuguang/` ↔ 进度
> `sweetdream:equipment/sword/liuguang` ↔ `custom_data` 里的 `"liuguang"`）。

## 命名约定

| 东西 | 用什么 | 说明 |
| --- | --- | --- |
| 命名空间 | `sweetdream:` | 函数、进度、标签都用它 |
| 数据存储 | **`zx:`** | `zx:in` / `zx:out` / `zx:work` / `zx:data` / `zx:config` |
| 计分板 | `zx.meta` | 框架内部用 |
| 前置包 | `manacore:*` | 那是它的地盘，别混用 |

## 新增一把武器的步骤

三件东西，**名字必须完全一致**。写错的表现是"右键毫无反应"且不报错，是最难查的一类。

1. `equipment/<分类>/<名字>/give.mcfunction` —— 给物品（分类 = sword/axe/bow/staff/armor/tool）。
   `custom_data` 里必须带三个标记：
   `custom_data={zx:["<名字>","itemreplace"], skill:"sweetdream:<名字>"}`
   - `itemreplace`：让通用回手线认出"这是消耗型道具"
   - `<名字>`：武器 id，进度 `equipment/<分类>/<名字>` 靠它认人
   - `skill`：**观测镜靠它显示冷却** —— 拿着这把刀就显示这条冷却，拿别的就显示 0。
     必须和 cast 里 `api/skill/check`、`api/cooldown/start` 传的 `skill` 完全一致。
2. `advancement/equipment/<分类>/<名字>.json` —— `consume_item` 触发，条件是
   `custom_data.zx` 里出现 `<名字>`，奖励指向
   `sweetdream:equipment/<分类>/<名字>/cast`。
3. `equipment/<分类>/<名字>/cast.mcfunction` —— 技能本体。
   **第一行必须是 `advancement revoke @s only sweetdream:equipment/<分类>/<名字>`**，
   否则这个进度一辈子只触发一次（第二次右键毫无反应）。
4. 技能流程照抄 `equipment/sword/liuguang/cast.mcfunction` 的骨架：
   `撤进度 → 读 UUID → 只读检查(冷却+魔力) → 锁目标 → 扣蓝 → 记冷却 → 算伤害 → schedule 延迟结算`
5. 需要延迟结算（"3 秒后再打"这种）就照抄流光那四件套：
   `hit` + `hit_self` + `hit_due` + `hit_calc`。
   那是跨 tick 结算的完整写法 —— 包括"多人同时放不会互相串"的隔离方式，
   以及怎么在 schedule 出来的函数里找回施法者。

### 右键为什么是两条线

| 线 | 进度 | 函数 | 职责 |
| --- | --- | --- | --- |
| 回手线（通用，所有消耗型道具共用） | `itembackup/consume`（条件 `zx:['itemreplace']`） | `internal/itembackup/effect_1` | 只负责把刀还回你手里 |
| 技能线（每把武器一条） | `equipment/<分类>/<名字>`（条件 `zx:['<名字>']`） | `equipment/<分类>/<名字>/cast` | 只负责放技能 |

两条线在同一次 `consume_item` 事件上同时触发，互不干扰。好处：

- 冷却中右键 = 刀回来了、技能没放、聊天栏提示还剩多久
- 某把武器的 cast 写坏了，回手机制照样好使

`zx` 数组的匹配规则是"**按顺序包含**"，所以 `zx:["liuguang","itemreplace"]`
能同时被 `zx:['liuguang']` 和 `zx:['itemreplace']` 匹配到。

## 通用状态标签（已实现，2026-10-01 重做）

渊海 / 流火 / 夜火 / 噬心 / 白昼梦统一由 `sweetdream:tag/mark`、`unmark` 管理。
状态保存在原生实体标签 `zx.status.<mark>`，不写普通生物不支持的自定义 NBT。
显示采用完整 UUID 绑定的单个 `text_display`，最多五个图标组成一行；每两刻跟随、每秒校验，覆盖原版三个维度。
调用写法、升级迁移和回归自检见根目录 `使用教程.md` §9.10。

## 装备被动效果（已做：静脉泵 / 体外供能装置 / 套装）

穿戴生效的效果挂在 `#manacore:event/second` 上，**每秒跑一次**。
**每件装备的逻辑写在它自己的文件夹里**（不另开公共文件夹），
并在 `data/manacore/tags/function/event/second.json` 的 `values` 里
登记自己那一行 —— 以后加新装备，只加一行，不动别人的代码：

```
equipment/armor/intravenous_pump/   second / passive / apply_mana / regen_mana / diagnose
equipment/armor/external_power/     second / passive / apply_hp        ← 套装也写在这里
```

每份 `passive.mcfunction` 以**玩家**为单位做三件事：

1. 按装备自带的 `custom_data.zx` 认出穿了哪几件 —— 用
   `execute if items entity @s armor.<head|chest|legs|feet> 物品[custom_data={...}]`
   （这套写法在以前那个 `zhuoxin` 包里已经跑通过；**物品 id 也写在判定里**，
   以后换底材要同时改 `give` 和这里）
2. 算出"应该加多少"魔力上限 / 生命上限（含套装），和账本求差 → 只加差值
3. 处理带条件的持续效果（满血回魔 / 满魔再生 / 双满给 buff）

**每个"加成来源"有自己的账本计分项**（每人一份）：`zx.pump_mana` /
`zx.set_mana` / `zx.power_hp` / `zx.set_hp`。各自穿上加、脱下减，互不干涉，
所以整套不需要宏函数。

> ⚠️ **`execute if items` 里的 `custom_data={...}` 是精确比对。**
> 装备的 `custom_data` 有两段（`["intravenous_pump","chestplate"]`），
> 判定里就必须写**整份**两段。只写一段会永远匹配不上，而且**不报错、不闪红**，
> 表现就是"整套效果毫无反应"。这个坑踩过一次，改 `give` 时记得同步改判定。

## 深海的回响：连锁扩散（已做）

这是目前结构最复杂的一件武器，机制是"一波 → 1 秒 → 下一波"的连锁：

```
cast  →  seed   挑 12 格内最近的生物 + 附加「渊海」+ 记状态(left=3)
              →  schedule 1s
wave  →  逐玩家 → wave_go
              ① 算本波伤害 = 当前魔力 ×0.15(算进 manacore:out r.damage)
              ② 每个"源"各调一次 hit_area, 对周围 3 格结算
              ③ 被打到的 → 变成下一波的源
              ④ left-1: 还 >0 就再花 110 魔力、1 秒后下一波; 否则 finish
finish → 把标记和状态全清掉
```

**三个关键手法（以后做类似技能可以照抄）：**

| 手法 | 为什么 |
| --- | --- |
| 每波的"源"用带**自己 UUID** 的标签 `zx.de_<uuid>` | 多个人同时放不会互相串（和流光同一套路） |
| 两层临时标签：`zx.de_hit`(单个源的受害者) / `zx.de_all`(本波累计) | 只用一个的话，第二个源会把第一个源打过的**再打一遍** |
| 伤害每波只算一次，放进 `manacore:out r.damage` | 各源的数值一样，省得把数值一路当宏参数传下去 |

**表现（海味）：**

| 时机 | 音效 | 粒子 |
| --- | --- | --- |
| 附加「渊海」（起链）| `block.conduit.activate`（潮涌核心激活）| 目标处：`nautilus` 鹦鹉螺 + `bubble` 气泡 |
| 起链同时 | — | 自己脚下半径 12 的**蓝色光环**（`sfx_ring12`）|
| 每一波开始 | `entity.guardian.ambient`（守卫者低鸣，**只在第一个源放一次**）| 每个源：`bubble` + `bubble_column_up` 气泡柱 |
| 每个"源"的 3 格范围 | — | **半径 3 的蓝色光球**（`sfx_ring3`）|
| 每次命中 | 无（一圈十几个目标会叠成噪音）| 每个受害者：`splash` 水花 + `bubble_pop` |
| 连锁结束 | `block.conduit.deactivate`（潮涌核心关闭）| — |

**分工原则：范围 = 蓝色 `dust`，其余 = 海味（鹦鹉螺 / 气泡 / 水花）。**
这样一眼就能分清"这片是要吃伤害的范围"和"这一圈被海吞了"。
**范围相关的表现全在 `sfx_ring3` / `sfx_ring12` 两个文件里** ——
想让范围也换上别的粒子，只改这两个文件就行，不用动技能逻辑。

**粒子统一用 `minecraft:dust`** —— 它是原版**唯一能带颜色**的粒子。
但它的参数必须写成 **SNBT**（大括号那种），**不是**把颜色直接跟在名字后面：

```mcfunction
particle dust{color:[0.0,0.0,1.0],scale:1.0} ~ ~ ~ 4 2 4 0.01 800 force
        └──────── 参数写成 SNBT ────────┘ └坐标┘ └散布┘ └速度┘└数┘└模式┘
```

> ⚠️ **写错了不在加载时报错，而是在运行时报错** —— 而函数里一条命令报错，
> 会把**它后面所有命令全部截断**。表现就是"音效响了、粒子一个都不出"，极难查。
> 这个坑踩过一次：当时写成 `particle minecraft:dust 0.3 0.65 1.0 1.4 ~ ~ ~ ...`
> （把颜色当成普通参数跟在名字后面），结果整条 `seed` 在那一行之后全被截断，
> 只剩音效生效。
> **速判方法：粒子名字后面不能直接跟数字。**

- `scale` 是**粒子大小**：1.0 偏小，场景里用 1.4~1.8 才看得清
- `color` 是 **0~1 的三元组**：深一点 `[0.15,0.45,1.0]`，淡一点 `[0.55,0.85,1.0]`
- 结尾建议写 `force`：玩家把"粒子效果"调到最少时也能看见
- 觉得糊/掉帧：把 `fx_go` 的 `limit=8` 调小，或把 `sfx_ring3` 里的数量压一压

**画"圆"的手法**（以后做任何范围技能都能用）：粒子命令只能在一个盒子里随机撒，
直接撒出来是方的。要画圆就**绕一圈取样**：

```mcfunction
execute rotated 0   0 positioned ^ ^ ^3 run particle minecraft:nautilus ~ ~1 ~ 0 0 0 0.02 2 normal
execute rotated 30  0 positioned ^ ^ ^3 run particle minecraft:nautilus ~ ~1 ~ 0 0 0 0.02 2 normal
...                                                                          # 每 30° 一个点
```

`rotated` 改朝向 → `positioned ^ ^ ^3` 就沿那个朝向走 3 格 → 正好落在圆周上。
12 个点连起来就是个很圆的圈。半径换成 12 就变成 `sfx_ring12` 那个大环。

**让效果"持续"的办法：反复补画。**

原版粒子的寿命是**写死的**（气泡、鹦鹉螺都只有零点几秒），命令改不了它。
所以想让水域看着是持续的，唯一办法就是隔几 tick 补画一次：

```
seed / wave_go  ──schedule 5t / 10t / 15t──►  fx ──► fx_self ──► fx_go
                                                    └ 给当前每个"源"再画一次 sfx_ring3
```

这样正好把"两波之间那一秒"填满，整条连锁看着一直是水在涌。
**顺带一个漂亮的副作用**：补画时标记已经传给"下一波要扩散到的那批"了，
所以看到的是**水在往前蔓延**，而不是原地闪。

补画时用 `limit=8` 限制只画前 8 个源 —— 一圈扩散到几十个时，全画会瞬间上千条命令。

> 音效/粒子 id 全部是**核对过的**：粒子名从客户端 jar 的粒子注册表里挖出来，
> 音效名从 `assets/minecraft/sounds.json` 里查。别凭印象写 id ——
> 写错一个（比如猜的 `block.conduit.attack`，其实不存在）整个函数会加载失败。

**波数**：`seed` 里写死 `left:3` = 初次 1 波 + 重复 2 波（正好扣 2 次 110 魔力）。
想改成"重复 N 次"就把它改成 `N+1`。

> ⚠️ **「渊海」现在只是一个标记**（`zx.status.yuanhai` 实体标签），没有持续时间、
> 也不会自动消失。等五个通用标签（渊海/流火/夜火/白昼梦/噬心）那套系统做好，
> 这里要换成统一的"施加/查询/倒计时"接口。存的位置已经预留好了。

## 踩过的坑（别重犯）

- **进度奖励函数第一行必须 `advancement revoke @s only <自己那条进度>`**，
  否则进度只会触发一次，第二次右键毫无反应。
- **做新武器时三处名字必须一致**：`give` 里 `zx` 的武器标记 / 进度文件名与条件 /
   进度奖励指向的那个 `cast`。任一处不一致的表现都是"右键静默无反应"，不报错。
- **含 `$(变量)` 的行必须以 `$` 开头；不含变量的行绝对不能加 `$`**
  （后者会报 `Macro without variables`，整个函数作废）。
- **宏变量在函数"被调用那一刻"就固定了**：在函数体里才写进节点的字段，这一层引用不到，
  必须再调一层带宏的函数。同一件事被坑过两次。
- **宏参数必须是复合标签**，不能传单个数字（传 `r.damage` 会直接报错）。
- **右键消耗型道具，退还物品必须延后 1 tick**：消耗流程收尾会把主手设成空，
  同 tick 放回去的会被覆盖。
- **`storage 存储ID 路径` 中间是空格，不是点**（`manacore:players "xxx".cooldowns`）。
- **选择器的 `distance` 下界用 `0.1`**：自己到自己的距离是 0，不排除就会打到/选中自己。
- **别把盔甲架塞到 y < -64**：虚空伤害无视 `Invulnerable`，会被销毁然后反复重造。
- **伤害默认 `minecraft:player_attack`**（吃护甲）；想穿甲自己传 `minecraft:magic`。
- **改了范围要两处一起改**：技能里的"锁定判定"和 `effect` 里的"打伤害选择器"。
- **武器忘了写 `skill` 字段 → 面板上这把刀永远显示 0。** 右键照样能放技能，
  不报错、不闪红，纯静默 —— 最难发现的一类。
- **进度条件里别写死 `"items"`。** `advancement` 的 `item` 条件里如果加了
  `"items": "minecraft:paper"` 这种限定，**换底材之后进度就永远匹配不上**，
  表现是"右键把道具消耗掉了，但没人把它还回来"（观测镜换追溯指针时就中招了）。
  只靠 `custom_data` 认物品就够了，让它和底材无关。
- **一件武器的消耗数值有三处，必须一起改**：
  `cast` 里 `api/skill/check` 的 `mana:`、`cast` 里 `api/mana/consume` 的 `value:`、
  以及 `give` 描述里的"魔力 X"。只改一处会出现"检查通过、扣不动"——
  表现就是**右键毫无反应**（检查写 10、扣写 350 时踩过）。
  → 所以**扣魔力失败那条路上一定要有 `tellraw` 提示**，别让它静默失败。
- **别改存档 `datapacks` 里那一份。** `部署到存档.bat` 用的是 `robocopy /MIR`
  （镜像），会把 `D:\数据包` 的内容**完全覆盖**过去 —— 你改在存档里的话，
  下次部署就被冲掉了。要改就改 `D:\数据包` 这边。
- **用"先判 A 再判非 A"模拟 if/else 时，小心第一个分支改掉判断依据。**
  manacore 的 `internal/mana/consume` 就踩过：它先 `if #cur >= #need → 扣款`，
  而扣款会把 `#cur` 减小，于是下一行 `if #cur < #need → 报不够` **必然成立**，
  把结果覆盖成"失败"。现象是**魔力明明扣了却报告不足**，
  而且只在"魔力不到消耗的两倍"时出现（很难复现的那种）。
  正确写法：先算出一个开关（`#ok`），两个分支都只读开关。
- **`manacore:in arg` 是"共享输入口"，不是存档。** 它的生命周期是
  "调用前填 → 函数读走"，中间谁都可以覆盖它。观测镜每刻查术阵数量都会用它，
  所以别把要长期保存的东西塞在里面 —— 要存就用 `zx:data`。

## 每次改动后跑一遍的检查

1. `/reload`，看日志有没有 `Failed to load function`
2. 函数引用、标签引用、进度奖励与撤销、宏前缀 —— 这些都能静态查出来
3. `/function sweetdream:debug/num_probe` 可以看宏渲染出来的数字长什么样

## 风行模型动画运行时

**两套动画、两条独立通道**，都写在物品的 `minecraft:custom_model_data` 上，
由资源包 `assets/naturewind/items/staff.json` 里的两层 `range_dispatch` 分别读取。

| | 待机（枝冠呼吸） | 释放（技能动画） |
|---|---|---|
| 分量 | `floats[0]` | `floats[1]` |
| 节拍 | 每 3 tick 一个相位，16 相位循环 2.4 秒 | 每 tick 一帧，26 帧 = 1.3 秒 |
| 驱动 | `naturewind/step` | `naturewind/cast_tick` |
| 写入口 | `item_modifier naturewind:animation_frame` | `item_modifier naturewind:cast_frame` |
| 何时跑 | 一直 | 只在施法之后 |

- 场上没人拿风行时待机不推进也不改物品（`tick.mcfunction` 开头那句 `return 0`）。
- **释放动画那一行必须放在那句 `return 0` 之前** —— 施法到一半把杖丢掉的玩家，
  仍然要靠 `cast_tick` 把计数走完、把 `nw.casting` 摘掉。
- `floats[1]` 缺失或 ≥26 → 走待机那套；0..25 → `cast_00..cast_25`。
  **threshold 26 也是待机**，所以"归位"只需要一个正常数值，不用表达负值。
- `step` 里还有一道兜底：所有 `unless tag=nw.casting` 的持杖者每 3 tick 被写一次
  `cast_idle`。它修的是"施法途中换武器 → 帧号残留在物品上 → 待机动画永久失效"。
- `crown_0..8` 这 9 份枝冠几何按往返顺序使用，只做整体升降；释放动画是另外
  26 份完整的 `staff_optimized/cast/cast_00..25`（木杆+水晶+树枝合并）。
- 以上全是游戏运行依赖，**不能当建模临时文件删掉**。
- 想整个撤掉这次接入：`python .workbuddy/wind_revert.py`（原件都有备份）。
