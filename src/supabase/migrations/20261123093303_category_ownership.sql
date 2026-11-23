alter table public.income_categories
  add column users_id integer references public.users (users_id);

alter table public.outcome_categories
  add column users_id integer references public.users (users_id);
