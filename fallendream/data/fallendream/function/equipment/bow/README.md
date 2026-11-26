# 弓类武器放这里

这个文件夹是**弓 / 弩**类武器的分类位，目前还是空的。

新做一把弓，就在 `bow/<武器名>/` 下建文件，规格和别的装备一样：

```
bow/<名字>/give.mcfunction          给物品 (custom_data 里带 "bow" 这个分类标记)
advancement/equipment/bow/<名字>.json  右键触发 (奖励指向 bow/<名字>/cast)
bow/<名字>/cast.mcfunction          技能本体 (第一行撤销自己的进度)
```

> 注意：`custom_data` 里的 `zx` 数组**按顺序包含**匹配，
> 所以分类标记放在哪一段都行，但 `execute if items` 那些判定要写**整份**内容
> （少写一段会静默匹配不上，踩过一次）。
