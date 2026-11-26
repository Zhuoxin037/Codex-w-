"""Test the training pavilion on the private vanilla server with two inventories."""

from lobby_expansion import DUMMY, PREVIEW, RACK, TRAINING_DIM, TRAINING_TAG
from lobby_metrics import OBJ
from training_world import EXIT, RACK_NEAR, STORE, coords
from world import ROOT, native
from verify import OTHER, PLAYER, command, status, storage, tags, wait
from verify_lobby import action, dimension


def move(player, point, dim):
    command(f"execute in {dim} run tp {player} {coords(point)}")


def inventory(player):
    return command(f"data get entity {player} Inventory").split("contents: ")[-1]


def hit(index, damage, kind="minecraft:magic"):
    return command(f"execute in {TRAINING_DIM} run damage "
                   f"@e[tag={DUMMY}_{index},distance=0..,limit=1] {damage} {kind} by {PLAYER}")


GEAR = {
    PLAYER: {"armor.head": "iron_helmet[damage=12]", "weapon.offhand": "compass[item_name={text:\"原副手\"}]"},
    OTHER: {"armor.feet": "iron_boots[damage=16]"},
}


def wears(player, slot, item):
    return "passed" in command(f"execute if items entity {player} {slot} {item}").lower()


def training_active(player):
    return f'"{TRAINING_TAG}"' in tags(player)


def verify(work=None):
    native.WORK = work or ROOT/".workbuddy/rogue_training_world_20261123"
    native.NATIVE = native.WORK/"final"
    native.rcon.D = native.NATIVE
    if PLAYER not in command("list"):
        native.clients()
    wait(lambda: "1b" in storage("built",STORE), "training terrain and gate built",45)
    for player in (PLAYER, OTHER):
        if training_active(player):
            action(player,3)
            wait(lambda: not training_active(player), "clear earlier training session")
        move(player,(260.5,78,18.5),"minecraft:overworld")
        command(f"clear {player}")
    command(f'item replace entity {PLAYER} hotbar.0 with diamond_sword[damage=41,'
            'enchantments={"minecraft:sharpness":3},custom_data={test:"mine"}]')
    command(f'item replace entity {PLAYER} inventory.8 with arrow 31')
    command(f'item replace entity {PLAYER} armor.head with iron_helmet[damage=12]')
    command(f'item replace entity {PLAYER} weapon.offhand with compass[item_name={{text:"原副手"}}]')
    command(f'item replace entity {PLAYER} enderchest.8 with amethyst_shard 4')
    command(f'item replace entity {OTHER} hotbar.0 with stick[custom_data={{test:"theirs"}}] 7')
    command(f'item replace entity {OTHER} armor.feet with iron_boots[damage=16]')
    assert all(wears(player,slot,item) for player,gear in GEAR.items() for slot,item in gear.items())
    before = {player: inventory(player) for player in (PLAYER,OTHER)}
    assert "minecraft:sharpness" in before[PLAYER]
    gates = {PLAYER:(275.5,78,30.5), OTHER:(275.5,78,30.0)}
    for player in (PLAYER,OTHER):
        move(player,gates[player],"minecraft:overworld")
        wait(lambda: dimension(player,TRAINING_DIM) and training_active(player),
             "cross the lobby gate")
        assert inventory(player).endswith("[]")
        assert all(not wears(player,slot,"*") for slot in GEAR[player])
        move(player,(272.5,78,30.5),TRAINING_DIM)
        wait(lambda: RACK_NEAR in tags(player), "equipment opens on approach")
    action(PLAYER,120)
    row = storage("row",PREVIEW)
    assert all(value in row for value in ("show_item","click_event","minecraft:lore","minecraft:item_name"))
    shown = command(f"execute in {TRAINING_DIM} as {PLAYER} at @s run "
                    f"function sweetdream_floor:lobby/practice/preview/show with storage {PREVIEW}")
    assert "failed" not in shown.lower(), shown
    action(PLAYER,300)
    action(OTHER,301)
    for player in (PLAYER,OTHER):
        assert "sd_training: 1b" in inventory(player)
    print("Independent room, automatic equipment menu, and real shop-style tooltips passed.",flush=True)

    wait(lambda: all(status(f"#sum{i}",OBJ)==0 and status(f"#hp{i}",OBJ)==1024000 for i in (0,1)),
         "wait for previous stats to expire and targets to recover")
    start = status("#clock",OBJ)
    hit(0,256)
    wait(lambda: status("#last0",OBJ)==256000, "damage tracked on first dummy")
    wait(lambda: 768000 < status("#hp0",OBJ) < 1024000, "regeneration starts shortly after the first hit")
    assert status("#clock",OBJ)-start < 30
    hit(1,100)
    wait(lambda: status("#last1",OBJ)==100000, "damage tracked on second dummy")
    second = status("#clock",OBJ)
    hit(0,80,"sweetdream:parallel_true_damage")
    wait(lambda: status("#last0",OBJ)==80000, "second hit is measured during recovery")
    after_hit = status("#hp0",OBJ)
    wait(lambda: status("#hp0",OBJ)>after_hit, "regeneration continues through repeated attacks")
    assert status("#clock",OBJ)-second < 30
    assert status("#sum0",OBJ)==336000 and status("#sum1",OBJ)==100000
    wait(lambda: status("#hp0",OBJ)==1024000 and status("#hp1",OBJ)==1024000,"dummies recover to full")
    assert status("#last0",OBJ)==80000 and status("#last1",OBJ)==100000
    print("Recovery continued between hits, and both damage totals matched actual health loss.",flush=True)

    move(PLAYER,EXIT,TRAINING_DIM)
    action(OTHER,3)
    for player in (PLAYER,OTHER):
        wait(lambda: dimension(player,"minecraft:overworld") and not training_active(player),
             "return to overworld and clear session")
        assert inventory(player)==before[player],(inventory(player),before[player])
        assert all(wears(player,slot,item) for slot,item in GEAR[player].items())
        position = "["+", ".join(f"{float(c)}d" for c in gates[player])+"]"
        assert position in command(f"data get entity {player} Pos")
    assert 'count: 4' in command(f"data get entity {PLAYER} EnderItems")
    assert "contents: {}" in storage("vault",STORE)
    print("Both original inventories, equipment slots, item components, and exact entrance positions were restored.",flush=True)


if __name__ == "__main__":
    verify()
