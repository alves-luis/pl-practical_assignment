BEGIN {FS = ";"; RS = "\n"}
NR > 2 && $1 ~/.+/ && $3 ~/.+/ && $4 ~/.+/ && $2 ~/.+/ {
        print "obra {\n  nome: \"" $3 "\",\n  data: " $1 ",\n  genero: \"" $4 "\",\n  duracao: " $2 "\n}\n"
       }
END {}
