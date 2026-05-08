import sys

pop_info_file = "/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popmap_albo.txt"

ind_2_native_invaded = {}

with open( pop_info_file ) as IN:
    for l in IN:
        sl = l.strip().split()
        ind_2_native_invaded[ sl[0] ] = sl[2]
    
ind_2_native_invaded


#indv_info_file
indv_info_file = sys.argv[1]

#FM_threshold=0.3
FM_threshold = float( sys.argv[2] )

#prefix='test'
prefix= sys.argv[3]


out_all =  prefix + ".in.txt" 
out_native = prefix + '.in.native.txt'
out_invaded = prefix + '.in.invaded.txt'

na = 0
nn = 0
ni = 0

# csv file INDV,MEAN_DEPTH,F_MISS,population

with open( indv_info_file )  as IN , open( out_all , 'w'  ) as OUT , open( out_native , 'w'  ) as OUT_native , open( out_invaded , 'w'  ) as OUT_invaded  :
    IN.readline()## header 
    for l in IN:
        sl = l.strip().split(',')
        ind = sl[0]
        fmiss = float(sl[2])
        if fmiss > FM_threshold:
            continue
        print( ind,ind , file=OUT )

        na += 1

        OUT_sub = OUT_native
        if ind_2_native_invaded[ind] == 'invaded':
            OUT_sub = OUT_invaded
            ni += 1
        else:
            nn += 1
            
        print( ind , file=OUT_sub )

print('wrote {} individuals; {} native ; {} invaded'.format(na,nn,ni))
