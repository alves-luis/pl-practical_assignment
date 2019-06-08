BEGIN {FS = "\t"; RS = "\n"}
NR > 1 && $1 !~ /\\N/ && $3 !~ /\\N/ && $2 !~ /\\N/ && $6 ~! /\\N/ {
        sub(/nm/,"a",$1);
        idade = (2019 - $3);
        printf "artista {\n  id: %s,\n  nome: \"%s\",\n  idade:  %d\n}\n", $1, $2, idade
        split($6,titulos,",");
        for(tit in titulos) {
            sub(/tt/,"t",titulos[tit]);
            printf "%s produziu %s.\n", $1, titulos[tit];
        }
       }
END {}
