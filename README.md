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
- **⚠️ 踩过的坑：`damage_type` 是"注册表"类内容，只在进世界时加载，`/reload` 不会补上它。**
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

## 新开一个对话怎么接着干

把下面这段直接发给新对话就行：

```
工作目录是 D:\数据包，先读 D:\数据包\README.md 和 D:\数据包\使用教程.md，再动手。
这是两个配套的 Minecraft Java 1.21.5 数据包：manacore-1.0.0（前置框架）和
sweetdream（应用层）。改完记得做静态自检，并用中文详细注释。
```

新对话不会记得我们聊过什么，**文档就是交接内容** —— 所以约定、踩过的坑、
当前状态都写在这两个文件里。要是想到什么该记的事，先补进 `使用教程.md` 再走。
