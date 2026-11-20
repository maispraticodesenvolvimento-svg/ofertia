# Frontend Ofertia e backend

## Iniciar

1. Inicie o backend em `../backend` com `npm run dev`.
2. No frontend, rode `flutter pub get` e inicie com `flutter run -d chrome`.
3. O app consulta `/api/health` e mostra a conexão no topo. Android Emulator usa `http://10.0.2.2:3000` por padrão; Flutter Web e simulador iOS usam `http://localhost:3000`. Para aparelho físico ou outro endereço, passe `--dart-define=API_BASE_URL=http://IP_DA_MAQUINA:3000`.

## Login

Cadastro, login e recuperação de senha são enviados ao backend. O backend usa Firebase Admin e a API de autenticação do Firebase com a chave mantida apenas no `.env` do servidor. Após login, o servidor cria uma sessão em cookie `HttpOnly`; o Flutter não inicializa Firebase nem recebe chaves Firebase.

Na tela de login, entre ou crie uma conta com e-mail e senha e use **Esqueci minha senha** para receber o link de recuperação. Ative o provedor E-mail/Senha no Firebase Authentication. Os produtos, ofertas, banners, pedidos, negociações, clientes, vendedores, relatórios e configurações carregam da API. O cadastro e edição de produtos e banners grava no Realtime Database. As rotas administrativas exigem `users/{uid}/role = admin` no banco.

As chaves públicas do app Firebase são diferentes da chave privada da conta de serviço. Nunca passe `FIREBASE_PRIVATE_KEY` ao Flutter. Em desenvolvimento, o backend permite CORS para origens `localhost` e `127.0.0.1`.
