# Frontend Ofertia e backend

## Iniciar

1. O app usa `https://backend-ofertia.vercel.app` como backend padrão.
2. No frontend, rode `flutter pub get` e inicie com `flutter run -d chrome`.
3. O app consulta `/api/health` e mostra a conexão no topo. Para desenvolver com o backend local, passe `--dart-define=API_BASE_URL=http://localhost:3000` ao comando Flutter. No Android Emulator, use `http://10.0.2.2:3000`; em aparelho físico, use o IP da máquina que executa o backend.

## Login

Cadastro, login e recuperação de senha são enviados ao backend. O backend usa Firebase Admin e a API de autenticação do Firebase com a chave mantida apenas no `.env` do servidor. Após login, o servidor cria uma sessão em cookie `HttpOnly`; o Flutter não inicializa Firebase nem recebe chaves Firebase.

Na tela de login, entre ou crie uma conta com e-mail e senha e use **Esqueci minha senha** para receber o link de recuperação. Ative o provedor E-mail/Senha no Firebase Authentication. Os produtos, ofertas, banners, pedidos, negociações, clientes, vendedores, relatórios e configurações carregam da API. O cadastro e edição de produtos e banners grava no Realtime Database. As rotas administrativas exigem `users/{uid}/role = admin` no banco.

As chaves públicas do app Firebase são diferentes da chave privada da conta de serviço. Nunca passe `FIREBASE_PRIVATE_KEY` ao Flutter. Em desenvolvimento, o backend local deve permitir CORS para as origens `localhost` e `127.0.0.1`.
