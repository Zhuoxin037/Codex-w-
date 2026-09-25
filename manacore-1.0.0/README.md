# ManaCore v1.0.0 —— 魔力 / 技能 / 冷却 / 术阵 前置框架

> 适用版本：**Minecraft Java 版 1.21.5**（数据包版本 `pack_format: 71`）
> 定位：**前置包**。它不提供具体技能，而是提供一套"技能系统需要的底层能力"，
> 你的技能包只要依赖它，就能直接调用现成的魔力、伤害、冷却、术阵计算。

> **目录名规则**：本包目录名带版本号（`manacore-1.0.0`）。命名空间固定为 `manacore`，
> 所以以后升级版本时**只需要替换文件夹**，配置里引用的 `manacore:xxx` 完全不用改。

---

## 目录

1. [它解决了什么问题](#1-它解决了什么问题)
2. [安装与卸载](#2-安装与卸载)
3. [3 分钟上手](#3-3-分钟上手)
4. [完整的一次技能释放（可直接复制）](#4-完整的一次技能释放可直接复制)
5. [数据是怎么存的](#5-数据是怎么存的)
6. [六大核心机制的原理](#6-六大核心机制的原理)
7. [API 手册](#7-api-手册)
8. [事件系统：如何接入你自己的包](#8-事件系统如何接入你自己的包)
9. [调试系统](#9-调试系统)
10. [扩展指南](#10-扩展指南)
11. [已知限制与设计取舍（重要）](#11-已知限制与设计取舍重要)
12. [文件目录结构](#12-文件目录结构)
13. [常见问题 FAQ](#13-常见问题-faq)

---

## 1. 它解决了什么问题

在 Minecraft 数据包里做技能系统，最麻烦的从来不是"效果"，而是这些底层问题：

| 问题 | 原生命令的困难 | ManaCore 的做法 |
| --- | --- | --- |
| 每个玩家独立数据 | 命令拿不到玩家名字，也没有"按玩家存字符串"的地方 | 用 UUID 文本当存储键，`players."<uuid>"` 一人一份 |
| 小数运算 | 计分板只有整数 | 定点数（x1000）在计分板里算，存储里仍是小数 |
| 冷却 | 要每 tick 遍历所有玩家所有技能 | 存"结束时刻"，读取时才做一次减法，零遍历 |
| 玩家掉线残留 | 没有登出事件 | 每秒用 UUID 反查实体，掉线就回收槽位、清术阵 |
| 参数化 | 一个效果写一个函数 | 宏函数 + 统一参数节点，一个函数服务所有技能 |

**一句话**：你把"技能是什么"交给自己的包，把"数据怎么存、怎么算、怎么清"交给 ManaCore。

---

## 2. 安装与卸载

### 安装（务必确认层级）

`pack.mcmeta` 必须**直接**位于你放进 `datapacks` 的那个文件夹里：

```
saves/<世界名>/datapacks/manacore-1.0.0/pack.mcmeta   ← 正确
saves/<世界名>/datapacks/manacore-1.0.0/data/manacore/function/core/load.mcfunction
```

常见错误（会导致**整个包不被识别**，`/function` 里一个都补全不出来）：

```
datapacks/数据包/manacore-1.0.0/pack.mcmeta        ← 多套了一层
datapacks/manacore-1.0.0/manacore-1.0.0/pack.mcmeta ← 多套了一层
datapacks/manacore-1.0.0/data/... (没有 pack.mcmeta) ← 少了元数据文件
```

1. 把整个 `manacore-1.0.0` 文件夹放进：
   - 单人：`.minecraft/saves/<世界名>/datapacks/`
   - 服务器：`<服务端目录>/world/datapacks/`
2. 进入游戏执行 `/reload`
3. `/datapack list` —— 必须在列表里看到 `manacore-1.0.0` 且是 `enabled`
   - 如果它出现在另一个分组（例如 "disabled" 或提示 "incompatible"），执行
     `/datapack enable "file/manacore-1.0.0"` 手动启用
4. `/function manacore:version` —— 应该打印出版本号与常量
   - 补全不出来 → 包没加载（回到第 3 步）
   - 能调用但数字是空的 → `core/load` 没跑完，把 `/reload` 后的日志报错发出来
5. `/function manacore:debug/validate` —— 看到 "警告数: 0" 表示框架正常

> 首次进入世界的玩家会在 1 秒内自动完成注册（写入存储、分配槽位）。

### 30 秒定位：包到底有没有被加载

如果 `manacore` 完全没反应，用附带的极小自检包 `probe-pack` 分辨原因：

1. 把 `probe-pack` 文件夹同样放进 `datapacks/`，`/reload`
2. 聊天栏应立刻出现绿色提示 `[probe] 自检包已加载成功!`
3. 执行 `/function probe:hello`

- **能正常执行** → 说明你的放置方式没问题，那问题在 manacore 内部，把
  `/reload` 后日志里 `Failed to load ...` 的行发出来即可定位到具体文件。
- **也没反应** → 说明是放置层级或版本兼容问题：
  检查 `pack.mcmeta` 是否在 `datapacks/<文件夹>/` 的第一层，
  以及游戏版本是否在 1.21 ~ 1.21.8 之间（本包声明的 `supported_formats` 是 48~81）。

### 卸载

删除文件夹后 `/reload`。玩家的数据仍留在世界存档的命令存储里，
如果确定不再需要，可以在删除前执行 `/function manacore:debug/reset_all` 清空。

---

## 3. 3 分钟上手

所有接口都是同一个调用套路——**写输入 → 调函数 → 读输出**：

```mcfunction
# 1) 写输入到 manacore:in arg（arg 是固定的输入节点名）
data modify storage manacore:in arg set value {uuid:"<玩家UUID>", value:50.0}

# 2) 调用接口
function manacore:api/mana/add

# 3) 需要结果时读 manacore:out r（r 是固定的结果节点名）
execute store result score #x obj run data get storage manacore:out r.value
```

常见的一次性测试（以玩家身份执行）：

```mcfunction
/function manacore:debug/on          # 打开 HUD，能在屏幕下方看到魔力/术阵/UUID
/function manacore:debug/selftest    # 跑 4 个内置用例，自动还原数据
```

**怎么拿到玩家 UUID？**
前置包在事件里会把它放进 `manacore:ctx.uuid`，例如：

```mcfunction
# 在 #manacore:event/player_join 指向的函数里
data modify storage mypack:buf.uuid set from storage manacore:ctx uuid
```

---

## 4. 完整的一次技能释放（可直接复制）

假设技能 id 是 `mypack:fireball`，由"按下技能键"的检测函数触发。

```mcfunction
# mypack:skills/fireball
# 执行者 = 施法者本人

# ① 先把施法者的 UUID 查出来（公开接口，结果写在 manacore:out r.uuid）
function manacore:api/player/self_uuid

# ② 组装技能参数
data modify storage manacore:in arg set value {skill:"mypack:fireball", mana:20.0, cooldown_seconds:3.0, skill_multiplier:2.0, independent_multiplier:1.0, custom_damage:6.0, target:"@e[tag=mana_target,distance=..8,limit=1]"}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid

# ③ 交给框架：查冷却 -> 扣蓝 -> 记冷却 -> 算伤害 -> 打伤害 -> 抛事件
function manacore:api/skill/cast

# ④ 根据结果做表现
execute if data storage manacore:out r {success:1b} run function mypack:skills/fireball_vfx
execute if data storage manacore:out r {reason:"cooldown"} run tellraw @s {"text":"技能冷却中","color":"red"}
execute if data storage manacore:out r {reason:"mana"} run tellraw @s {"text":"魔力不足","color":"red"}
```

`skill/cast` 内部严格按这个顺序执行，失败时**不会**扣魔力、**不会**进冷却：

```
冷却检查 ──失败──> 结束（reason=cooldown）
   │通过
   ▼
扣除魔力 ──不足──> 结束（reason=mana，一个字节都没扣）
   │通过
   ▼
开始冷却 → 计算伤害 → 施加伤害 → 抛 #manacore:event/skill_cast → success=1b
```

---

## 5. 数据是怎么存的

### 5.1 存储分区总览

所有数据都在命令存储里（世界存档的一部分，重启不丢）：

| 存储 | 内容 |
| --- | --- |
| `manacore:config` | 配置与"新玩家默认模板" |
| `manacore:players` | **玩家数据主体，键 = UUID 文本** |
| `manacore:index` | 槽位号 → UUID 的索引（用于遍历/离线检测） |
| `manacore:free_slots` | 槽位回收池 |
| `manacore:in` | **公开输入**（读 `arg` 节点，见下方寻址规则） |
| `manacore:out` | **公开输出**（写 `r` 节点） |
| `manacore:ctx` | 事件上下文（uuid / id / skill / reason / slot） |
| `manacore:ctrl` | 遍历的附加参数（`arg`）；遍历模式用计分板 `#mode` 表示 |

> **NBT 寻址规则（很重要）**
> Minecraft 里"存储名"和"路径"是**两个用空格分开的参数**，不能写成 `manacore:work.a`。
> 正确写法：`data modify storage manacore:work a set value {...}`（存储 = `manacore:work`，路径 = `a`）。
> 写成 `manacore:work.a` 会被整体当成一个存储名，命令直接在**加载期**报错、整个函数失效。
> 本框架统一约定：
>
> | 访问对象 | 写法 |
> | --- | --- |
> | 公开输入 | `storage manacore:in arg...` |
> | 公开输出 | `storage manacore:out r...` |
> | 玩家数据 | `storage manacore:players "<uuid>"...` |
> | 槽位索引 | `storage manacore:index "<槽位>"...` |
> | 宏参数节点 | `with storage manacore:work a` |
| `manacore:work` `manacore:macro` | 内部宏参数节点与临时数据 |

### 5.2 玩家记录长什么样

`/data get storage manacore:players "<uuid>"`：

```snbt
{
  uuid: "069a79f4-44e9-4726-a5be-fca90e38aaf5",   // 键与值一致, 方便反查
  slot: 1,                                        // 槽位号(1..#max_slots)
  u0: 110542324, u1: 1156278118, u2: -1514206078, u3: -942000459,  // UUID 的 4 个整数
  session: 1b,                                    // 是否在线(注册状态)
  debug: 0b,                                      // 是否开启调试 HUD
  stats: {
    current_mana: 100.0,            // 当前魔力
    max_mana: 100.0,                // 最大魔力
    base_attack: 5.0,               // 基础攻击力
    max_health: 20.0,               // 最大生命值
    custom_damage: 0.0,             // 技能固定伤害
    skill_multiplier: 1.0,          // 技能倍率
    independent_multiplier: 1.0,    // 独立乘区
    cooldown: 0.0,                  // 冷却(秒, 技能表用)
    mana_regen: 1.0,                // 每秒基础恢复
    mana_regen_multiplier: 1.0,     // 恢复倍率
    cooldown_reduction: 0.0,        // 冷却缩减(0..1)
    formation_limit: 3              // 术阵数量上限(不是写死的 3!)
  },
  flags: { no_regen: 0b, regen_ban_end: 0 },
  cooldowns: {                      // 键 = 技能 id, 支持同时多技能冷却
    "mypack:fireball": { end: 1200, total: 60, start: 1140 }
  },
  regen_mods: [ {}, {}, ... ],      // 8 个恢复修正槽位(空槽是 {})
  formations: [ {}, {}, ... ]       // 8 个术阵槽位(空槽是 {})
}
```

### 5.3 术阵条目的结构

```snbt
{
  id: "mypack:fire_array",   // 唯一标识
  type: "fire",              // 自定义类型
  owner: "069a79f4-...",     // 所属玩家 UUID
  data: { radius: 4.0 },     // 自由载荷
  start: 1140,               // 创建时刻
  end: 1400                  // 到期时刻(没有该字段 = 永久术阵)
}
```

---

## 6. 六大核心机制的原理

### 6.1 UUID 是怎么"造"出来的（这是整个框架的地基）

命令**无法**把玩家的 UUID 变成字符串，也**无法**读取玩家名字。所以框架自己转换：

```
data get entity @s UUID          ->  [I;a,b,c,d]      4 个 32 位整数
每个整数 >> 28/24/.../0 & 15      ->  8 个半字节
半字节查表(0-9a-f)                ->  32 个十六进制字符
按 8-4-4-4-12 切片并插入 "-"      ->  "069a79f4-44e9-4726-a5be-fca90e38aaf5"
```

对应文件：`internal/uuid/collect` → `internal/uuid/build` → `internal/uuid/part` → `internal/uuid/append`。

- 只在**玩家上线**时算一次（约 700 条命令，1 秒内完成），结果缓存在 `players` 的键和 `index` 里。
- 负数不需要特殊处理：`>>` 之后 `& 15` 取到的仍是正确的补码半字节。

### 6.2 为什么需要"槽位（slot）"

UUID 是任意字符串，**无法枚举**。而"每秒检查谁掉线""全服查某个术阵"都要求能遍历所有玩家，
于是框架额外维护：

```
计分板 manacore.slot           :  该玩家的槽位号(按玩家名持久化)
storage manacore:index "<槽位>" :  { uuid, u0..u3, slot }   ← 反向索引
storage manacore:free_slots list:  回收池(玩家离线后槽位还回来)
```

遍历就是 `#next_slot` 从 1 数到最后，配合 `internal/index/foreach`（递归宏）逐个处理。

遍历要做哪一类事情，由一个计分板开关决定（避免依赖存储里的字符串比较）：

| `#mode`（objective: `manacore.meta`） | 含义 |
| --- | --- |
| 1 | `sweep`：离线检测与清理（每秒） |
| 2 | `reset_session`：把所有人的会话标记归零（load 时） |
| 3 | `formation_remove_all`：全服删除指定 id 的术阵 |
| 4 | `formation_find`：全服查找指定 id 的术阵归属 |
| 5 | `dump`：打印所有玩家数据 |
| 6 | `validate`：数据自检 |
| 7 | `reset_all`：清空所有玩家数据 |
| 8 | `export_all`：导出所有玩家数据 |

需要附加参数时放在 `storage manacore:ctrl arg`（字符串）。

### 6.3 会话检测：怎么发现玩家掉线

传统做法用 `tag` 标记"已登录"，但玩家掉线时无法操作其实体，标签会永久残留，导致**重新上线不再触发登录逻辑**。
本框架改用**数据里的 `session` 标记**：

```
每秒:
  对每个在线玩家 session/refresh
      ├─ 没有槽位分        -> 首次注册(join)
      └─ 有槽位分          -> 用 @s[nbt={UUID:[I;u0,u1,u2,u3]}] 校验身份
                              · 身份不符(槽位被别人用了) -> 重新注册
                              · 身份相符且 session=0b    -> 走"重新上线"流程

  遍历所有索引条目 sweep
      └─ 用 @a[nbt={UUID:[I;...]}] 反查实体
         不存在 => 已离线 -> 释放槽位、清术阵、抛 player_leave 事件
```

**这就是"玩家退出/异常掉线也尽量不留残留"的实现**：掉线一秒内，术阵被清空、
槽位被回收、索引被删除；玩家数据（属性/魔力/冷却）则保留，重连后接着用。
服务器崩溃同理——重启后 load 会把所有 `session` 归零，1 秒内自动重建。

### 6.4 宏函数与"参数节点"约定

Minecraft 的宏函数（`$` 开头的行）用 `$(字段名)` 做文本替换，参数来自一个**复合标签**：

```mcfunction
function manacore:internal/stats/get with storage manacore:work a
#                                        ^ 来源存储        ^ 来源路径
```

框架统一约定：

- **`manacore:work.a`** = 当前宏参数节点（大多数接口用）
- **`manacore:work.entry`** = 展开式循环用的参数节点（循环会把 `.i` 覆盖，用独立节点避免互相干扰）

这也是"用宏函数调用"需求的落地方式：`$(key)`、`$(uuid)`、`$(skill)`、`$(i)` 都是运行时变量，
所以同一个函数可以服务无限多的技能 id、属性名。

### 6.5 小数怎么算（定点数）

计分板只有 32 位整数，所以内部把小数变整数再运算。这里有**两档缩放**：

```
基础量 (攻击力 / 魔力 / 固定伤害 ...) : x1000, 保留 3 位小数
  读取:  execute store result score #a obj run data get storage ... 1000
  写回:  execute store result storage ... double 0.001 run scoreboard players get #a obj

倍率类 (技能倍率 / 独立乘区 / 恢复倍率 ...) : x100, 保留 2 位小数
  读取:  execute store result score #b obj run data get storage ... 100
  运算:  #a *= #b   然后   #a /= #100
```

**为什么要分两档。** 计分板上限只有 21.4 亿。两个 x1000 的数相乘，中间量会到
x1000000，于是"原值 × 倍率"超过约 **2147** 就溢出成负数，紧接着被
`if ... matches ..0 -> 0` 夹成 0——现象就是伤害数值一大就突然变成 `0.0`。
倍率降成 x100 后中间量只有 x100000，可承受范围提升到约 **21474**。

存储里的值**仍然是普通小数**（比如 `current_mana: 100.0`），只有中间计算是整数。
想再扩大范围可以把倍率改成 x10（上限约 21 万，代价是倍率只剩 1 位小数），
具体改动点写在 `internal/damage/calc` 顶部的注释里。

### 6.6 为什么列表都是"固定槽位"

Minecraft **无法遍历任意键名的复合标签**（例如无法枚举某个玩家的所有技能冷却）。
因此所有可堆叠列表都用固定长度数组 + 展开式循环：

```
formations : 8 个槽位    regen_mods : 8 个槽位
空槽 = {}     判断是否占用 = 看它有没有 id / value 字段
```

反过来，`cooldowns` 用**任意键名**（技能 id），代价是不能遍历，于是采用**惰性清理**：
某技能被查询时如果已到期，就顺手把记录删掉——不需要全服扫描，也不会有性能问题。

---

## 7. API 手册

> 统一约定：所有接口都从 **`manacore:in arg`** 读参数、往 **`manacore:out r`** 写结果。
> `uuid` 一律是 UUID 文本。数值型字段写小数即可（`20` 与 `20.0` 都能接受）。

### 7.0 玩家工具（player）

| 接口 | 入参 | 出参 | 说明 |
| --- | --- | --- | --- |
| `api/player/self_uuid` | — | `out.uuid` | **以玩家身份执行**，取自己的 UUID |
| `api/player/ensure` | （内部用） | — | 保证记录存在，接口内部会自动调用 |
| `api/player/reset` | `{uuid}` | — | 把该玩家重置为默认模板（危险） |

```mcfunction
# 最常用的开场白：拿到"我"的 UUID
/function manacore:api/player/self_uuid
/data get storage manacore:out r.uuid
```

> 前置包不使用玩家名字（命令读不到名字），所有数据都以 UUID 为键，
> 所以任何"针对我自己"的操作都从这一步开始。

### 7.1 属性（stats）

| 接口 | 入参 | 出参 | 说明 |
| --- | --- | --- | --- |
| `api/stats/get` | `{uuid, key}` | `out.value/key/uuid` | 读一项属性 |
| `api/stats/set` | `{uuid, key, value}` | — | 写一项属性（不存在则创建） |
| `api/stats/add` | `{uuid, key, value}` | — | 数值加法（可用负数减） |
| `api/stats/mul` | `{uuid, key, value}` | — | 数值乘法（1.25 = +25%） |
| `api/stats/import` | `{uuid, stats:{...}}` | — | 批量导入，只覆盖给出的字段 |
| `api/stats/export` | `{uuid}` | `out.stats` | 导出整份属性表 |
| `api/stats/export_all` | — | `out.players` | 导出所有玩家数据 |

内置 key：`current_mana` `max_mana` `base_attack` `max_health` `custom_damage`
`skill_multiplier` `independent_multiplier` `cooldown` `mana_regen`
`mana_regen_multiplier` `cooldown_reduction` `formation_limit`。
你也可以 `set` 任意自定义 key（例如 `crit_rate`），框架不会阻拦。

```mcfunction
data modify storage manacore:in arg set value {uuid:"<UUID>", key:"max_mana", value:250.0}
function manacore:api/stats/set
```

### 7.2 魔力（mana）

| 接口 | 入参 | 出参 | 说明 |
| --- | --- | --- | --- |
| `api/mana/get` | `{uuid}` | `out.value`(当前) `out.max` | 读魔力 |
| `api/mana/set` | `{uuid, value}` | — | 直接设置（夹取到 0..max） |
| `api/mana/add` | `{uuid, value}` | — | 回复（夹取上限，不受禁疗影响） |
| `api/mana/remove` | `{uuid, value}` | — | 扣除（下限 0） |
| `api/mana/consume` | `{uuid, value}` | `out.success/reason` | **够才扣**，技能用这个 |
| `api/mana/percent` | `{uuid}` | `out.value` | 当前魔力百分比 0..1 |
| `api/mana/max/get` | `{uuid}` | `out.value` | 读上限 |
| `api/mana/max/set` | `{uuid, value}` | — | 设置上限 |
| `api/mana/max/add` | `{uuid, value}` | — | 增加上限 |
| `api/mana/max/remove` | `{uuid, value}` | — | 削减上限（会夹取当前值） |

### 7.3 魔力恢复（mana/regen）

恢复公式：**每秒恢复 = (基础 + 各来源修正之和) × 恢复倍率**，再经禁疗判定。

| 接口 | 入参 | 说明 |
| --- | --- | --- |
| `api/mana/regen/get` | `{uuid}` | 出参 `out.value`(基础) `out.multiplier` `out.bonus`(修正合计) |
| `api/mana/regen/set` | `{uuid, value}` | 设置基础每秒恢复（新玩家默认 1.0） |
| `api/mana/regen/multiplier/set` | `{uuid, value}` | 设置倍率 |
| `api/mana/regen/modifier/add` | `{uuid, id, type, value, duration\|duration_seconds}` | 加一条修正（装备/被动/临时/特殊） |
| `api/mana/regen/modifier/remove` | `{uuid, id}` | 按 id 移除修正 |
| `api/mana/regen/modifier/clear` | `{uuid}` | 清空全部修正 |
| `api/mana/regen/ban` | `{uuid, ticks\|seconds}` | 禁止恢复（<=0 或缺省 = 永久） |
| `api/mana/regen/unban` | `{uuid}` | 解除禁止 |
| `api/mana/regen/force` | `{uuid, value}` | **强制恢复**：无视倍率与禁疗 |

```mcfunction
# 装备：+0.8 每秒恢复
data modify storage manacore:in arg set value {uuid:"<UUID>", id:"mypack:ring", type:"equipment", value:0.8}
function manacore:api/mana/regen/modifier/add

# 临时：+3 每秒恢复，持续 30 秒
data modify storage manacore:in arg set value {uuid:"<UUID>", id:"mypack:potion", type:"temporary", value:3.0, duration_seconds:30}
function manacore:api/mana/regen/modifier/add

# 战斗禁疗 5 秒
data modify storage manacore:in arg set value {uuid:"<UUID>", seconds:5.0}
function manacore:api/mana/regen/ban
```

### 7.4 冷却（cooldown）

| 接口 | 入参 | 出参 | 说明 |
| --- | --- | --- | --- |
| `api/cooldown/start` | `{uuid, skill, cooldown\|cooldown_seconds, reduce}` | `out.remaining` | 进入冷却（tick 优先，秒自动 x20） |
| `api/cooldown/check` | `{uuid, skill}` | `out.ready/remaining` | 是否冷却完毕 |
| `api/cooldown/get` | `{uuid, skill}` | `out.remaining` | 剩余 tick |
| `api/cooldown/reduce` | `{uuid, skill, ticks\|seconds}` | — | 减少剩余冷却 |
| `api/cooldown/increase` | `{uuid, skill, ticks\|seconds}` | — | 增加剩余冷却 |
| `api/cooldown/reset` | `{uuid, skill}` | — | 重置单个技能冷却 |
| `api/cooldown/reset_all` | `{uuid}` | — | 清空全部冷却 |
| `api/cooldown/list` | `{uuid}` | `out.cooldowns` | 导出冷却表 |
| `api/cooldown/reduction_set` | `{uuid, value}` | — | 设置冷却缩减（0..1） |
| `api/cooldown/reduction_get` | `{uuid}` | `out.value` | 读取冷却缩减 |

需求对应关系：

- 秒级 / tick 级冷却 → `cooldown_seconds` 与 `cooldown` 两个字段
- 多个技能同时冷却 → `cooldowns` 以技能 id 为键，互不干扰
- 不同玩家独立冷却 → 数据存在各人自己的记录里
- 冷却减少 / 增加 / 重置 → `reduce` / `increase` / `reset`
- 冷却期间禁止释放 → `skill/cast` 第一步就拦截
- 释放成功后才开始冷却 → `skill/cast` 在扣蓝成功之后才 `start`

### 7.5 伤害（damage）

**公式**：`(基础攻击力 × 技能倍率 + 技能固定伤害 + 最大生命 × 生命系数) × 独立乘区`

| 接口 | 入参 | 出参 | 说明 |
| --- | --- | --- | --- |
| `api/damage/calc` | `{uuid, base_attack(-1=面板), skill_multiplier, independent_multiplier, custom_damage, health_ratio}` | `out.damage` | 只算不打 |
| `api/damage/apply` | `{uuid, target, damage, type, from}` | `out.applied` | 只打不算 |
| `api/damage/deal` | 上面两者合并 | `out.damage` | 算+打 |

```mcfunction
data modify storage manacore:in arg set value {uuid:"<UUID>", base_attack:-1.0, skill_multiplier:2.0, independent_multiplier:1.5, custom_damage:10.0}
function manacore:api/damage/calc
/data get storage manacore:out r.damage     # => 例如 45.0
```

- 想改公式？只需要改 `internal/damage/calc.mcfunction` 中间那几行（注释已标出每一步）。
- 伤害类型默认 `minecraft:magic`（可穿甲）；换 `minecraft:generic` 走正常护甲结算。
- `from` 省略时框架会自动用 UUID 反推出攻击者选择器，所以击杀归属/击退方向仍然正确。

### 7.6 术阵（formation）

| 接口 | 入参 | 出参 | 说明 |
| --- | --- | --- | --- |
| `api/formation/create` | `{uuid, id, type, duration\|duration_seconds, data}` | `out.success/reason/count/limit/index` | 创建（受上限限制） |
| `api/formation/remove` | `{uuid, id}` | `out.removed` | 删除 |
| `api/formation/force_remove` | `{uuid, id}` | `out.removed` | 强制移除（无视状态） |
| `api/formation/force_remove_all` | `{id}` | — | 全服移除该 id |
| `api/formation/count` | `{uuid}` | `out.count/limit` | 数量统计 |
| `api/formation/check` | `{uuid}` | `out.can_create/count/limit` | 是否还能创建 |
| `api/formation/list` | `{uuid}` | `out.formations` | 导出 8 槽数组 |
| `api/formation/get` | `{uuid, id}` | `out.found/index/formation` | 查询详情 |
| `api/formation/refresh` | `{uuid, id, duration\|duration_seconds}` | `out.found/success` | 刷新持续时间（<=0 = 永久的） |
| `api/formation/clear` | `{uuid}` | — | 清空该玩家全部术阵 |
| `api/formation/limit/get` | `{uuid}` | `out.value` | 读上限 |
| `api/formation/limit/set` | `{uuid, value}` | — | 改上限（道具接入点） |
| `api/formation/find` | `{id}` | `out.found/uuid/index/formation` | 全服查归属 |

```mcfunction
# 创建一个持续 15 秒的火阵
data modify storage manacore:in arg set value {uuid:"<UUID>", id:"mypack:fire_array", type:"fire", duration_seconds:15, data:{radius:4.0}}
function manacore:api/formation/create

# 数量够不够?
data modify storage manacore:in arg set value {uuid:"<UUID>"}
function manacore:api/formation/count
/data get storage manacore:out r.count

# 道具: 把上限从 3 提到 5
data modify storage manacore:in arg set value {uuid:"<UUID>", value:5}
function manacore:api/formation/limit/set
```

需求对应关系：

- 默认每人最多 3 个 → `config.defaults.stats.formation_limit = 3`
- **不写死 3** → 上限存在玩家属性里，唯一入口 `api/formation/limit/set`
- 创建 / 删除 / 检查 / 持续时间 / 归属 / 强制删除 → 上表逐项对应
- 玩家退出不留残留 → 离线检测里调用 `clear_all`，每个术阵都会抛移除事件

### 7.7 统一技能（skill）

| 接口 | 说明 |
| --- | --- |
| `api/skill/cast` | 全流程：冷却→扣蓝→记冷却→算伤害→打伤害→事件 |
| `api/skill/check` | **只读**检查能否释放（不扣蓝、不记冷却） |

字段完整列表见第 4 节与 `api/skill/cast.mcfunction` 顶部注释。

---

## 8. 事件系统：如何接入你自己的包

前置包本身**不生成任何实体、粒子、音效**。所有"表现"都通过函数标签回调给你。

### 可用事件

| 事件标签 | 触发时机 | 上下文（`manacore:ctx`） |
| --- | --- | --- |
| `#manacore:event/load` | 数据包加载/重载后 | — |
| `#manacore:event/second` | 每秒（所有玩家逻辑之后） | — |
| `#manacore:event/player_join` | 玩家完成注册 | `uuid` `slot` `reason="join"` |
| `#manacore:event/player_leave` | 检测到玩家离线并完成清理 | `uuid` `reason="leave"` |
| `#manacore:event/mana_regen` | 每次自动恢复结算前 | `uuid`，可读写计分板 `#regen` |
| `#manacore:event/cooldown_start` | 技能进入冷却 | `uuid` `skill` |
| `#manacore:event/skill_cast` | 技能释放成功 | `uuid` `skill` |
| `#manacore:event/damage_calc` | 伤害算完（`out.damage` 已就绪） | `uuid` |
| `#manacore:event/formation_create` | 术阵创建成功 | `uuid` `id` |
| `#manacore:event/formation_remove` | 术阵被移除 | `uuid` `id` `reason` |

`formation_remove` 的 `reason` 取值：`expire`(自然到期) / `remove`(主动删除) /
`clear`(清空) / `leave`(玩家离线)。

### 接入方式（推荐）

在你自己的数据包里建同路径的标签文件，Minecraft 会把多个包的标签**合并**：

```json
// 你的包: data/manacore/tags/function/event/formation_create.json
{
  "values": [
    "mypack:on_formation_create"
  ]
}
```

```mcfunction
# mypack:on_formation_create
# 生成一个显示用的 marker, 并把它和术阵 id 绑定
summon marker ~ ~ ~ {Tags:["mypack:formation_display"]}
data modify entity @n[type=marker,tag=mypack:formation_display] data.mana_id set from storage manacore:ctx id
```

```mcfunction
# mypack:on_formation_remove —— 清理显示实体
execute as @e[type=marker,tag=mypack:formation_display] run function mypack:formation/destroy
```

> **注意：函数标签不能是空的。**
> Minecraft 里 `values` 为空的标签**会被当成"不存在"**，于是 `function #manacore:event/xxx`
> 这行命令在**解析期**就失败，导致调用它的整个函数加载不出来（`/function` 里都补全不到）。
> 所以本框架给每个事件标签默认挂了一个空操作函数 `manacore:event/noop`。
> 你自己的包如果也要建事件标签，记得同样放一个占位函数，别留空数组。

### 在恢复事件里改数值

```mcfunction
# mypack:on_mana_regen —— 例如"低血量时恢复量翻倍"
# 契约: 读写计分板 #regen (objective: manacore.math), 单位 = 真实值 x1000
execute if score #regen manacore.math matches 1.. run scoreboard players operation #regen manacore.math *= #two manacore.meta
```

### 接入自定义属性

```mcfunction
# 事件里把玩家 UUID 拿出来, 然后随便调用 API
data modify storage mypack:buf.uuid set from storage manacore:ctx uuid
data modify storage manacore:in arg set value {key:"crit_rate", value:0.15}
data modify storage manacore:in arg.uuid set from storage mypack:buf uuid
function manacore:api/stats/set
```

---

## 9. 调试系统

> 除 `debug/dump` 支持指定 UUID 外，以下命令都请**以玩家身份**执行。

| 命令 | 作用 |
| --- | --- |
| `/function manacore:debug/on` | 打开 HUD（每秒刷新魔力 / 术阵 / 槽位 / UUID） |
| `/function manacore:debug/off` | 关闭 HUD |
| `/function manacore:debug/hud` | 立即刷新一次 HUD |
| `/function manacore:debug/dump` | 打印自己的完整原始数据 |
| `/function manacore:debug/dump_all` | 打印所有已登记玩家的数据 |
| `/function manacore:debug/validate` | 数据完整性自检 + 自动清理脏索引 |
| `/function manacore:debug/selftest` | 跑 4 个内置用例（伤害 / 冷却 / 术阵 / 上限），完成后自动还原 |
| `/function manacore:debug/reset_all` | **危险**：清空全部玩家数据 |

看别人的数据：

```mcfunction
data modify storage manacore:in arg set value {uuid:"<UUID>"}
function manacore:debug/dump
```

**排查思路**：

1. 数值不对 → `debug/dump` 看真实 NBT，注意术阵/修正是 8 槽数组、空槽是 `{}`
2. 玩家"数据没生效" → 看 `manacore:index` 里有没有他的槽位；没有说明还没注册完成
3. 掉线残留 → `debug/validate` 会自动清理脏索引并报告
4. 性能 → 本框架每 tick 只有 3 条命令；所有重活都在"每秒"里做

---

## 10. 扩展指南

### 10.1 新增一种属性

不需要改任何框架代码：

```mcfunction
data modify storage manacore:in arg set value {uuid:"<UUID>", key:"spell_power", value:1.0}
function manacore:api/stats/set
```

### 10.2 新增一个技能

```mcfunction
# mypack:skills/ice_lance
function manacore:api/player/self_uuid
data modify storage manacore:in arg set value {skill:"mypack:ice_lance", mana:35.0, cooldown_seconds:8.0, skill_multiplier:3.5, custom_damage:12.0, target:"@e[tag=mana_target,distance=..12,limit=1]"}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/skill/cast
execute if data storage manacore:out r {success:1b} run function mypack:skills/ice_lance_vfx
```

### 10.3 修改伤害公式

只改 `data/manacore/function/internal/damage/calc.mcfunction`。
里面的注释标出了每一项（基础攻击力 / 技能倍率 / 固定伤害 / 生命系数 / 独立乘区），
加一项就在对应的计分板运算处插一行。

### 10.4 扩容固定槽位（术阵 / 恢复修正）

术阵与修正是 8 槽数组，扩容需要同步三处：

1. `core/load.mcfunction` 里默认模板的 `formations` / `regen_mods` 长度
2. 对应的 `*_driver.mcfunction`（展开式循环，照抄一段并把下标 +1）
3. `config.settings.max_formations` / `max_regen_mods`（仅作记录）

### 10.5 扩容玩家槽位

```mcfunction
data modify storage manacore:config settings.max_slots set value 256
/reload
```

遍历用的是 `#next_slot` 而非固定常量，所以不需要改函数。

### 10.6 修改新玩家默认值

```mcfunction
data modify storage manacore:config defaults.stats.max_mana set value 150.0
data modify storage manacore:config defaults.stats.formation_limit set value 4
/reload
```

> 只影响之后注册的新玩家。老玩家请在 `internal/join/existing.mcfunction`
> 里加一条 `execute unless data ...` 补齐，或者直接对他们调用 API。

---

## 11. 已知限制与设计取舍（重要）

这些是 Minecraft 命令本身的限制，不是实现偷懒，使用前请务必了解：

1. **无法遍历任意键名的复合标签。**
   所以 `cooldowns` 采用惰性清理（查询时顺手删掉过期记录），
   术阵/修正采用固定 8 槽数组。你无法"列出某人所有冷却并批量过期"，
   但 `cooldown/reset_all` 可以一键清空。

2. **无法读取玩家名字。**
   因此存储全部按 UUID 索引。调试时用 `debug/dump` 或 HUD 看 UUID，
   再对照 `manacore:index`。

3. **计分板是 32 位整数。**
   基础量定点倍率 1000（单值上限约 214 万），倍率类取 100。
   做乘法时"原值 × 倍率"不要超过约 **21474**，否则中间量会溢出成负数，
   表现为伤害或属性突然变成 0。想再放大就把倍率改成 x10，
   实现见 `internal/damage/calc` 与 `internal/stats/mul_calc` 的注释。

4. **玩家槽位总数有上限**（`settings.max_slots`，默认 64）。
   槽位会在玩家离线后回收，正常不会耗尽；一旦回绕，
   `debug/validate` 会报告，调大配置即可。

5. **注册有最长 1 秒延迟。**
   玩家进服后最多 1 秒完成注册。若你的包在 `player_join` 事件之前就调用 API，
   `api/player/ensure` 会自动补建记录，但槽位要等注册完成才有。

6. **修改 `current_mana` 请走 mana 系列接口。**
   直接用 `stats/set` 写入可能超出 `max_mana`（`debug/validate` 会报警告）。

7. **本包不提供任何视觉表现。**
   实体、粒子、音效都需要你在事件里自己实现——这是刻意的设计，
   让计算层和表现层解耦。

---

## 12. 文件目录结构

```
manacore/
├── pack.mcmeta                      数据包元信息 (pack_format 71 = 1.21.5)
├── README.md                        本文档
└── data/
    ├── minecraft/tags/function/
    │   ├── load.json                -> manacore:core/load
    │   └── tick.json                -> manacore:core/tick
    └── manacore/
        ├── tags/function/event/     10 个事件标签(供你的包追加)
        └── function/
            ├── core/                加载、主循环、每秒循环、玩家注册
            ├── internal/
            │   ├── uuid/            UUID -> 字符串
            │   ├── join/ slot/      注册流程与槽位管理
            │   ├── session/ sweep/  会话检测与离线清理
            │   ├── index/           槽位索引遍历(递归宏)
            │   ├── mana/            魔力、恢复、修正
            │   ├── cooldown/        冷却
            │   ├── damage/          伤害计算与施加
            │   ├── formation/       术阵
            │   ├── skill/           统一技能流程
            │   ├── stats/           属性读写
            │   ├── fmt/             数字格式化
            │   └── debug/           调试内部实现
            ├── lib/num/             通用数值工具
            ├── api/                 公开接口(你只需要看这里)
            ├── debug/               公开调试入口
            └── example/             示例(可安全删除)
```

---

## 13. 常见问题 FAQ

**Q：为什么我的玩家数据是空的？**
A：玩家进服后最多 1 秒完成注册。先 `/function manacore:debug/validate` 看是否已登记。

**Q：为什么 `/function` 补全里看不到某些函数？**
A：补全只列出**解析成功**的函数。如果某个函数里有非法命令（最常见的是把存储名和路径
写成 `manacore:work.a` 这种点号连写），Minecraft 会在 `/reload` 时直接跳过它，
并在日志里打印 `Failed to load function ...`。本框架内部已全部改成
`storage <存储名> <路径>` 的空格写法，你自己写扩展函数时请同样遵守。

**Q：能不能不用 UUID，直接用玩家名字？**
A：命令读不到玩家名字，这是硬限制。UUID 方案是唯一可靠的做法。

**Q：能不能给一个玩家同时挂 20 个临时恢复 buff？**
A：默认 8 个槽位。建议让装备/天赋系统先自己汇总成一条修正，或按第 10.4 节扩容。

**Q：离线玩家的术阵会怎样？**
A：离线检测（每秒）会清空他的术阵并抛 `formation_remove` 事件，
所以你的显示实体也能被正确销毁，不会残留。

**Q：冷却会随着掉线继续走吗？**
A：会。冷却存的是绝对时刻，离线期间自然走完，重连时该好就好了。

**Q：`/reload` 之后数据会乱吗？**
A：不会。load 会把所有会话标记归零，1 秒内全体自动重新注册；
老玩家的数据会通过 `join/existing` 逐项补齐缺失字段。

**Q：`/reload` 后框架整个不动了（魔力不恢复、新人注册不上）？**
A：先确认 load 有没有跑完：`/scoreboard players get #loads manacore.meta`
——正常应该是 1 以上的数字。如果报"没有这个计分项"，说明 load 中途被中断了。
本框架已经把最容易踩的坑处理掉了：`scoreboard objectives add` 在目标已存在时会
**报错并中断整个函数**（也就是第二次 `/reload` 之后所有初始化都会停），
所以这里改用 `scoreboard players set` 隐式创建 dummy 目标。
你自己写扩展函数时，凡是"只该执行一次"或"重复执行会报错"的命令
（`objectives add/remove`、`team add`、`attribute` 等），都要用
`execute unless data <你自己的标记>` 之类的方式保护。

**Q：某个函数在 `/function` 补全里完全看不到，其他函数却正常？**
A：说明**这个文件里的某一行在解析期就失败了**，Minecraft 会丢弃整个文件并在日志里
打印 `Failed to load function ...`。除了命令拼写错误，最常见的原因是
**引用了空的函数标签**（`function #ns:tag`，而该标签 `values: []`）——
空标签会被视为不存在。第二个常见原因是把存储名和路径连写成 `manacore:work.a`。
排错方法：看 `logs/latest.log` 里该函数的那一行报错，它会直接指出哪一行的参数不合法。

**Q：如何看某个技能现在有没有在冷却？**
A：`api/cooldown/check` 或 `api/cooldown/list`；HUD 里也有提示。

---

## 附：一键排错清单

```mcfunction
/datapack list
/reload
/function manacore:debug/on
/function manacore:debug/selftest     # 4 个用例应全部符合预期
/function manacore:debug/validate     # 警告数应为 0
/function manacore:debug/dump         # 对照第 5 节的数据结构
```
