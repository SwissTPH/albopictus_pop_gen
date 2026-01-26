import gzip
import sys



INfile = sys.argv[1]
OUTfile = sys.argv[2]

SEP = '@'
if len(sys.argv)>3:
    SEP = sys.argv[3]


if not INfile.endswith('.vcf.gz'):
    print('ERROR: expected a .vcf.gz file as input (got',INfile,')')
    exit(1)
if not OUTfile.endswith('.vcf.gz'):
    print('ERROR: expected a .vcf.gz file as output (got',OUTfile,')')
    exit(1)



## reading population info 

pop_info_file = "/scicore/home/muellepi/GROUP/albopictus/info/albo_global_pops_UNSD.txt"

ind_2_native_invaded = {}

with open( pop_info_file ) as IN:
    for l in IN:
        sl = l.strip().split()
        ind_2_native_invaded[ sl[0] ] = sl[2]


## reading vcf
with gzip.open( INfile , 'rt') as IN:
    content = IN.read()

lines = content.split('\n')
del content

## get header line number
header_num = None
for i,l in enumerate( lines ):
    if not l.startswith('##'):
        header_num = i
        break

header = lines[header_num].split('\t')
ids = header[9:]

desplit = lambda x : x[:len(x)//2]
makeid = lambda x :  ind_2_native_invaded[x] + '@' + x
new_ids = list(map( makeid , map(desplit , ids ) ) )

new_header = header[:9] + new_ids
lines[header_num] = '\t'.join(new_header)

new_content = '\n'.join( lines )
del lines

with gzip.open( OUTfile , 'wt' ) as OUT:
    OUT.write( new_content )
