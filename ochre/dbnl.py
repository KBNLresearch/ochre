import edlib

from collections import Counter


class Note():
    def __init__(self, text, index, source_text_length):
        self.index = index
        self.text = text
        self.source_text_length = source_text_length
        self.lines_to_check = []
        self.lines = []
        self.candidates = []
        self.added = []

        self.previous = None
        self.next = None

        self.done = False
        self.short = False

    def __str__(self):
        return '(Note {}) {}'.format(self.index, self.text[:50].strip())

    def get_search_start(self):
        if self.previous is None:
            return 0
        elif self.previous.lines != []:
            return self.previous.lines[-1] + 1
        else:
            return self.previous.get_search_start()

    def get_search_end(self):
        if self.next is None:
            return self.source_text_length
        elif self.next.lines != []:
            return self.next.lines[0]
        else:
            return self.next.get_search_end()

    def get_search_indices(self):
        return range(self.get_search_start(), self.get_search_end())

    def to_fragment(self, lines):
        return to_fragment(lines, self.lines)

    def ed(self, lines):
        fragment = self.to_fragment(lines)
        return edlib.align(self.text, fragment)['editDistance']

    def complete(self, lines, threshold=0.2):
        self.done = complete(self.text, self.to_fragment(lines), threshold)
        return self.done


def to_fragment(lines, indices):
    return ''.join([lines[i] for i in indices])


def complete(note, fragment, treshold=0.2):
    ed = edlib.align(note, fragment)['editDistance']
    score = ed/len(note)
    #print('completeness score', score)
    if score < treshold:
        return True
    return False


def get_repeated(notes):
    c = Counter()
    num_lines = 0

    for note in notes:
        c[note] += 1

    repeated = []
    ns = []
    for k, v in c.most_common():
        if v > 1:
            num_lines += v
            repeated.append(k)
        else:
            ns.append(k)

    return repeated


def extend_lines(indexes, length, num=3):
    result = []
    for i in indexes:
        result.append(i)
        # lines before i
        start = max(0, i-num)
        to_add = list(range(start, i))
        for n in to_add:
            result.append(n)

        # lines after i
        end = min(length, i+num+1)
        to_add = list(range(i, end))
        for n in to_add:
            result.append(n)

    result = list(set(result))
    result.sort()

    return(result)
