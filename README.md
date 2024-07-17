# Amazon Sales 
  
  Neste projeto, foram utilizadas as ferramentas BigQuery, Google Colab e Power BI e a aplicação de testes para validação de hipóteses sobre uma base de dados da Amazon.

<details>
  <summary><strong style="font-size: 16px;">Objetivo</strong></summary>
  
Identificar e compreender os principais fatores que influenciam a pontuação e a classificação dos produtos na plataforma da Amazon. Assim, foram levantadas as seguintes hipóteses:


- **_Hipótese 1_:** Produtos com maior desconto aplicado (discount_percentage) são melhor classificados (rating);
- **_Hipótese 2_:** Produtos com mais avaliações positivas (score_sentimento) são melhor classificados (rating);
- **_Hipótese 3_:** Produtos com mais avaliações (rating_count) são melhor classificados (rating).
</details>

<details>
  <summary><strong style="font-size: 16px;">Equipe</strong></summary>
  
  - Nicole Machado Corrêa
  - Lays Silva
</details>

<details>
  <summary><strong style="font-size: 16px;">Ferramentas e Tecnologias</strong></summary>
  
  - BigQuery
  - Google Colab
  - Power BI
  - Python
 
</details>

<details>
 <summary><strong style="font-size: 16px;">Processo e Técnicas de Análise</strong></summary>

- ETL (Extract, Transform, Load): tratamento e limpeza de nulos, duplicados, dados fora do alcance da análise, criação de novas variáveis, o cálculo de quartis e segmentação. Também se realizou a conversão de variáveis categóricas em dummy.

- Processamento de Linguagem Natural (PLN): criação de um score de sentimento para a variável review_content, para análise de sentimentos em textos. Implementada através da biblioteca NLTK (Natural Language Toolkit);

- Modelagem Estatística: Teste de Shapiro-Wilk para verificar a normalidade dos dados, correlação de Spearman, Teste de Significância (Mann-Whitney) e Regressão linear e logística.
 
- Visualização de Dados: através de dashboard interativo no Power BI..
  
</details>


<details>
<summary><strong style="font-size: 16px;">Resultados e Conclusões</strong></summary>

  Com base na análise exploratória dos dados, chegou-se as seguintes conclusões:

- **_Hipótese 1_:** os resultados mostraram uma correlação significativa, mas negativa, entre o percentual de desconto aplicado e a classificação dos produtos.

- **_Hipótese 2_:**   há uma correlação positiva moderada e significativa entre score_sentimento e rating. Isso sugere que produtos com mais avaliações positivas tendem a ter classificações melhores, porém outros fatores também podem estar influenciando a classificação.

- **_Hipótese 3_:** os resultados evidenciaram uma correlação significativa, positiva e moderada entre a quantidade de avaliações e a classificação dos produtos.


</details>

<details>
<summary><strong style="font-size: 16px;">Recomendações</strong></summary>

 
- Talvez descontos muito altos possam afetar a percepção de qualidade dos produtos pelos clientes, então testar diferentes níveis de desconto e monitorar como isso influencia as avaliações possa ser uma boa estratégia;

- Reforçar estratégias para incentivar e promover avaliações positivas dos clientes (melhorias na experiência do cliente, suporte pós-venda, etc);

- Criar incentivos para avaliações, pedidos claros de feedback após a compra e um processo fácil e acessível para deixar avaliações;

Uso da análise de sentimento para identificar padrões nas avaliações, para identificação da satisfação dos clientes e gerar pontos de melhoria.
