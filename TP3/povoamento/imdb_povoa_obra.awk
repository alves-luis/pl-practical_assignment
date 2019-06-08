BEGIN {FS = "\t"; RS = "\n"}
NR > 1 && $2 ~/movie/ && $3 !~ /\\N/ && $6 !~ /\\N/ && $9 !~ /\\N/ && $8 !~ /\\N/ {
        split($9,genero,",");
        sub(/tt/,"o",$1);
        printf "obra {\n  id: %s,\n  nome: \"%s\",\n  data:  %s,\n  genero: \"%s\",\n  duracao: %s\n}\n", $1, $3, $6, genero[1], $8
       }
END {}
