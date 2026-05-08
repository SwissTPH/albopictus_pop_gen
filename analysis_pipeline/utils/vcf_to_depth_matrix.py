def parse_indiv_info( X ):
    '''0/0:2:2,0:31:-0.00,-2.51,-11.42
    
    ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
    ##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read Depth">
    ##FORMAT=<ID=AD,Number=R,Type=Integer,Description="Allele Depth">
    ##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
    ##FORMAT=<ID=GL,Number=G,Type=Float,Description="Genotype Likelihood">
    
    GT:DP:AD:GQ:GL
    '''
    if X == "./.:.:.:.:.":
        return {'GT': './.' , 'DP': 0 , 'AD' : [0,0], 'GQ' : 0, 'GL' : [ 0.0,0.0,0.0 ] }
    sX = X.split( ':' )
    res = {'GT':sX[0] , 'DP': int( sX[1] ) , 
     'GQ' : int(sX[3]),
     'GL' : [ float(x) for x in sX[4].split(',') ] }

    if sX[2] == '.':
        res['AD'] = [0,0]
        res['AD'][int( res['GT'][0] ) ] = res['DP']
    else:
        res['AD'] = [ int(x) for x in sX[2].split(',') ]
    
    return res
    


def parse_line( l ):
    sl = l.strip().split('\t')
    pre = sl[:9]
    indiv = [ parse_indiv_info(x) for x in sl[9:] ]
    return pre,indiv


if __name__ == '__main__':
    import sys
    import gzip

    fileIN = sys.argv[1]

    with gzip.open( fileIN,"rt" ) as IN:
        for l in IN:
            if l.startswith('##'):
                continue
            elif l.startswith('#'):
                print(l.strip())
                continue
            pre,indiv = parse_line(l)
            
            print(*pre, *([i['DP'] for i in indiv]) , sep='\t')
            

