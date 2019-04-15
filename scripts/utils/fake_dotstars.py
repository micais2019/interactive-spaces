
class FakeDotstars:
    def __init__(self, pin1, pin2, count, *args, **kwargs):
        self.length = count
        self.fill((0, 0, 0))

    def fill(self, color):
        self.state = [color for c in self.state]

    def __getitem__(self, index):
        self.state[index]

    def __setitem__(self, index, color):
        if index < 0 or index >= len(self.state):
            print("FakeDotstars index out of range:", index)
        else:
            self.state[index] = color

    def __iter__(self):
        return self.state

    def inspect(self):
        print("{} Fake Dotstars in a strip".format(self.length))
        for color in self.state:
            print("  {}".format(tuple(color)))

