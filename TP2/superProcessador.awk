BEGIN {
      FS=";"
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



END{for (freg in freguesia) print "A freguesia " freg " tem " freguesia[freg] " pedidos.";
    for (conc in concelho) print "O Concelho " conc " tem " concelho[conc] " pedidos.";
    for (date in dados) for(con in dados[date]) print "Para o ano de "date" , houve " dados[date][con] " pedido no concelho de " con ".";
    for (n in nome) print "O nome " n " tem " nome[n] " ocorrencias."
    print "Número total de linhas " NR ;
    print "CONTA = " conta}
