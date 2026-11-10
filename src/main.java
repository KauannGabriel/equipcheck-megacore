import java.util.Scanner;

public class main {
    public static void Main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        boolean rodando = true;

        System.out.println("========================================");
        System.out.println("        EQUIPCHECK MINI - MEGACORE      ");
        System.out.println("========================================");

        while (rodando) {
            System.out.println("\nSelecione uma opção:");
            System.out.println("1. Registar Nova Inspeção (RF02/RF03)");
            System.out.println("2. Consultar Equipamentos");
            System.out.println("3. Sair");
            System.out.print("Opção: ");

            int opcao = -1;
            try {
                opcao = Integer.parseInt(scanner.nextLine());
            } catch (NumberFormatException e) {
                System.out.println(" Por favor, digite um número válido.");
                continue;
            }

            switch (opcao) {
                case 1:
                    registarInspecao(scanner);
                    break;
                case 2:
                    System.out.println("Funcionalidade de consulta em desenvolvimento...");
                    break;
                case 3:
                    System.out.println("A encerrar o sistema. Até logo!");
                    rodando = false;
                    break;
                default:
                    System.out.println("Opção inválida! Tente novamente.");
            }
        }
        scanner.close();
    }

    public static void registarInspecao(Scanner scanner) {
        System.out.print("Digite o ID do Equipamento (ex: EQP-001): ");
        String idEquipamento = scanner.nextLine();

        System.out.print("Digite o valor da medição numérica (entre 10 e 20): ");
        double medicao = 0.0;
        
        try {
            medicao = Double.parseDouble(scanner.nextLine());
        } catch (NumberFormatException e) {
            System.out.println(" Valor de medição inválido.");
            return;
        }

        if (medicao >= 10.0 && medicao <= 20.0) {
            System.out.println("Status: APTO. Medição dentro dos parâmetros aceitáveis.");
        } else {
            System.out.println(" Status: BLOQUEADO. Medição fora do intervalo (10 a 20).");
            System.out.print("Justificativa obrigatória para bloqueio: ");
            String justificativa = scanner.nextLine();
            
            if (justificativa.trim().isEmpty()) {
                System.out.println("Alerta: A justificativa não pode estar vazia para equipamentos bloqueados!");
            } else {
                System.out.println("Registo gravado com a justificativa: '" + justificativa + "'");
            }
        }
    }
}