"""
Convert Adobe Illustrator CS4 format to graph format.
CS4 .ai format appears to be a kind of postscript.
http://www.physics.emory.edu/faculty/weeks//graphics/howtops1.html
A spatial graph:  dots, connections.

Usage:  python ai2dots.py [--lua] [--vertical] file.ai [...]
    --lua:  Add one to connection indexes.
    --vertical:  Do not vertically center.
Vim example:   :%!python ai2dots.py ai/*.ai
               :%!python ai2dots.py --vertical ai_digits/*.ai
"""


import copy
import pprint


_example_ai_text = """
%%EndSetup
u
[]0 d
0.600 0.000 0.000 0.000 K
1 j
1 J
8.000000 w
331.3 4.0 m
167.6 287.5 L
4.0 4.0 L
331.3 4.0 L
S
U
%%PageTrailer
"""

_point_ai_text = """
[]0 d
0.600 0.000 0.000 0.000 K
1 j
1 J
16.000000 w
37.0 318.0 m
33.0 321.0 L
f
"""

_example_dots_text = """
    {connections: [[0, 1], [0, 2], [1, 2]], 
     dots: [[-160, 120], [0, -120], [160, 120]]},
"""

_cheer_ai_text = """
%%EndSetup
u
[]0 d
0.600 0.000 0.000 0.000 K
1 j
1 J
80.000000 w
40.0 370.0 m
197.0 262.0 L
S
[]0 d
0.600 0.000 0.000 0.000 K
1 j
1 J
80.000000 w
197.0 154.0 m
54.0 40.0 L
S
[]0 d
0.600 0.000 0.000 0.000 K
1 j
1 J
80.000000 w
197.0 262.0 m
347.0 370.0 L
S
[]0 d
0.600 0.000 0.000 0.000 K
1 j
1 J
80.000000 w
197.0 154.0 m
339.0 45.0 L
S
[]0 d
0.600 0.000 0.000 0.000 K
1 j
1 J
80.000000 w
197.0 262.0 m
197.0 154.0 L
S
[]0 d
0.600 0.000 0.000 0.000 K
1 j
1 J
80.000000 w
195.0 413.0 m
194.0 424.0 L
S
U
%%PageTrailer
"""


def parse(ai_text, vertical=True):
    """
    Dictionary of lists of dots and connections.

    Collapse nearby points if 10 pixels away.
    Store key in a dictionary of 10 pixel grid.
    >>> pprint.pprint(parse(_point_ai_text))
    {'connections': [], 'dots': [[0, 0]]}

    Center by extreme coordinates.  Sort dots.
    >>> triangle = parse(_example_ai_text)
    >>> triangle['connections']
    [[0, 1], [1, 2], [2, 0]]
    >>> triangle['dots']
    [[-164, 142], [0, -142], [163, 142]]

    If not vertical, retain disconnected dots but do not vertically center.
    >>> pprint.pprint(parse(_point_ai_text, False))
    {'connections': [], 'dots': [[0, -78]]}

    Connect merging line segments.
    >>> cheer = parse(_cheer_ai_text)
    >>> pprint.pprint(cheer['connections'])
    [[0, 3], [3, 4], [4, 5], [1, 4], [6, 3]]
    >>> pprint.pprint(cheer['dots'])
    [[-154, -144],
     [-140, 186],
     [1, -187],
     [3, -36],
     [3, 72],
     [145, 181],
     [153, -144]]
    """
    lines = ai_text.splitlines()
    connections = []
    dots = []
    coordinating = False
    coordinates = {}
    index = -1
    for line in lines:
        connecting = False
        words = line.split(' ')
        if 'U' == words[-1]:
            break;
        if words[-1] in ['S', 'f']:
            coordinating = False
        elif 'm' == words[-1]:
            coordinating = True
        elif 'L' == words[-1]:
            connecting = True
            previous = index
        if coordinating:
            x = int(round(float(words[0]), 0))
            y = int(round(float(words[1]), 0))
            nearIndex = near(dots, x, y)
            if 0 <= nearIndex:
                index = nearIndex
            else:
                index = len(dots)
                dots.append([x, y])
        if connecting and previous != index:
            connection = [previous, index]
            connection.sort()
            connections.append(connection)
    center(dots, vertical)
    sort(dots, connections)
    graph = {'connections': connections, 'dots': dots}
    return graph


def near(dots, x, y):
    """
    >>> near([[0, 0]], 20, 40)
    -1
    >>> near([[0, 0]], -19, -20)
    -1
    >>> near([[0, 0]], 19, 19)
    0
    """
    radius = 20 # 40 < ? < 120
    index = -1
    for d in range(len(dots)):
        kx, ky = dots[d]
        if abs(ky - y) < radius and abs(kx - x) < radius:
            index = d
            break
    return index


def invert(coordinates):
    """
    >>> dots = [[167, -138], [4, 146], [-160, -138]]
    >>> invert(dots)
    >>> dots
    [[167, 138], [4, -146], [-160, 138]]
    """
    for c, coordinate in enumerate(coordinates):
        coordinates[c][1] *= -1


def center(coordinates, vertical=True):
    """
    And invert
    >>> dots = [[331, 4], [168, 288], [4, 4]]
    >>> center(dots)
    >>> dots
    [[163, 142], [0, -142], [-164, 142]]

    If not vertical, manually set y to 240 (half screen).
    Because 0 has no pips above it.
    """
    invert(coordinates)
    xMin = 99999
    yMin = 99999
    xMax = -99999
    yMax = -99999
    for x, y in coordinates:
        if x < xMin:
            xMin = x
        if xMax < x:
            xMax = x
        if y < yMin:
            yMin = y
        if yMax < y:
            yMax = y
    xOffset = (xMin + xMax) / -2
    if vertical:
        yOffset = (yMin + yMax) / -2
    else:
        yOffset = 240 
    for c, coordinate in enumerate(coordinates):
        coordinates[c][0] += xOffset
        coordinates[c][1] += yOffset


def sort(dots, connections):
    """Sort dots left to right.
    Trace finger over mark from left to right.  
    2014-08-29 checkmark.  Samantha Yang expects to feel aware to trace.  Got confused.

    >>> line = {'connections': [[0, 1]], 'dots': [[113, -113], [-113, 113]]}
    >>> sort(line['dots'], line['connections'])
    >>> line['dots']
    [[-113, 113], [113, -113]]
    >>> line['connections']
    [[0, 1]]
    >>> dip = {}
    >>> dip['connections'] = [[0, 1], [0, 2]]
    >>> dip['dots'] = [[0, -142], [163, 142], [-164, 142]]
    >>> sort(dip['dots'], dip['connections'])
    >>> dip['dots']
    [[-164, 142], [0, -142], [163, 142]]
    >>> dip['connections']
    [[0, 1], [1, 2]]
    
    Remove duplicate connections, which game does not tolerate.
    2014-09-08 Cat. Cannot complete.
    >>> line = {'connections': [[0, 1], [0, 1]], 'dots': [[113, -113], [-113, 113]]}
    >>> sort(line['dots'], line['connections'])
    >>> line['dots']
    [[-113, 113], [113, -113]]
    >>> line['connections']
    [[0, 1]]

    Pendant dots first.
    2014-09-19 Chris Hewitt expects to see a hint of a unicursal trace.
    >>> line = {'connections': [[0, 1], [1, 2]], 'dots': [[113, -113], [0, 0], [-113, 113]]}
    >>> sort(line['dots'], line['connections'])
    >>> line['dots']
    [[-113, 113], [0, 0], [113, -113]]
    >>> line['connections']
    [[0, 1], [1, 2]]

    If no difference in connection count, top left first.
    >>> line = {'connections': [[0, 1], [1, 2], [0, 2]], 
    ...     'dots': [[113, -113], [-113, -113], [-113, 113]]}
    >>> sort(line['dots'], line['connections'])
    >>> line['dots']
    [[-113, -113], [-113, 113], [113, -113]]

    Connected in drawing order.
    >>> line['connections']
    [[0, 1], [1, 2], [2, 0]]
    """
    if not dots:
        return
    olds = [dot for dot in dots]
    dots.sort()
    if not connections:
        return
    for c in connections:
        c[0] = dots.index(olds[c[0]])
        c[1] = dots.index(olds[c[1]])
        c.sort()
    connections.sort()
    next = None
    for current in reversed(connections):
        if current == next:
            connections.remove(next)
        next = current
    counts = {}
    for a, b in connections:
        counts[a] = counts.setdefault(a, 0) + 1
        counts[b] = counts.setdefault(b, 0) + 1
    minicursal = []
    head = _minicurse(connections, minicursal, counts)
    c = 0
    attempt = 0
    while 1 <= len(connections):
        assert c < len(connections), 'Expected %i less than %r' % (c, connections)
        a, b = connections[c]
        next = None
        if a == head:
            next = b
        elif b == head:
            next = a
        if next is None:
            c = (c + 1) % len(connections)
            if 0 == c:
                head = _minicurse(connections, minicursal, counts)
        else:
            minicursal.append([head, next])
            del connections[c]
            if len(connections) <= c:
                c = 0
            head = next
            next = None
        attempt += 1
        assert attempt < 1024, 'Expected to traverse all dots by now'
    connections[:] = minicursal        


def _minicurse(connections, minicursal, counts):
    """
    Attempt to find nearest pendant of a unicursal graph.
    Parameters are modified in place.  Return head.
    >>> _minicurse([], [], {})
    >>> conns = [[0, 1]]
    >>> counts = {0: 1, 1: 1}
    >>> curse = []
    >>> _minicurse(conns, curse, counts)
    1
    >>> conns
    []
    >>> curse
    [[0, 1]]
    >>> counts[0]
    0
    >>> counts[1]
    0
    """
    min = 1
    head = None
    first = None
    start = len(minicursal)
    attempt = 0
    while len(minicursal) == start and connections:
        for c, (a, b) in enumerate(connections):
            if counts[a] == min:
                first = [a, b]
                head = b
            elif counts[b] == min:
                first = [b, a]
                head = a
            if first:
                minicursal.append(first)
                del connections[c]
                counts[a] -= 1
                counts[b] -= 1
                break
        else:
            min += 1
        attempt += 1
        assert attempt < 1024, 'Expected to find least connected node.'
    return head


def main(paths, vertical=True):
    # print 'main: paths %r' % paths
    graphs = []
    for path in paths:
        ai_text = open(path, 'rU').read()
        graphs.append(parse(ai_text, vertical))
    return graphs


def py2lua(graphs):
    """
    Add 1 to connection indexes.  
    Pretty formatted text of lua data structure.
    >>> graphs = [{'connections': [[0, 1]], 'dots': [[-113, 113], [113, -113]]}]
    >>> py2lua(graphs)
    '{{connections = {{1, 2}}, dots = {{-113, 113}, {113, -113}}}}'
    """
    graphs_index_1 = copy.deepcopy(graphs)
    for graph in graphs_index_1:
        for connection in graph['connections']:
            for i in range(len(connection)):
                connection[i] += 1
    lua = pprint.pformat(graphs_index_1)
    lua = lua.replace('[', '{').replace(']', '}')
    lua = lua.replace(':', ' =').replace("'", '')
    return lua


if '__main__' == __name__:
    import sys
    vertical = True
    options = ''
    lua = False
    if 2 <= len(sys.argv) and '--lua' == sys.argv[1]:
        lua = True
        options += sys.argv[1]
        del sys.argv[1]
    if 2 <= len(sys.argv) and '--vertical' == sys.argv[1]:
        vertical = False
        options += sys.argv[1]
        del sys.argv[1]
    if len(sys.argv) <= 1:
        print __doc__
        import doctest
        doctest.testmod();
    else:
        import glob
        globbing = sys.argv[1]
        files = glob.glob(globbing)
        graphs = main(files, vertical)
        if lua:
            comment = '--'
            prefix = 'return '
            text = py2lua(graphs)
        else:
            comment = '//'
            prefix = 'graphs = '
            text = pprint.pformat(graphs)
        print "%s Auto generated by ai2dots.py %s %s\n%s%s" % (
            comment, options, globbing, prefix, text)
