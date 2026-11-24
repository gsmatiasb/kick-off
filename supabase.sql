-- =====================================================================
-- PARTE 1 — Rode uma vez: SQL Editor > New query > colar tudo > Run.
-- Cria os dados compartilhados da loja e a lista de membros.
-- =====================================================================

-- Quem pode usar o app
create table if not exists public.membros (
  user_id   uuid primary key references auth.users(id) on delete cascade,
  nome      text,
  criado_em timestamptz not null default now()
);

-- Dados da loja (pacotes, lançamentos, a receber e caixa), iguais para todos os membros
create table if not exists public.registros (
  colecao        text        not null,
  id             text        not null,
  dados          jsonb       not null,
  atualizado_em  timestamptz not null default now(),
  atualizado_por uuid        default auth.uid() references auth.users(id) on delete set null,
  primary key (colecao, id)
);

-- Verifica se quem está logado é membro (usada pelas regras abaixo)
create or replace function public.eh_membro()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.membros where user_id = auth.uid()) $$;

alter table public.membros   enable row level security;
alter table public.registros enable row level security;

drop policy if exists "membros veem a lista"   on public.membros;
drop policy if exists "membros usam os dados" on public.registros;
-- A lista de membros só é alterada aqui pelo SQL Editor (não pelo app).
create policy "membros veem a lista"   on public.membros   for select to authenticated using (public.eh_membro());
create policy "membros usam os dados" on public.registros for all    to authenticated using (public.eh_membro()) with check (public.eh_membro());

-- Permissões para o app acessar as tabelas pela API (as regras acima continuam valendo)
grant usage on schema public to authenticated;
grant select on public.membros to authenticated;
grant select, insert, update, delete on public.registros to authenticated;
grant execute on function public.eh_membro() to authenticated;
revoke all on public.membros, public.registros from anon;

-- Atualização ao vivo entre os iPhones
do $$ begin
  alter publication supabase_realtime add table public.registros;
exception when duplicate_object then null; end $$;


-- =====================================================================
-- PARTE 2 — Liberar pessoas. Antes, crie cada usuário em
-- Authentication > Users > Add user (marque "Auto Confirm User").
-- Troque os e-mails e nomes abaixo e rode. Pode rodar de novo para incluir alguém.
-- =====================================================================
insert into public.membros (user_id, nome)
select id, 'Seu nome'  from auth.users where email = 'seu-email@exemplo.com'
on conflict (user_id) do nothing;

insert into public.membros (user_id, nome)
select id, 'Nome do amigo' from auth.users where email = 'email-do-amigo@exemplo.com'
on conflict (user_id) do nothing;

-- Ver quem tem acesso:
--   select m.nome, u.email from public.membros m join auth.users u on u.id = m.user_id;
-- Remover o acesso de alguém:
--   delete from public.membros where user_id = (select id from auth.users where email = 'email@exemplo.com');
