set terminal svg size 800,600 enhanced font 'Arial,20'
set output "bars.svg"

#set style histogram columnstacked
#set style data histogram
set style fill solid 0.5 noborder
set key left

set datafile separator ','

#set style histogram clustered gap 1 title textcolor lt -1
set style data histograms

set yrange [0:400]

set ylabel "Time (s)"

set boxwidth 0.95
#set style fill solid

plot "bars.dat" using 2:xtic(1) lt rgb "#406090" title "Postgres (cold)", \
     "" using 3:xtic(1) lt rgb "#107d10" title "Vmprobe", \
     "" using 4 lt rgb "#903070" title "Postgres (hot)"
