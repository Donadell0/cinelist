# 🎬 CineList

Um aplicativo de gerenciamento pessoal de filmes, inspirado no Letterboxd. Desenvolvido como projeto final avaliativo da disciplina de Desenvolvimento de Sistemas Móveis (UNIFEOB).

O **CineList** permite aos usuários buscar filmes atualizados através de uma API pública e organizá-los em listas locais ("Quero Assistir" e "Já Assisti"), além de possibilitar a avaliação com estrelas dos títulos finalizados.

---

## 🎯 Requisitos da Atividade Cumpridos

Este projeto atende a todos os critérios estabelecidos para a Atividade Avaliativa Final:
- [x] **Ferramenta Flutter:** App totalmente desenvolvido em Flutter/Dart.
- [x] **Consumo de API (Leitura):** Integração com a OMDb API para buscar filmes em tempo real.
- [x] **Banco de Dados Local (Inserção e Leitura):** Uso do `sqflite` para persistir as listas e avaliações do usuário no dispositivo.
- [x] **Vídeo de Apresentação:** Pitch e demonstração do funcionamento (Link abaixo).
- [x] **Hospedagem no GitHub:** Repositório com código-fonte organizado.

🎥 **[CLIQUE AQUI PARA ASSISTIR AO VÍDEO DE APRESENTAÇÃO]([https://youtu.be/TIbWtGHwb4A])**

---

## ✨ Funcionalidades

*   **Busca de Filmes:** Pesquisa de títulos diretamente na base de dados do IMDb (via OMDb API).
*   **Lista "Quero Assistir":** Adiciona filmes desejados a uma *watchlist* local.
*   **Lista "Já Assisti":** Move filmes assistidos e registra um histórico.
*   **Sistema de Avaliação:** Permite dar uma nota de 1 a 5 estrelas para os filmes já assistidos.
*   **Prevenção de Erros (UX):** Trava de segurança (Dialog) antes da exclusão de qualquer título para evitar *misclicks*.

---

## 🛠 Tecnologias e Pacotes Utilizados

*   **Flutter & Dart**
*   **`provider`:** Gerenciamento de estado baseado na arquitetura MVVM (Model-View-ViewModel).
*   **`sqflite` & `path`:** Criação e manipulação do banco de dados relacional SQLite no dispositivo móvel.
*   **`http`:** Realização de requisições REST (GET) para a OMDb API e tratamento de JSON.

---

## 🏗 Arquitetura do Projeto

O projeto segue a arquitetura **MVVM**, com forte separação de responsabilidades e um *Design System* centralizado:

```text
lib/
├── main.dart
└── src/
    ├── models/         # Estrutura de dados (FilmeModel)
    ├── services/       # Comunicação externa (ApiService, DatabaseHelper)
    ├── viewmodels/     # Regras de negócio e estado (FilmeViewModel)
    ├── pages/          # Telas da aplicação (HomePage, BuscaPage, DetalhesPage)
    ├── widgets/        # Componentes reutilizáveis (FilmeCard, AvaliacaoWidget, CampoBusca)
    └── theme/          # Design System (Cores, Estilos de texto, Tema Global)
```
