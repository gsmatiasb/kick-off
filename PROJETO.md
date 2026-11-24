# Kick Off: documentação completa do projeto

Este arquivo guarda todo o contexto do app **Kick Off**: o que ele faz, as regras de cálculo, como foi construído, onde está hospedado e como manter. Se a conversa original com o Claude se perder, este documento basta para continuar o projeto.

> Este repositório é **público**. Não escreva aqui senhas, chaves secretas ou dados de clientes.

---

## 1. O negócio

Venda de camisetas de times de futebol importadas, sob encomenda.

1. O cliente pede a camiseta.
2. Eu faço o pedido ao fornecedor (importação). O fornecedor passa o preço **em dólar** e gera um **PIX em reais**, já convertido e com pequenas taxas embutidas.
3. Eu pago o fornecedor com o dinheiro da própria loja.
4. Quando o pacote chega ao Brasil, pago o **imposto** e, se houver, a **entrega**.
5. O cliente só me paga **depois que a camiseta chega**.

Por isso o sistema controla o dinheiro que saiu do caixa e ainda não voltou (capital empatado) e o que falta receber de cada cliente.

Uma pessoa ajuda na operação e usa o app com login próprio. Os dados são compartilhados entre os dois.

---

## 2. Regras de cálculo

### Custo da camiseta em reais
- No **pacote** eu informo o **valor total pago no PIX** (R$).
- Em cada **camiseta** eu informo o **preço em dólar** (US$).
- **Custo de cada dólar** = valor do PIX ÷ soma dos dólares de todas as camisetas do pacote.
- **Custo da camiseta** = preço em US$ × custo de cada dólar.

Exemplo: PIX de R$ 500,00 e 5 camisetas de US$ 10. Total de US$ 50, então cada dólar custa R$ 10,00 e cada camiseta custa R$ 100,00.

Cada camiseta nova lançada no pacote muda o custo por dólar de todas as outras. O valor só fica certo quando todas as camisetas do pacote estiverem lançadas.

### Imposto e entrega
- Preenchidos no pacote quando ele chega (o valor só é conhecido nessa hora).
- São **rateados** entre as camisetas, na proporção do preço em dólar de cada uma.
- **Custo final da camiseta** = custo em reais + parte do imposto + parte da entrega.

### Lucro
- **Lucro da camiseta** = valor de venda ao cliente − custo final.
- **Lucro do pacote** = soma dos lucros das camisetas, que é o mesmo que venda total − (PIX + imposto + entrega).
- **Lucro realizado** = lucro das camisetas já pagas pelos clientes.
- **Lucro previsto** = lucro das camisetas ainda não pagas.

### Caixa
- Eu lanço o **"caixa de hoje"** (quanto há em caixa agora). Esse valor vira o ponto de partida.
- **Caixa atual** = saldo lançado + movimentos registrados **depois** desse lançamento.
- Movimentos automáticos:
  - PIX ao fornecedor (saída), na hora em que o pacote é cadastrado;
  - imposto e entrega (saídas), na hora em que são preenchidos;
  - camiseta marcada como paga (entrada);
  - valor "a receber" manual marcado como recebido (entrada).
- Movimentos manuais: **entradas** e **saídas**, cada uma com valor, data e motivo/observação.
- Lançar um novo "caixa de hoje" reinicia a conta. Os movimentos anteriores deixam de somar.

### A receber
- Soma do valor de venda das camisetas ainda não pagas, mais os valores "a receber" lançados manualmente (por exemplo, pedidos que chegaram e ainda não foram entregues).
- **Capital empatado** = custo final das camisetas ainda não pagas (dinheiro da loja que ainda não voltou).

### Situação do pacote
Pedido feito → Em trânsito → No Brasil → Concluído.
- Ao preencher o imposto, o pacote passa sozinho para **No Brasil**.
- Quando todas as camisetas de um pacote "No Brasil" estão pagas, ele passa para **Concluído**.

---

## 3. Funcionalidades por tela

**Resumo**
- Saudação, data e logo.
- Cartões: valor em caixa, a receber, capital empatado, lucro realizado e lucro previsto.
- Pacotes recentes e a lista de camisetas que chegaram e ainda não foram pagas.

**Pacotes**
- Busca por time, cliente ou nome do pacote; filtro Em aberto / Concluídos / Todos.
- Dentro do pacote:
  - situação, valor do PIX, total em dólar, custo de cada dólar, imposto, entrega e observações;
  - camisetas com descrição, **versão** (Fan / Player / Retro), tamanho, cliente, preço em US$, valor de venda;
  - cada camiseta mostra custo, venda e lucro em reais, a conta usada e o botão Pago / A receber;
  - ao cadastrar uma camiseta, a tela mostra ao vivo o custo em reais e o lucro;
  - botão "Salvar e adicionar outra" para lançar várias seguidas.

**Financeiro**
- Valor em caixa, botão "Lançar caixa de hoje", a receber e caixa + a receber.
- Botões Entrada, Saída e A receber (manual).
- Aba **Extrato**: todos os movimentos depois do saldo lançado.
- Aba **A receber**: camisetas não pagas e valores manuais, com o botão "Recebi".

**Conta** (indicador no canto superior direito)
- Estado da sincronização: Ao vivo, Sincronizado, Offline ou Erro.
- Sincronizar agora, exportar backup, importar backup e sair da conta.

---

## 4. Design

- Visual de app nativo do iPhone: títulos grandes, listas agrupadas, barra de abas flutuante de vidro, janelas que sobem de baixo, interruptores, controles segmentados.
- Fundo: **textura cinza** (`img/textura.jpg`, imagem enviada pelo dono) escurecida com uma camada de cerca de 55% de preto e bordas mais escuras.
- Cartões em cinza translúcido mais claro, para contraste. Botões principais em cinza prateado.
- Logo **branca** (versão invertida da original preta), em `img/logo.png`.
- Ícone do app: logo branca sobre a textura escura (`icons/`).
- Cores de estado: verde para lucro e entradas, vermelho para saídas, âmbar para pendente ou no Brasil, azul para em trânsito.
- Animações ao passar o mouse e ao tocar: brilho que segue o cursor, leve inclinação 3D nos cartões, botões que crescem e encolhem.
- Etiquetas de versão: Fan prateada, Player dourada, Retro bege.

---

## 5. Arquitetura técnica

App web instalável (**PWA**), sem App Store. HTML, CSS e JavaScript puros, sem etapa de build.

| Arquivo | Função |
|---|---|
| `index.html` | O app inteiro (telas, estilos e lógica). **É o código-fonte principal.** |
| `config.js` | Endereço do Supabase e chave **publicável** |
| `supabase.js` | Biblioteca `@supabase/supabase-js` **2.118.0** (versão UMD), incluída no projeto para funcionar offline |
| `sw.js` | Service worker: guarda os arquivos para o app abrir sem internet |
| `manifest.webmanifest` | Nome "Kick Off", ícones, tela cheia |
| `icons/` | Ícones do app (180, 192, 512 e 512 maskable) |
| `img/` | Logo branca e textura do fundo |
| `supabase.sql` | Script que cria o banco e as regras de acesso |
| `README.md` | Passo a passo resumido de instalação |

### Como os dados funcionam no app
- Tudo fica numa tabela genérica `registros` no Supabase, com uma linha por item:
  - coleções: `pacotes`, `lancamentos`, `receber`, e `config/caixa` para o saldo lançado;
  - as camisetas ficam **dentro** do pacote (lista `itens`).
- **Offline:** o app guarda uma cópia local (localStorage) e uma **fila de envios**. Sem internet, as alterações entram na fila e são enviadas quando a conexão volta.
- **Ao vivo:** usa o Realtime do Supabase. Uma alteração feita num iPhone aparece no outro em segundos. Uma alteração local ainda não enviada não é sobrescrita pela do outro aparelho.
- Ao abrir, ao voltar para o app e a cada minuto (se o "ao vivo" cair), o app busca tudo de novo no servidor.
- Se duas pessoas editarem o mesmo pacote ao mesmo tempo sem internet, vale a última alteração enviada.

### Estrutura de um pacote (campo `dados`)
```json
{
  "id": "…", "nome": "Pacote #1", "data": "2026-11-20", "fornecedor": "",
  "status": "pedido | transito | brasil | concluido",
  "pix": 500, "pixEm": 1764000000000,
  "imposto": 0, "impostoEm": null, "entrega": 0, "entregaEm": null,
  "obs": "", "criadoEm": 1764000000000,
  "itens": [
    { "id": "…", "descricao": "Flamengo 25/26 Home", "versao": "fan | player | retro",
      "tamanho": "G", "cliente": "Nome", "usd": 10, "venda": 150,
      "pago": false, "pagoEm": null }
  ]
}
```
Lançamento manual: `{ id, tipo: "entrada" | "saida", valor, data, obs, em }`.
A receber manual: `{ id, cliente, descricao, valor, data, recebido, recebidoEm, em }`.
Caixa (`config/caixa`): `{ valor, em }`, onde `em` é o momento do lançamento em milissegundos.

---

## 6. Banco de dados (Supabase)

- Projeto: `ajzzjknqpxucclzvotxa`, região América do Sul (São Paulo), plano gratuito.
- Endereço: `https://ajzzjknqpxucclzvotxa.supabase.co`.
- O app usa a chave **publicável** (`sb_publishable_…`), que já está no `config.js`.

### Tabelas
- `membros (user_id, nome, criado_em)`: quem pode usar o app.
- `registros (colecao, id, dados, atualizado_em, atualizado_por)`: os dados da loja, compartilhados entre os membros. `atualizado_por` guarda quem fez a última alteração.

### Segurança (RLS)
- Só usuários **logados** e **presentes em `membros`** leem ou alteram `registros`.
- A lista `membros` só é alterada pelo SQL Editor do Supabase, nunca pelo app.
- Visitantes sem login não têm nenhuma permissão nas tabelas. Isso foi testado: leitura e gravação são negadas.
- O Realtime está habilitado na tabela `registros`.

### Incluir uma pessoa
1. Supabase → **Authentication → Users → Add user → Create new user**, com e-mail e senha, marcando **Auto Confirm User**.
2. No **SQL Editor**, rode (trocando os dados):
```sql
insert into public.membros (user_id, nome)
select id, 'Nome da pessoa' from auth.users where email = 'email@exemplo.com'
on conflict (user_id) do nothing;
```

### Remover o acesso de alguém
```sql
delete from public.membros where user_id = (select id from auth.users where email = 'email@exemplo.com');
```

### Ver quem tem acesso
```sql
select m.nome, u.email from public.membros m join auth.users u on u.id = m.user_id;
```

### Recriar o banco do zero
Rode o `supabase.sql` inteiro no SQL Editor (Parte 1), depois a Parte 2 com os e-mails. O script pode ser executado mais de uma vez sem problema.

---

## 7. Hospedagem e publicação

- Repositório: **github.com/gsmatiasb/kick-off** (público, branch `main`).
- Publicado pelo **GitHub Pages** (Settings → Pages → Deploy from a branch → `main` / root).
- Endereço do app: **https://gsmatiasb.github.io/kick-off/**
- Toda alteração enviada para a branch `main` é publicada sozinha em 1 a 2 minutos.

### Publicar uma alteração
1. Edite os arquivos (normalmente `index.html`).
2. **Aumente o número do cache** em `sw.js` (por exemplo `camisetas-v4` → `camisetas-v5`). Sem isso, os iPhones podem continuar com a versão antiga.
3. Envie para a branch `main`.
4. No iPhone, abra o app com internet (às vezes é preciso abrir duas vezes).

---

## 8. Instalar no iPhone

1. Abra **https://gsmatiasb.github.io/kick-off/** no **Safari**.
2. **Compartilhar → Adicionar à Tela de Início → Adicionar**. O nome e o ícone já vêm prontos.
3. Abra pelo ícone e entre com o próprio e-mail e senha.

Se precisar reinstalar, apague o ícone antigo (segure o dedo → Remover App → Apagar da Tela de Início) e repita.

---

## 9. Segurança: o que é público e o que é segredo

**Pode ficar público** (já está no repositório):
- o código do app, as imagens e o ícone;
- o endereço do Supabase e a chave **publicável**, que sozinha não abre nenhum dado.

**Nunca compartilhe nem coloque no repositório:**
- as senhas de login das pessoas;
- a senha do banco de dados (gerada ao criar o projeto);
- a chave **secreta** do Supabase (*secret key* / *service_role*), que ignora todas as regras de acesso.

**Lista de conferência**
- [ ] **Cadastro de novos usuários desligado**: Authentication → Sign In / Providers → desligar "Allow new users to sign up". Na última verificação ele ainda estava ligado; confira.
- [ ] Senhas fortes e diferentes para cada pessoa.
- [ ] Ao tirar alguém da operação, remova a pessoa de `membros` e, se quiser, apague o usuário em Authentication.
- [ ] Exporte um **backup** de vez em quando (Conta → Exportar backup) e guarde no app Arquivos ou no iCloud.

---

## 10. Solução de problemas

| Problema | O que fazer |
|---|---|
| "E-mail ou senha incorretos" | Confira se o usuário existe e foi criado com Auto Confirm User. Se preciso, redefina a senha em Authentication → Users. |
| "Esse e-mail ainda não foi confirmado" | Em Authentication → Users, confirme o usuário ou crie de novo com Auto Confirm User. |
| Tela "Acesso pendente" | O e-mail não está em `membros`. Rode o comando de inclusão da seção 6. |
| "Erro ao sincronizar" | Toque no indicador para ver a mensagem. Em geral o `supabase.sql` precisa ser rodado de novo. |
| "Offline · X pendentes" | Sem internet. As alterações serão enviadas quando a conexão voltar. Não saia da conta enquanto houver pendentes. |
| Alteração no outro iPhone não aparece | Toque no indicador → Sincronizar agora. |
| App não atualiza depois de uma mudança | Confirme que o número do cache em `sw.js` foi aumentado. Feche e abra o app com internet. |
| Supabase "pausado" | No plano gratuito, projetos sem uso por cerca de uma semana podem ser pausados. Entre no painel do Supabase e clique em **Restore**. |

---

## 11. Como continuar o projeto com o Claude

Em uma conversa nova no Claude Code (claude.ai/code), selecione o repositório **gsmatiasb/kick-off** e peça para ele ler este `PROJETO.md`. Ao pedir mudanças, lembre que:
- o código está todo em `index.html`;
- é preciso aumentar o número do cache em `sw.js` a cada mudança;
- o ambiente do Claude Code chamado **kick-off** já libera o acesso ao Supabase e ao site publicado, para testes.

Existe também uma primeira versão do sistema publicada como página no claude.ai (https://claude.ai/artifact/LANcKunXAggRArt5DCK1jT). Ela foi **substituída por este app** e não tem dados.

---

## 12. Histórico de decisões

1. Primeira versão como página no claude.ai, com dados salvos lá.
2. Custo em reais calculado pelo **custo de cada dólar** (PIX ÷ total em US$), mostrado em destaque, com lucro por camiseta.
3. Fundo trocado pela textura cinza enviada pelo dono e depois escurecido para dar mais contraste.
4. Campo **Versão** (Fan / Player / Retro) nas camisetas.
5. Migração para um app instalável pelo Safari (PWA), com dados no Supabase e hospedagem no GitHub Pages.
6. Dados **compartilhados da loja** com lista de membros: cada pessoa com o próprio login, atualização ao vivo entre os aparelhos.
7. App renomeado para **Kick Off**, com a logo como ícone.

## 13. Ideias para o futuro

- Mostrar quem fez cada alteração (o dado `atualizado_por` já é gravado).
- Relatórios por mês: lucro, volume de camisetas, ticket médio.
- Cadastro de clientes com histórico de pedidos.
- Filtros por versão (Fan / Player / Retro) e por time.
