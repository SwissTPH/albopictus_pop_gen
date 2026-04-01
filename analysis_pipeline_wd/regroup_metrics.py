def read_indv_to_pop(file = '/scicore/home/muellepi/GROUP/albopictus/info/albo_global_pops_UNSD.txt'):
    indv_to_pop = {}
    with open( file ) as IN:
        for l in IN:
            sl = l.strip().split('\t')
            indv_to_pop[ sl[0] ] = sl[1]
    return indv_to_pop


def fill_template(prefix , template):
    for i,E in enumerate( template ):

        with open( prefix + E['suffix'] ) as IN:
            IN.readline()
            for l in IN:
                sl = l.strip().split()
                template[i]['values'].append( sl[E['field']] )

    return template

def write_template( fileName , template ):
    with open( fileName , 'w') as OUT:
        header = [e['name'] for e in template]
        print( *header , sep=',' , file = OUT )
        
        n = len( template[0]['values'] )
        for i in range(n):
            V = [e['values'][i] for e in template]
            print( *V , sep=',' , file = OUT )

template_INDV = [dict( suffix = '.imiss',
                  field = 0,
                  name = 'INDV',
                  values = [] ),
                 dict( suffix = '.idepth',
                  field = 2,
                  name = 'MEAN_DEPTH',
                  values = [] ),
                 dict( suffix = '.imiss',
                  field = 4,
                  name = 'F_MISS',
                  values = [] )]


template_sites = [dict( suffix = '.frq',
                  field = 0,
                  name = 'CHROM',
                  values = [] ),
            dict( suffix = '.frq',
                  field = 1,
                  name = 'POS',
                  values = [] ),
            dict( suffix = '.frq',
                  field = 5,
                  name = 'FRQ_alt',
                  values = [] ),
            dict( suffix = '.ldepth.mean',
                  field = 3,
                  name = 'MEAN_DEPTH',
                  values = [] ),
            dict( suffix = '.lmiss',
                  field = 5,
                  name = 'F_MISS',
                  values = [] ) ]



if __name__ == "__main__":
    import sys

    input_prefix = sys.argv[1]
    output_prefix = sys.argv[2]

    indv_to_pop = read_indv_to_pop(file = '/scicore/home/muellepi/GROUP/albopictus/info/albo_global_pops_UNSD.txt')

    tmp = fill_template( input_prefix , template_sites)
    write_template( output_prefix + 'site_metrics.csv' , tmp )

    tmp = fill_template( input_prefix , template_INDV)
    tmp.append(dict( name = 'population' ,
               values = [ indv_to_pop.get(i, i+'_'+i) for i in tmp[0]['values'] ]))

    write_template( output_prefix + 'indv_metrics.csv' , tmp )


