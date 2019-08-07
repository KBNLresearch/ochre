import os

from collections import Counter

from lxml import etree

UNKNOWN = 'UNKNOWN'
EMPTY = 'EMPTY'


class Match():
    def __init__(self, gs_label, index):
        self.gs_label = gs_label
        self.ocr_label = UNKNOWN

        self.index = index

        self.previous = None
        self.next = None

        self.done = False
        self.short = False

    def __str__(self):
        return '(Match {}) {}-{}'.format(self.index, self.gs_label,
                                         self.ocr_label)

    def is_set(self):
        return self.ocr_label != UNKNOWN

    #def get_options(self, ocr_lines):
    #    for
    def get_search_start(self, ocr_lines):
        #print('getting start')
        if self.previous is None:
            #print('prev is None')
            return 0
        elif self.previous.ocr_label != UNKNOWN:
            #print('prev is known')
            #print(self.previous)
            #print('returning ', self.previous.index)
            #print('should return ', list(ocr_lines.keys()).index(self.previous.ocr_label)+1)
            if self.previous.ocr_label != EMPTY:
                return list(ocr_lines.keys()).index(self.previous.ocr_label) + 1
            else:
                return self.previous.get_search_start(ocr_lines)
        else:
            #print('get prev search start')
            return self.previous.get_search_start(ocr_lines)

    def get_search_end(self, ocr_lines):
        #print('getting end')
        if self.next is None:
            #return self.index + 1
            # the number of ocr_lines could be bigger than the number of match
            # objects
            return len(ocr_lines) + 1
        elif self.next.ocr_label != UNKNOWN:
            #print('next is known')
            #print(self.next)
            #print('returning ', self.next.index)
            #print('should return ', list(ocr_lines.keys()).index(self.next.ocr_label))
            return list(ocr_lines.keys()).index(self.next.ocr_label)
        else:
            return self.next.get_search_end(ocr_lines)

    def get_search_indices(self, ocr_lines):
        return range(self.get_search_start(ocr_lines), self.get_search_end(ocr_lines))

    def get_options(self, ocr_lines, used):
        options = {}
        #print(self.eds)
        #print('get_options search indices', [i for i in self.get_search_indices(ocr_lines)])
        for i in self.get_search_indices(ocr_lines):
            #print(i, list(ocr_lines.keys())[i])
            try:
                label = (list(ocr_lines.keys())[i])
                #print('Trying', label)
                if label not in used:
                    #print('Label not in used')
                    #print(self.eds)
                    #print(self.eds[label])
                    #print('No key error')
                    options[label] = self.eds[label]
            except IndexError:
                pass
            except KeyError:
                pass
        return options

    def get_match(self, ocr_lines, matches, used, method='close'):
        options = self.get_options(ocr_lines, used)
        #print(self)
        #print('options', options)
        if len(options) == 1:
            # Return the key of the first item.
            return next(iter(options.items()))[0]
        elif len(options) == 0:
            #print(EMPTY, self)
            return EMPTY
        else:
            if method == 'close':
                for o_label in sorted(options, key=options.get):
                    if len(' '.join(ocr_lines[o_label])) > 45:
                        if options[o_label] < 15:
                            #print('Close enough, using', o_label)
                            return o_label
            elif method == 'best':
                use = True
                for o_label in sorted(options, key=options.get):

                    #print(o_label)
                    ed = options[o_label]
                    for match in matches:
                        if not match.is_set() and match.index != self.index and o_label in match.eds:
                            ned = match.eds[o_label]
                            #print(match)
                            #print('ned', ned)
                            if ned < ed:
                                use = False
                    if use:
                        #print('Please use', o_label)
                        return o_label
            return UNKNOWN


def print_match(m, gs_lines, ocr_lines):
    return str(m)+'\n GS: '+' '.join(gs_lines[m.gs_label])+'\nOCR: '+' '.join(ocr_lines.get(m.ocr_label, ['NOT FOUND']))



def gt_fname2ocr_fname(fname):
    bn = os.path.basename(fname)
    return bn.replace('GT', 'alto')


def get_ns(fname):
    context = etree.iterparse(fname, events=('start', 'end'))
    for event, elem in context:
        return '{'+elem.nsmap[None]+'}'


def count_unknown(matches):
    num_unknown = 0
    for m in matches:
        if m.ocr_label == UNKNOWN:
            num_unknown += 1
    return num_unknown


def replace_entities(fname):
    with open(fname, encoding='utf8') as f:
        t = f.read()
    t = t.replace('&nbsp;', '&#160;')
    t = t.replace('&ldquo;', '&#8220;')
    t = t.replace('&rdquo;', '&#8221;')
    t = t.replace('&lsquo;', '&#8216;')   # left single quote
    t = t.replace('&rsquo;', '&#8217;')   # right single quote
    t = t.replace('&copy;', '&#169;')
    t = t.replace('&fnof;', '&#192;')     # f-sign (guilders)
    t = t.replace('&rarr;', '&#8594;')    # rightwards arrow
    t = t.replace('&Euml;', '&#203;')     # capital E, dieresis or umlaut mark
    t = t.replace('&Uuml;', '&#220;')     # capital U, dieresis or umlaut mark
    t = t.replace('&Auml;', '&#196;')     # capital A, dieresis or umlaut mark
    t = t.replace('&Ouml;', '&#214;')     # capital O, dieresis or umlaut mark
    t = t.replace('&Egrave;', '&#353;')     # capital E, grave accent
    t = t.replace('&scaron;', '&#200;')     # latin small letter s with caron
    t = t.replace('&yacute;', '&#253;')     # y, acute accent
    t = t.replace('&otilde;', '&#245;')   # small o, tilde
    t = t.replace('&atilde;', '&#227;')   # small a, tilde
    t = t.replace('&ntilde;', '&#241;')   # small n, tilde
    t = t.replace('&plusmn;', '&#177;')   # +/-
    t = t.replace('&times;', '&#215;')    # multiply sign
    t = t.replace('&sect;', '&#167;')    # section (?)
    t = t.replace('&pi;', '&#960;')    # pi
    t = t.replace('&Epsilon;', '&#917;')    # greek capital letter epsilon
    t = t.replace('&rho;', '&#961;')    # greek small letter rho
    t = t.replace('&omega;', '&#969;')    # greek small letter omega
    t = t.replace('&tau;', '&#964;')    # greek small letter tau
    t = t.replace('&omicron;', '&#959;')    # greek small letter omicron
    t = t.replace('&alpha;', '&#945;')    # greek small letter alpha
    t = t.replace('&iota;', '&#953;')    # greek small letter iota
    t = t.replace('&gamma;', '&#947;')    # greek small letter gamma
    t = t.replace('&nu;', '&#957;')    # greek small letter nu
    t = t.replace('&sigmaf;', '&#962;')    # greek small letter final sigma
    t = t.replace('&upsilon;', '&#965;')    # greek small letter upsilon
    t = t.replace('&kappa;', '&#954;')    # greek small letter kappa
    t = t.replace('&mu;', '&#956;')    # greek small letter mu
    t = t.replace('&lambda;', '&#955;')    # greek small letter lambda
    t = t.replace('&epsilon;', '&#949;')    # greek small letter epsilon
    t = t.replace('&eta;', '&#951;')    # greek small letter eta
    t = t.replace('&delta;', '&#948;')    # greek small letter delta
    t = t.replace('&theta;', '&#952;')    # greek small letter theta
    t = t.replace('&phi;', '&#966;')    # greek small letter phi
    t = t.replace('&zeta;', '&#950;')    # greek small letter zeta
    t = t.replace('&sigma;', '&#963;')    # greek small letter sigma
    t = t.replace('&beta;', '&#946;')    # greek small letter beta
    t = t.replace('&chi;', '&#967;')    # greek small letter chi
    t = t.replace('&Tau;', '&#932;')    # greek capital letter tau
    t = t.replace('&Mu;', '&#924;')    # greek capital letter mu
    t = t.replace('&Eta;', '&#919;')    # greek capital letter eta
    t = t.replace('&Omicron;', '&#927;')    # greek capital letter omicron
    t = t.replace('&Delta;', '&#916;')    # greek small letter delta
    t = t.replace('&', '&#38;')  # ampersand

    return t
