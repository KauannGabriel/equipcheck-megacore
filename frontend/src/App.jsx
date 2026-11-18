import { useState } from "react";
import "./App.css";

function AddEquipment() {
    const [form, setForm] = useState({
        idEquipamento: "",
        versaoFirmware: "",
        versaoSoftware: "",
    });
    const [erro, setErro] = useState(null);
    const [sucesso, setSucesso] = useState(null);
    const [enviando, setEnviando] = useState(false);

    function handleChange(e) {
        const { name, value } = e.target;

        setSucesso(null);
        setForm((atual) => ({
            ...atual,
            [name]: name === "idEquipamento" ? value.toUpperCase() : value,
        }));
    }

    async function handleSubmit(e) {
        e.preventDefault();
        setErro(null);
        setSucesso(null);
        setEnviando(true);

        try {
            const res = await fetch("/api/equipamentos", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(form),
            });

            const dados = await res.json().catch(() => ({}));

            if (!res.ok) {
                setErro(dados.erro || `Erro ${res.status}`);
                return;
            }

            setSucesso(`Equipamento ${form.idEquipamento} cadastrado.`);
            setForm({ idEquipamento: "", versaoFirmware: "", versaoSoftware: "" });
        } catch {
            setErro("Não foi possível falar com o servidor.");
        } finally {
            setEnviando(false);
        }
    }

    return (
        <div className="add-equipment">
            <h2>Adicionar Equipamento</h2>

            <form onSubmit={handleSubmit}>
                <label htmlFor="idEquipamento">ID do Equipamento</label>
                <input
                    id="idEquipamento"
                    name="idEquipamento"
                    type="text"
                    placeholder="Ex.: EQP-001"
                    pattern="EQP-\d{3}"
                    title="Use o formato EQP-001 (EQP, hífen e 3 dígitos)"
                    value={form.idEquipamento}
                    onChange={handleChange}
                    required
                />

                <label htmlFor="versaoFirmware">Versão do Firmware</label>
                <input
                    id="versaoFirmware"
                    name="versaoFirmware"
                    type="text"
                    placeholder="Ex.: 1.0.0"
                    value={form.versaoFirmware}
                    onChange={handleChange}
                    required
                />

                <label htmlFor="versaoSoftware">Versão do Software</label>
                <input
                    id="versaoSoftware"
                    name="versaoSoftware"
                    type="text"
                    placeholder="Ex.: 2.0.0"
                    value={form.versaoSoftware}
                    onChange={handleChange}
                    required
                />

                <button type="submit" disabled={enviando}>
                    {enviando ? "Enviando..." : "Adicionar"}
                </button>

                {erro && (
                    <p className="erro" role="alert">
                        {erro}
                    </p>
                )}
                {sucesso && <p className="sucesso">{sucesso}</p>}
            </form>
        </div>
    );
}

export default function App() {
    return (
        <div className="app">
            <h1>Bem-vindo ao EquipCheck</h1>
            <AddEquipment />
        </div>
    );
}