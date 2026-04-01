import sys

def find_pos(header , to_find):
    positions = []
    for tf in to_find:
        positions.append(None)
        for p,name in enumerate( header ):
            if name == tf or name == tf+'_'+tf or name.rpartition('@')[-1] == tf:
                positions[-1] = p
                break
    return positions




input_vcfgz = sys.argv[1]
to_remove_file = sys.argv[2]
output_vcfgz = sys.argv[3]


toRemove = []
with open( to_remove_file ) as IN:
    for l in IN:
        toRemove.append( l.strip().split()[0] )

print(f"found {len(toRemove)}elements to remove from the vcf")



import gzip
with gzip.open( input_vcfgz , 'rb') as IN , gzip.open( output_vcfgz , 'wb' ) as OUT:
    
    pos_to_remove = None
    pos_to_keep = None
    for l in IN:
        if l.startswith(b"##"):
            OUT.write(l)
            
        elif l.startswith(b"#CHROM"):
            header = l.decode().strip().split('\t')
            pos_to_remove = find_pos(header , toRemove)
            pos_to_keep = [x for x in range(len(header)) if not x in pos_to_remove]
            print('header OK')
            print(f"going from {len(header)} to {len(pos_to_keep)} columns.")
            sl = l.decode().strip().split('\t')
            
            towrite = '\t'.join( [sl[i] for i in pos_to_keep] ) + '\n'
            OUT.write(towrite.encode())          

        else:
            if pos_to_remove is None:
                print("!!ERROR!! no header found")
                break
            sl = l.decode().strip().split('\t')
            towrite = '\t'.join( [sl[i] for i in pos_to_keep] ) + '\n'
            OUT.write(towrite.encode())          
            

print("finished writing to", output_vcfgz )