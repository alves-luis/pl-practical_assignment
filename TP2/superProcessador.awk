BEGIN {
      FS=";"
      print "digraph G {\n rankdir=LR\n" > "graph.dot"
      }
# contar o número de processos registados por Concelho e Freguesia.
# calcular a frequência de processos por ano e relacionar com os concelhos
NR > 2 {
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
NR > 2 {

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

NR > 2 && $2 ~ /.+/ {
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
    for (freg in freguesia) print "A freguesia " freg " tem " freguesia[freg] " pedidos.";
    for (conc in concelho) print "O Concelho " conc " tem " concelho[conc] " pedidos.";
    for (date in dados) for(con in dados[date]) print "Para o ano de "date", houve " dados[date][con] " pedido no concelho de " con ".";
    for (n in nome) print "O nome " n " tem " nome[n] " ocorrencias."
    print "Nº total de nomes próprios = " numNomesProprios;
    print "}" >> "graph.dot"}
