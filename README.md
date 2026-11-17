EquipCheck Mini

Banco de dados e aplicação de apoio ao registro de equipamentos e inspeções da MegaCore Labs, permitindo acompanhar a condição de liberação de cada equipamento, as versões de firmware e software associadas e o histórico das verificações e mudanças.

Trabalho A3 integrado — Bancos de Dados e Garantia da Qualidade de Software · UNA Betim · Cenário 5 MegaCore Labs

Bancos de Dados: documentação, diagramas, scripts SQL, vídeo pitch.
Garantia da Qualidade de Software: diagnóstico, AS-IS, app, testes, TO-BE, melhorias.
Equipe
Integrantes:
Kauan Gabriel,
Rafaela Oliveira,
Eric Braga,
Thays Durães,
Lucas 

Vídeo pitch



Contexto

A MegaCore Labs, de Campinas, desenvolve software embarcado e aplicações de configuração para equipamentos médicos e industriais. Firmware e aplicativo são produzidos por equipes diferentes e, em um teste interno, uma combinação de versões mostrou um equipamento como apto apesar de existir uma condição de bloqueio. O EquipCheck Mini registra inspeções com rastreabilidade, preservando os controles necessários e a possibilidade de reconstruir o histórico de uma liberação.

Requisitos funcionais
ID	Requisito
RF01	Cadastrar equipamento com identificador único e versões de firmware e software obrigatórias.
RF02	Registrar uma medição numérica em inspeção, usando a faixa didática de 10 a 20, incluindo os extremos.
RF03	Classificar como Bloqueado se a medição estiver fora da faixa; dentro dela, classificar como Apto.
RF04	Permitir que um equipamento Bloqueado volte a Apto somente após nova inspeção aprovada.
RF05	Exigir responsável e justificativa para alteração de versão ou de dados da inspeção.
RF06	Preservar o histórico de inspeções e mudanças, incluindo as versões de firmware e software associadas a cada registro.
Documentação
Entregável	Arquivo
Escopo do projeto	docs/escopo.md
Lista de funcionalidades	docs/funcionalidades.md
Levantamento de requisitos	docs/requisitos.md
Diagrama de caso de uso	docs/caso-de-uso.md
DER conceitual	docs/der.md
Modelo relacional em 3FN	docs/modelo-relacional.md
Normalização e justificativas	docs/normalizacao.md
Dicionário de dados (bônus)	docs/dicionario-de-dados.md
Plano de desenvolvimento	ROADMAP.md
Garantia da Qualidade de Software
Etapa	Entregável	Arquivo
1	Diagnóstico e problemas prioritários	qualidade/01-diagnostico.md
1	AS-IS em BPMN	qualidade/02-as-is.md
1	Maturidade e relação com MPS.BR e CMMI	qualidade/03-maturidade.md
1	Requisitos com critérios de aceite	docs/requisitos.md
2	Plano de testes, riscos e casos de teste	qualidade/04-plano-de-testes.md
2	Defeitos controlados, TDD e CI	qualidade/05-defeitos-tdd-ci.md
2 e 3	Rastreabilidade requisito, risco, teste, defeito e melhoria	qualidade/06-rastreabilidade.md
3	TO-BE, melhorias, maturidade comparada e indicadores	qualidade/07-to-be-e-melhorias.md

Os arquivos em qualidade/ são a base dos relatórios; as colunas marcadas como "a preencher" dependem das execuções do grupo.

Como executar o banco

Requer MySQL 8.0.16 ou superior (necessário para CHECK constraints aplicadas). Execute os scripts em ordem:

bash
mysql -u root -p < sql/01-create-database.sql
mysql -u root -p < sql/02-create-tables.sql
mysql -u root -p < sql/03-triggers-views.sql
mysql -u root -p < sql/04-inserts.sql
mysql -u root -p < sql/05-queries.sql

No MySQL Workbench, abra cada arquivo e execute o script inteiro, na mesma ordem.

Script	Conteúdo
01-create-database.sql	Criação do banco equipcheck
02-create-tables.sql	Tabelas, chaves primárias e estrangeiras, CHECK
03-triggers-views.sql	Triggers (RF04, RF05, RF06) e view de status atual
04-inserts.sql	Dados de exemplo (5 equipamentos, inspeções, correções e mudanças de versão)
05-queries.sql	12 consultas de demonstração e testes das regras
Modelo de dados
Tabela	Função
equipamento	Equipamento (EQP-001), versões atuais e status (Apto/Bloqueado)
inspecao	Medição, classificação automática, aprovação, responsável e versões vigentes na data
historico_equipamento	Toda mudança de versão, com responsável e justificativa
historico_inspecao	Toda correção de dados de inspeção, com responsável e justificativa
v_status_atual_equipamento (view)	Situação atual de cada equipamento com a última inspeção

Diagramas: docs/caso-de-uso.png, docs/der.png e docs/modelo-relacional.png.

Tecnologias
Banco de dados: MySQL 8.0.16+
Back-end: JavaScript (Node.js), necessário para Garantia da Qualidade (regras testáveis, TDD, testes automatizados e CI)
Interface: React (opcional; a avaliação aceita interface simples ou terminal)
Estrutura do repositório
.
├── README.md
├── ROADMAP.md
├── docs/
│   ├── escopo.md, funcionalidades.md, requisitos.md
│   ├── caso-de-uso.md, der.md, modelo-relacional.md
│   ├── normalizacao.md, dicionario-de-dados.md
│   ├── caso-de-uso.png, der.png, modelo-relacional.png
│   └── diagramas/        # fontes dos diagramas (Graphviz)
├── qualidade/            # Garantia da Qualidade: diagnóstico, AS-IS, maturidade, testes, TO-BE
│   ├── 01 a 07 (.md), as-is-bpmn.png
│   └── diagramas/        # gerador do diagrama AS-IS
├── sql/                  # scripts 01 a 05
├── video/                # link e roteiro do pitch
├── backend/              # regras de negócio em JavaScript, testes e API
├── frontend/             # interface React (opcional)
└── .github/workflows/    # CI (GitHub Actions)