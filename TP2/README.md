# Trabalho Prático de GAWK
## MIEI - Processamento de Linguagens - Universidade do Minho (2018/2019)

Para correr o script *gawk*, sugere-se o uso do seguinte comando:
`gawk -f superProcessador.awk < emigra.csv`

Para que o resultado de correr a script seja guardado num documento,
sugere-se o uso do seguinte comando:
`gawk -f superProcessador.awk < emigra.csv > output.txt`

Para gerar o grafo em dot, usar o comando:
`dot -Tpng graph.dot -o graph.png`
