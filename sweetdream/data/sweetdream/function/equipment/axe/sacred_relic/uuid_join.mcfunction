# 宏只拼标准 UUID, 与核心的玩家存储键无关。
$data modify storage zx:sr watch.victim set value "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)"
