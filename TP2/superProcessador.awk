BEGIN {
      FS=";"
      print "digraph G {\n rankdir=LR\n" > "graph.dot"
      }
# contar o número de processos registados por Concelho e Freguesia.
# calcular a frequência de processos por ano e relacionar com os concelhos
NR > 2 && $1 ~ /.+/ {
        freguesia[$4]++ ;
        concelho[$5]++;
        split($6,data,"[-/.]");
        # Adiciona a uma matriz de ano/concelho,
        # o número de pedidos no concelho nesse ano
        dados[data[1]][$5]++
     }

# estudar a ocorrência de nomes próprios
# (não considere só os requerentes, mas considere também seus
# parentes).
NR > 2 && $1 ~ /.+/ {

      # nome do requerente
      lookOn[0]=$2
      # nome do pai
      lookOn[1]=$7
      # nome da mãe
      lookOn[2]=$9
      # nome do conjuge
      lookOn[3]=$11

      for(j = 0; j < 4; j++){
        # n = número de nomes próprios em cada nome
        n = split(lookOn[j],name," ");
        # para cada nome próprio, adiciona a contagem a uma hash de nomes
        # próprios
        for(i = 0; i < n; i++) {
          if(name[i] ~ /[A-Z][^A-Z]+/){
            nome[name[i]]++;
            numNomesProprios++;
          }
        }
      }
    }

NR > 2 && $1 ~ /.+/ {
         req=$2;
         pai=$7;
         mae=$9;
         conj= $11;
         # se houver pai
         if(pai != ""){
             print "edge [color=blue];\n" >> "graph.dot"
             print " \" " req " \" " " -> " " \" " pai " \" " ";\n" >> "graph.dot";
         }
         # se houver mãe
         if(mae != ""){
             print "edge [color=red];\n" >> "graph.dot"
             print " \" " req " \" " " -> " " \" " mae " \" " ";\n" >> "graph.dot";
         }
         # se houver conjuge
         if(conj != ""){
             print "edge [color=black];\n" >> "graph.dot"
             print " \" " req " \" " " -> " " \" " conj " \" " " [style=dotted];\n" >> "graph.dot";
         }
    }


END {
    # imprimir o nº de pedidos por freguesia
    for (freg in freguesia) print "A freguesia " freg " tem " freguesia[freg] " pedidos.";

    # guardar as estatísticas da freguesia em csv
    print "Freguesia, Pedidos" > "freguesias.csv";
    for (freg in freguesia) print freg "," freguesia[freg] >> "freguesias.csv";

    # imprimir o nº de pedidos por concelho
    for (conc in concelho) print "O Concelho " conc " tem " concelho[conc] " pedidos.";

    # guardar as estatísticas do concelho em csv
    print "Concelho, Pedidos" > "concelhos.csv";
    for (conc in concelho) print conc "," concelho[conc] >> "concelhos.csv";

    # imprimir o nº de pedidos por ano e concelho
    for (date in dados) for(con in dados[date]) print "Para o ano de "date", houve " dados[date][con] " pedido no concelho de " con ".";

    # Guardar estatísticas de cima em csv
    header = "Ano";
    for(conc in concelho) header = header ", " conc;
    print header > "anos.csv";
    for (date in dados) {
        row = date ","
        for(conc in concelho) {
            row = row dados[date][conc] ","
        }
        print row >> "anos.csv"
    }

    # imprimir o nº de ocorrências de cada nome próprio
    for (n in nome) print "O nome " n " tem " nome[n] " ocorrencias."

    # guardar estatísticas de nome próprio em csv
    print "Nome, Ocorrências" > "nomes.csv"
    for (n in nome) print n "," nome[n] >> "nomes.csv"

    # imprimir nº total de nomes próprios (incluindo repetidos)
    print "Nº total de nomes próprios = " numNomesProprios;

    # finalizar ficheiro .dot
    print "}" >> "graph.dot"}
