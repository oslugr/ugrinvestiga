T="$(date +%s%N)"

./ugrinvestiga.pl listado.dat ranking.csv

T="$(($(date +%s%N)-T))"
S="$((T/1000000000))"
M="$((T/1000000))"

printf "Tiempo: %02d:%02d:%02d:%02d.%03d\n" "$((S/86400))" "$((S/3600%24))" "$((S/60%60))" "$((S%60))" "${M}"
