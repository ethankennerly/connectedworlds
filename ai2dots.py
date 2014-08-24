"""
Convert Adobe Illustrator CS4 format to dots level format.
CS4 .ai format appears to be a kind of postscript.
http://www.physics.emory.edu/faculty/weeks//graphics/howtops1.html
A spatial graph:  dots, connections.

Usage:  python ai2dots.py file.ai [...]
"""


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

_example_dots_text = """
    {connections: [[0, 1], [0, 2], [1, 2]], 
     dots: [[-160, 120], [0, -120], [160, 120]]},
"""


def parse(ai_text):
    """
    Dictionary of lists of dots and connections.
    Center by extreme coordinates.
    >>> triangle = parse(_example_ai_text)
    >>> triangle['connections']
    [[0, 1], [0, 2], [1, 2]]
    >>> triangle['dots']
    [[167, 138], [4, -146], [-160, 138]]
    """
    lines = ai_text.splitlines()
    connections = []
    dots = []
    coordinating = False
    connecting = False
    coordinates = {}
    index = -1
    previous = -1
    for line in lines:
        words = line.split(' ')
        if 'U' == words[-1]:
            break;
        if 'S' == words[-1]:
            coordinating = False
            connecting = False
        if 'm' == words[-1]:
            coordinating = True
            connecting = False
        if 'L' == words[-1]:
            connecting = True
        if coordinating:
            x = int(round(float(words[0]), 0))
            y = int(round(float(words[1]), 0))
            key = y * 10000 + x
            if key in coordinates:
                index = coordinates[key]
            else:
                index += 1
                coordinates[key] = index
                dots.append([x, y])
        if connecting:
            connection = [previous, index]
            connection.sort()
            connections.append(connection)
        previous = index
    connections.sort()
    center(dots)
    invert(dots)
    graph = {'connections': connections, 'dots': dots}
    return graph


def invert(coordinates):
    """
    >>> dots = [[167, -138], [4, 146], [-160, -138]]
    >>> invert(dots)
    >>> dots
    [[167, 138], [4, -146], [-160, 138]]
    """
    for c, coordinate in enumerate(coordinates):
        coordinates[c][1] *= -1


def center(coordinates):
    """
    >>> dots = [[331, 4], [168, 288], [4, 4]]
    >>> center(dots)
    >>> dots
    [[167, -138], [4, 146], [-160, -138]]
    """
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
    xOffset = (xMin - xMax) / 2
    yOffset = (yMin - yMax) / 2
    for c, coordinate in enumerate(coordinates):
        coordinates[c][0] += xOffset
        coordinates[c][1] += yOffset


def main(paths):
    # print 'main: paths %r' % paths
    graphs = []
    for path in paths:
        ai_text = open(path, 'rU').read()
        graphs.append(parse(ai_text))
    return graphs


if '__main__' == __name__:
    import sys
    if len(sys.argv) <= 1:
        print __doc__
    else:
        import glob
        files = glob.glob(sys.argv[1])
        print "levels =", pprint.pformat(main(files))
    import doctest
    doctest.testmod();
