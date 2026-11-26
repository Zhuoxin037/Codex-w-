"""Check every potential doorway and encounter spawn across all generated variants."""
from collections import deque
from itertools import product
import architecture


def relative(token):
    return int(token.removeprefix("~") or "0")


def layout(commands):
    world = {}
    for parts in map(str.split, commands):
        if parts[0] == "fill":
            axes = zip(map(relative, parts[1:4]), map(relative, parts[4:7]))
            ranges = [range(min(a,b),max(a,b)+1) for a,b in axes]
            material = parts[7].split("[")[0].removeprefix("minecraft:")
            for pos in product(*ranges):
                world[pos] = material
        elif parts[0] == "setblock":
            pos = tuple(map(relative,parts[1:4]))
            world[pos] = parts[4].split("[")[0].removeprefix("minecraft:")
    return world


def room_check(kind, variant):
    world = layout(architecture.room(kind, variant))
    radius = architecture.radius(kind)
    passable = ("air","short_grass","fern","brown_mushroom","red_mushroom")

    def clear(x, z):
        return (abs(x)<radius and abs(z)<radius
                and world.get((x,0,z)) not in (None,"air","water")
                and all(world.get((x,y,z),"air") in passable for y in (1,2)))

    assert clear(4,0), (kind,variant,"unsafe landing")
    seen = {(4,0)}
    waiting = deque(seen)
    while waiting:
        x,z = waiting.popleft()
        for pos in [(x+1,z),(x-1,z),(x,z+1),(x,z-1)]:
            if clear(*pos) and pos not in seen:
                seen.add(pos)
                waiting.append(pos)
    approaches = {(radius-1,0),(1-radius,0),(0,radius-1),(0,1-radius)}
    assert approaches <= seen, (kind,variant,"blocked approach",approaches-seen)
    if kind in ("combat","elite"):
        spawns = {(-4,-2),(2,-4),(4,3),(-4,3),(0,5),(-2,5)}
        assert spawns <= seen, (kind,variant,"blocked enemy spawn",spawns-seen)
    if kind == "boss":
        assert (0,-4) in seen, (kind,variant,"blocked Knight spawn")


def corridor_check(axis, first, second):
    world = layout(architecture.corridor(axis,first,second))
    for along in range(first,architecture.PITCH+1-second):
        for across in range(-architecture.DOOR_HALF,architecture.DOOR_HALF+1):
            def coord(y):
                return (along,y,across) if axis=="east" else (across,y,along)

            assert world[coord(0)] in ("mossy_stone_bricks","spruce_planks")
            assert all(world[coord(y)]=="air" for y in range(1,6))


if __name__ == "__main__":
    kinds = ("entry","combat","elite","boss","safe","merchant","rental","blackmarket","forge","astrology","gamble","event")
    failures = []
    for kind, variant in product(kinds,range(3)):
        try:
            room_check(kind, variant)
        except AssertionError as error:
            failures.append(error.args[0])
    for corridor in product(("east","south"),architecture.RADII,architecture.RADII):
        corridor_check(*corridor)
    assert not failures, failures
    print("36 room variants have clear approaches and spawn positions. All 18 corridor variants have full-height doorways.")
