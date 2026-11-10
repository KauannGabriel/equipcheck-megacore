CREATE DATABASE IF NOT EXISTS equipcheck_db;
USE equipcheck_db;

CREATE TABLE responsavel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE equipamento (
    id_equipamento VARCHAR(50) PRIMARY KEY,
    versao_firmware VARCHAR(20) NOT NULL,
    versao_software VARCHAR(20) NOT NULL
);

CREATE TABLE inspecao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_equipamento VARCHAR(50) NOT NULL,
    responsavel_id INT NOT NULL,
    medicao DECIMAL(5,2) NOT NULL CHECK (medicao BETWEEN 10.00 AND 20.00),
    status VARCHAR(20) NOT NULL,
    justificativa TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_equipamento) REFERENCES equipamento(id_equipamento),
    FOREIGN KEY (responsavel_id) REFERENCES responsavel(id)
);