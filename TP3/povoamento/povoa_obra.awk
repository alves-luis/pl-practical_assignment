BEGIN {FS = ";"; RS = "\n"}
NR > 2 && $1 !~ /\\N/ && $3 !~ /\\N/ && $4 !~ /\\N/ && $2 !~ /\\N/ {
        print "obra {\n  id: o" NR ",\n  nome: \"" $3 "\",\n  data: " $1 ",\n  genero: \"" $4 "\",\n  duracao: " $2 "\n}\n"
       }
END {}
