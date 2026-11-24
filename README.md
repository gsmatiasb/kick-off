# Kick Off

App instalável pelo Safari (PWA) para controlar pacotes de camisetas importadas, custos, imposto rateado, lucro, caixa e valores a receber. Os dados ficam no Supabase, compartilhados entre os membros da loja (cada um com seu login), atualizam ao vivo entre os aparelhos, e o app funciona offline (sincroniza quando a internet volta).

## 1. Banco de dados (Supabase)
Os dados são **da loja**: todo membro liberado vê e edita as mesmas informações, cada um com seu próprio login.

1. Crie uma conta gratuita em https://supabase.com e um projeto novo.
2. Em **Authentication > Users**, clique em **Add user > Create new user** para você e para cada pessoa da operação (e-mail e senha, marcando **Auto Confirm User**).
3. Em **SQL Editor**, cole o conteúdo de `supabase.sql`, troque os e-mails e nomes da **Parte 2** pelos reais e clique em **Run**.
4. Em **Authentication > Sign In / Providers**, desligue **Allow new users to sign up**, para ninguém mais criar conta.
5. Em **Project Settings > API**, copie a **Project URL** e a chave **anon public** e cole em `config.js`.

Para incluir alguém depois: crie o usuário (passo 2) e rode só a Parte 2 com o e-mail dele. Para tirar o acesso, use o comando de remoção no fim do `supabase.sql`.

## 2. Publicar (GitHub Pages)
1. Envie esta pasta para um repositório do GitHub.
2. Em **Settings > Pages**, escolha **Deploy from a branch**, branch `main`, pasta `/ (root)`.
3. O endereço fica `https://SEU-USUARIO.github.io/NOME-DO-REPOSITORIO/`.

## 3. Instalar no iPhone
1. Abra o endereço no **Safari**.
2. Toque em **Compartilhar > Adicionar à Tela de Início**.
3. Abra pelo ícone e entre com o e-mail e a senha criados no passo 1.

## Atualizações
Ao alterar arquivos, aumente o número em `CACHE` no `sw.js` (ex.: `camisetas-v2`) para os aparelhos baixarem a versão nova. O app atualiza ao ser aberto com internet.

## Backup
No app, toque no indicador de sincronização (canto superior direito) para exportar ou importar um backup em arquivo.
