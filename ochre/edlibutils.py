import re
import edlib


def align_characters(query, ref, empty_char=''):
    a = edlib.align(query, ref, task="path")
    ref_pos = a["locations"][0][0]
    query_pos = 0
    ref_aln = []
    match_aln = ""
    query_aln = []

    for step, code in re.findall(r"(\d+)(\D)", a["cigar"]):
        step = int(step)
        if code == "=":
            for c in ref[ref_pos: ref_pos + step]:
                ref_aln.append(c)
            #ref_aln += ref[ref_pos : ref_pos + step]
            ref_pos += step
            for c in query[query_pos: query_pos + step]:
                query_aln.append(c)
            #query_aln += query[query_pos : query_pos + step]
            query_pos += step
            match_aln += "|" * step
        elif code == "X":
            for c in ref[ref_pos: ref_pos + step]:
                ref_aln.append(c)
            #ref_aln += ref[ref_pos : ref_pos + step]
            ref_pos += step
            for c in query[query_pos: query_pos + step]:
                query_aln.append(c)
            #query_aln += query[query_pos : query_pos + step]
            query_pos += step
            match_aln += "." * step
        elif code == "D":
            for c in ref[ref_pos: ref_pos + step]:
                ref_aln.append(c)
            #ref_aln += ref[ref_pos : ref_pos + step]
            ref_pos += step
            #query_aln += " " * step
            query_pos += 0
            for i in range(step):
                query_aln.append('')
            match_aln += " " * step
        elif code == "I":
            for i in range(step):
                ref_aln.append('')
            #ref_aln += " " * step
            ref_pos += 0
            for c in query[query_pos: query_pos + step]:
                query_aln.append(c)
            #query_aln += query[query_pos : query_pos + step]
            query_pos += step
            match_aln += " " * step
        else:
            pass

    return ref_aln, query_aln, match_aln


def align_output_to_input(input_str, output_str, empty_char=u'@'):
    t_output_str = output_str.encode('ASCII', 'replace')
    t_input_str = input_str.encode('ASCII', 'replace')
    #try:
    #    r = edlib.align(t_input_str, t_output_str, task='path')
    #except:
    #    print(input_str)
    #    print(output_str)
    r1, r2 = align_characters(input_str, output_str,
                              empty_char=empty_char)
    while len(r2) < len(input_str):
        r2.append(empty_char)
    return u''.join(r2)
