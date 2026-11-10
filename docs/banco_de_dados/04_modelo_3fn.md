# Modelo Relacional Lógico e Justificativa de Normalização (3FN)
**Projeto:** EquipCheck Mini (MegaCore Labs)

## 1. Esquema Relacional (Lógico)
A estrutura lógica do banco de dados mapeia as entidades para o modelo relacional com tipos de dados e chaves:

* **EQUIPAMENTO** (**id_equipamento** [PK, VARCHAR], versao_firmware [VARCHAR], versao_software [VARCHAR])
* **RESPONSAVEL** (**id_responsavel** [PK, INT], nome [VARCHAR])
* **INSPECAO** (**id_inspecao** [PK, INT], medicao [DECIMAL], status [VARCHAR], justificativa [TEXT], data_hora [TIMESTAMP], *id_equipamento* [FK, VARCHAR], *id_responsavel* [FK, INT])

## 2. Justificativa de Normalização

### 1ª Forma Normal (1FN)
* **Atributos Atômicos:** Todos os atributos armazenam valores indivisíveis (ex.: medicao, status, data_hora).
* **Ausência de Grupos Repetitivos:** Não existem colunas multivaloradas ou tabelas aninhadas.

### 2ª Forma Normal (2FN)
* **Atendida a 1FN.**
* **Dependência Funcional Total:** As chaves primárias são simples (`id_equipamento`, `id_responsavel`, `id_inspecao`). Todos os atributos não-chave dependem integralmente da totalidade da sua respetiva Chave Primária.

### 3ª Forma Normal (3FN)
* **Atendida a 2FN.**
* **Ausência de Dependências Transitivas:** Nenhum atributo não-chave depende de outro atributo não-chave. 
  * Os dados do responsável (como o `nome`) e as versões do equipamento não são duplicados na tabela de inspeção; a ligação é feita estritamente através das Chaves Estrangeiras (`id_equipamento` e `id_responsavel`).