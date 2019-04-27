BEGIN {
      FS=";"
      print "digraph G {\n rankdir=LR\n" > "graph.dot"
      }


NR>2 {freguesia[$4]++ ; concelho[$5]++;
      split($6,data,"[-/.]"); dados[data[1]][$5]++}
NR>2 {

      lookOn[0]=$2
      lookOn[1]=$7
      lookOn[2]=$9
      lookOn[3]=$11
      for(j=0;j<4;j++){
        n=split(lookOn[j],name," ");
        for(i=0;i<n;i++){
          if(name[i] ~ /[A-Z][^A-Z]+/){
            nome[name[i]]++;
            conta++;
          }
        }
      }
    }

NR>2 { req=$2; pai=$7; mae=$9; conj= $11;
       if(req!=""){
         if(pai!=""){
           print "edge [color=blue];" >> "graph.dot"
           print " \" " req " \" " " -> " " \" " pai " \" " ";" >> "graph.dot";
         }
         if(mae!=""){
           print "edge [color=red];" >> "graph.dot"
           print " \" " req " \" " " -> " " \" " mae " \" " ";" >> "graph.dot";
         }
         if(conj!=""){
           print "edge [color=black];" >> "graph.dot"
           print " \" " req " \" " " -> " " \" " conj " \" " " [style=dotted];" >> "graph.dot";
         }
      }
    }


END{for (freg in freguesia) print "A freguesia " freg " tem " freguesia[freg] " pedidos.";
    for (conc in concelho) print "O Concelho " conc " tem " concelho[conc] " pedidos.";
    for (date in dados) for(con in dados[date]) print "Para o ano de "date" , houve " dados[date][con] " pedido no concelho de " con ".";
    for (n in nome) print "O nome " n " tem " nome[n] " ocorrencias."
    print "Número total de linhas " NR ;
    print "CONTA = " conta;
    print "}" >> "graph.dot"}
