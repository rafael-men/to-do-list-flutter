## ToDo App

Este é um aplicativo de lista de tarefas simples e intuitivo, desenvolvido em Flutter, que utiliza o **Sembast** para o armazenamento local de dados. Ideal para quem precisa organizar as atividades diárias de forma eficiente, o aplicativo permite adicionar, editar e excluir tarefas facilmente.

### Funcionalidades

  * **Adicionar tarefas:** Crie novas tarefas com descrições.
  * **Marcar como concluída:** Altere o status de uma tarefa para 'concluída'.
  * **Editar tarefas:** Modifique a descrição de tarefas existentes.
  * **Excluir tarefas:** Remova tarefas que não são mais necessárias.
  * **Armazenamento persistente:** As tarefas são salvas localmente usando o Sembast, garantindo que os dados não sejam perdidos ao fechar o aplicativo.

-----

### Tecnologias

  * **Flutter:** Framework para o desenvolvimento do aplicativo.
  * **Sembast:** Banco de dados NoSQL embarcado para Dart, usado para persistir os dados da lista de tarefas de forma assíncrona e segura.
  * **Provider:** Gerenciamento de estado para atualizar a interface do usuário de forma reativa.

-----

### Como Rodar o Projeto

Para executar este projeto em seu ambiente de desenvolvimento, siga os passos abaixo:

1.  **Clone o repositório:**

    ```bash
    git clone https://github.com/rafael-men/to-do-list-flutter.git
    ```

2.  **Navegue até o diretório do projeto:**

    ```bash
    cd to-do-list-flutter
    ```

3.  **Instale as dependências:**

    ```bash
    flutter pub get
    ```

4.  **Execute o aplicativo:**

    ```bash
    flutter run
    2
    ```

Certifique-se de ter o Flutter SDK instalado e configurado corretamente.

-----

### Estrutura do Projeto

  * **`lib/`**: Contém o código-fonte principal da aplicação.
      * **`main.dart`**: Ponto de entrada do aplicativo.
      * **`models/`**: Definições dos modelos de dados (ex: `task.dart`).
      * **`services/`**: Lógica de interação com o Sembast (ex: `database_service.dart`).
      * **`widgets/`**: Componentes reutilizáveis da interface do usuário.
-----

### Contribuição

Contribuições são bem-vindas\! Se você encontrar um bug ou tiver uma ideia para uma nova funcionalidade, sinta-se à vontade para abrir uma *issue* ou enviar um *pull request*.

1.  Faça um *fork* do projeto.
2.  Crie uma nova *branch* (`git checkout -b feature/nova-funcionalidade`).
3.  Faça suas alterações e *commite-as* (`git commit -m 'Adiciona nova funcionalidade'`).
4.  Envie suas alterações para a sua *branch* (`git push origin feature/nova-funcionalidade`).
5.  Abra um *pull request*.

-----
