# Todo App — Projeto Avaliativo Final (M02-S07)
Vídeo: https://drive.google.com/file/d/1-_uEHDtKlrV0z2L5OSVuB7Qn3An7qWb1/view?usp=drive_link
Link Github: https://github.com/amandaespindulamachado/FlutterMiniProj02-AmandaEspindulaMachado


Aplicativo Flutter de gerenciamento de tarefas que demonstra o ciclo completo de uma aplicação mobile moderna: consumo de API REST, persistência local com SQLite, autenticação com SharedPreferences e arquitetura MVVM.

---

## Funcionalidades

| RF   | Descrição                                                                 | Status |
|------|---------------------------------------------------------------------------|--------|
| RF01 | Splash Screen com verificação de sessão via SharedPreferences             | ✅     |
| RF02 | Tela de Login com validação de campos e toggle de senha                   | ✅     |
| RF03 | Login via API com SnackBar de erro e salvamento de dados no SharedPrefs   | ✅     |
| RF04 | Carregamento de TODOs via API → salvo no SQLite → exibido via SELECT      | ✅     |
| RF05 | Home com nome do usuário, lista, filtros por status e busca por texto     | ✅     |
| RF06 | Tarefas concluídas com opacidade reduzida e texto riscado                 | ✅     |
| RF07 | Checkbox para completar tarefa pendente, atualizado no SQLite em tempo real| ✅    |

---

## Arquitetura — MVVM

```
mini_projeto_avaliativo_todos/
├── main.dart                         # Ponto de entrada, MultiProvider, rotas
├── README.md
└── lib/
    ├── core/
    │   ├── app_routes.dart           # Constantes de rotas nomeadas
    │   ├── errors/
    │   │   └── app_error.dart        # Hierarquia sealed de erros
    │   └── result/
    │       └── result.dart           # Padrão Result<S,E> com Success/Failure
    ├── data/
    │   ├── models/
    │   │   ├── user_model.dart       # Entidade usuário (fromJson, fullName)
    │   │   └── todo_model.dart       # Entidade tarefa (fromJson, toMap, copyWith)
    │   ├── datasources/
    │   │   ├── auth_remote_datasource.dart    # POST /auth/login
    │   │   ├── todo_remote_datasource.dart    # GET /todos
    │   │   └── todo_local_datasource.dart     # SQLite CRUD
    │   └── repositories/
    │       ├── auth_repository.dart           # Abstração + implementação
    │       └── todo_repository.dart           # fetch API → salva SQLite → SELECT
    ├── services/
    │   ├── auth_service.dart         # Orquestra login + SharedPreferences
    │   ├── todo_service.dart         # loadTodos, completeTodo, filterTodos
    │   └── prefs_service.dart        # SharedPreferences (firstName, lastName, token)
    └── view/
        ├── viewModel/
        │   ├── auth_view_model.dart  # ChangeNotifier: login, logout, isLoggedIn
        │   └── todo_view_model.dart  # ChangeNotifier: loadTodos, completeTodo, filtros
        └── screens/
            ├── splash_screen.dart    # Animação + verificação de sessão
            ├── login_screen.dart     # Form com validação e toggle de senha
            └── home_screen.dart      # Lista, filtros, contadores, checkbox
```

---

## Tecnologias e Pacotes

| Pacote               | Versão   | Uso                              |
|----------------------|----------|----------------------------------|
| `provider`           | ^6.1.2   | Gerência de estado (MVVM)        |
| `http`               | ^1.2.2   | Requisições HTTP à API           |
| `sqflite`            | ^2.3.3+1 | Banco de dados SQLite local      |
| `path`               | ^1.9.0   | Manipulação de caminhos (SQLite) |
| `shared_preferences` | ^2.3.2   | Persistência de sessão           |

---

## Como Executar

### Pré-requisitos
- Flutter SDK 3.x instalado
- Dispositivo físico ou emulador Android/iOS

### Passos

```bash
# Clone o repositório
git clone <url-do-repositorio>

# Entre na pasta do projeto
cd mini_projeto_avaliativo_todos

# Instale as dependências
flutter pub get

# Execute o projeto
flutter run
```

### Credenciais de teste

A API `dummymyjson.com` aceita usuários de sua base pública. Para testar use:

```
Usuário: emilys
Senha:   emilyspass
```

---

## Fluxo da Aplicação

```
Inicialização
    └── SplashScreen
           ├── SharedPreferences.token existe? → HomeScreen
           └── Não → LoginScreen
                        └── Login bem-sucedido
                                 ├── Salva firstName, lastName, token
                                 └── HomeScreen
                                          ├── API GET /todos
                                          ├── Salva no SQLite (batch insert)
                                          ├── SELECT no SQLite → exibe lista
                                          ├── Filtro: Todos / Pendentes / Concluídas
                                          ├── Busca por texto
                                          └── Checkbox → UPDATE SQLite → atualiza UI
```

---

## Padrões Técnicos

- **Padrão Result**: `sealed class Result<S, E>` com `Success` e `Failure` — elimina `try/catch` nas camadas superiores.
- **Sealed classes de erro**: `AppError` com subtipos `AuthError`, `InvalidCredentialsError`, `NetworkError`, `DatabaseError`, `UnknownError`.
- **Abstrações (interfaces)**: todas as camadas expõem `abstract interface class I...` permitindo inversão de dependência e testabilidade.
- **Dart 3 pattern matching**: `switch (result) { case Success(:final value): ... case Failure(:final error): ... }` para exaustividade em tempo de compilação.
- **SQLite**: `insertOrReplace` via batch para sincronização; `updateCompleted` para persistir checkbox sem nova chamada à API.
- **Operador ternário**: usado extensivamente na UI para status visual das tarefas.
- **Operadores lógicos compostos**: validações no `filterTodos` com `&&` e `||`.
- **Iteração com `.map()` e `.where()`**: conversão JSON → List<TodoModel> e filtragem de listas.

---

## API Utilizada

- **Base URL**: `https://dummymyjson.com`
- **Login**: `POST /auth/login` — retorna `accessToken`, `firstName`, `lastName`
- **Tarefas**: `GET /todos?limit=100` — retorna lista de objetos `{ id, todo, completed, userId }`

---

*Desenvolvido como Projeto Avaliativo Final — Módulo 02, Semana 07 — LAB365*
